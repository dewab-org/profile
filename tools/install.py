#!/usr/bin/env python3
"""Deploy the latest released binaries of shell tools into ~/.local/bin.

Reads ``manifest.json`` (sibling file by default), resolves the latest release
for the current OS/arch, downloads the matching asset, extracts the binary and
installs it. Re-running only re-downloads tools whose latest version differs
from what was last installed (tracked in ``<dest>/.tools-installed.json``).

Supports macOS and Linux on x86_64 and arm64. Pure stdlib (Python 3.8+).

Usage:
    ./install.py                     # install/update everything
    ./install.py --only fzf bat      # just these tools
    ./install.py --list              # show resolved plan, install nothing
    ./install.py --force             # re-download even if up to date
    ./install.py --dry-run           # resolve + report, download nothing
    ./install.py --dest ~/bin        # override destination
    ./install.py --prefer-binary     # download binaries, brew only as fallback
    ./install.py --no-brew           # never use brew (binaries only)

GitHub release metadata is fetched anonymously because all configured
repositories and assets are public.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

ARCH_ALIASES = {
    "amd64": ["amd64", "x86_64", "x64"],
    "arm64": ["arm64", "aarch64"],
}
ARCHIVE_SUFFIXES = (".tar.gz", ".tgz", ".tar.xz", ".txz", ".tar.bz2", ".zip")
STATE_FILE = ".tools-installed.json"
UA = "profile.d-tools-installer"


# ── platform ────────────────────────────────────────────────────────────────
def detect_platform():
    sysname = platform.system().lower()  # darwin / linux
    machine = platform.machine().lower()
    if machine in ("x86_64", "amd64"):
        arch = "amd64"
    elif machine in ("arm64", "aarch64"):
        arch = "arm64"
    else:
        sys.exit(f"unsupported architecture: {machine}")
    if sysname not in ("darwin", "linux"):
        sys.exit(f"unsupported OS: {sysname}")
    return sysname, arch


def arch_regex(arch: str) -> str:
    return "(?:" + "|".join(ARCH_ALIASES[arch]) + ")"


# ── http ─────────────────────────────────────────────────────────────────────
def _request(url: str, accept: str | None = None) -> bytes:
    headers = {"User-Agent": UA}
    if accept:
        headers["Accept"] = accept
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def get_json(url: str) -> dict:
    return json.loads(_request(url, accept="application/vnd.github+json"))


def download(url: str, dest: Path) -> None:
    dest.write_bytes(_request(url))


# ── resolvers: return (version, asset_url, asset_name) ───────────────────────
def resolve_github(tool, osname, arch):
    match = (tool.get("match") or {}).get(osname)
    if not match:
        note = tool.get("note", "no asset for this OS")
        raise Skip(f"no {osname} build ({note})")
    pattern = re.compile(match.replace("{arch}", arch_regex(arch)))
    rel = get_json(f"https://api.github.com/repos/{tool['repo']}/releases/latest")
    version = rel.get("tag_name", "?")
    candidates = [a for a in rel.get("assets", []) if pattern.fullmatch(a["name"])]
    if not candidates:
        raise Skip(f"no asset matching /{match}/ in {version}")
    asset = min(candidates, key=_asset_rank)
    return version, asset["browser_download_url"], asset["name"]


def resolve_kubectl(tool, osname, arch):
    version = _request("https://dl.k8s.io/release/stable.txt").decode().strip()
    url = f"https://dl.k8s.io/release/{version}/bin/{osname}/{arch}/kubectl"
    return version, url, "kubectl"


def resolve_helm(tool, osname, arch):
    rel = get_json("https://api.github.com/repos/helm/helm/releases/latest")
    version = rel["tag_name"]
    name = f"helm-{version}-{osname}-{arch}.tar.gz"
    return version, f"https://get.helm.sh/{name}", name


RESOLVERS = {"github": resolve_github, "kubectl": resolve_kubectl, "helm": resolve_helm}


def _asset_rank(asset):
    """Prefer statically-linked (musl) Linux builds, then gnu; shorter names win ties."""
    n = asset["name"]
    libc = 0 if "musl" in n or "static" in n else (1 if "gnu" in n else 2)
    return (libc, len(n))


class Skip(Exception):
    """Tool is not applicable on this platform (informational, not an error)."""


# ── homebrew (macOS preferred method) ────────────────────────────────────────
def brew_path() -> str | None:
    return shutil.which("brew")


def _brew(*args, check=False) -> str:
    r = subprocess.run(["brew", *args], capture_output=True, text=True)
    if check and r.returncode != 0:
        raise RuntimeError(
            (r.stderr or r.stdout).strip() or f"brew {' '.join(args)} failed"
        )
    return r.stdout


def brew_formula(tool) -> str | None:
    """Formula name for a tool, or None if brew is disabled for it."""
    b = tool.get("brew", True)
    if b is False:
        return None
    return b if isinstance(b, str) else tool["name"]


def brew_installed_version(formula: str) -> str | None:
    out = _brew("list", "--versions", formula).split()
    return out[1] if len(out) >= 2 else None


def process_brew(tool, dest_dir, prefix, state, args):
    formula = brew_formula(tool)
    binname = tool["bin"]
    before = brew_installed_version(formula)
    if args.list or args.dry_run:
        flag = f"installed {before}" if before else "would install"
        return "plan", f"brew:{formula:<16} {flag}"

    if before is None:
        _brew("install", formula, check=True)
    elif args.force:
        _brew("reinstall", formula, check=True)
    else:
        _brew("upgrade", formula)  # no-op (nonzero allowed) when already current
    after = brew_installed_version(formula) or before

    src = Path(prefix) / "bin" / binname
    if not src.exists():
        raise RuntimeError(f"{binname} not in {src} after 'brew install {formula}'")
    link_into(dest_dir, binname, src)
    state[tool["name"]] = f"brew {after}"
    if before and before == after and not args.force:
        return "skip", f"brew up to date ({after})"
    return "ok", f"brew {formula} -> {after} (symlinked)"


def link_into(dest_dir: Path, name: str, src: Path) -> None:
    dest_dir.mkdir(parents=True, exist_ok=True)
    target = dest_dir / name
    tmp = dest_dir / (name + ".lnk")
    if tmp.is_symlink() or tmp.exists():
        tmp.unlink()
    os.symlink(src, tmp)
    os.replace(tmp, target)


# ── extraction / install ─────────────────────────────────────────────────────
def is_archive(name: str) -> bool:
    return name.endswith(ARCHIVE_SUFFIXES)


def extract_binary(archive: Path, workdir: Path, tool) -> Path:
    out = workdir / "x"
    out.mkdir()
    name = archive.name
    if name.endswith(".zip"):
        with zipfile.ZipFile(archive) as z:
            z.extractall(out)
    else:
        with tarfile.open(archive) as t:
            t.extractall(out)
    if tool.get("archive_bin"):
        wanted = re.compile(tool["archive_bin"])
    else:
        wanted = re.compile(re.escape(tool["bin"]))
    matches = [p for p in out.rglob("*") if p.is_file() and wanted.fullmatch(p.name)]
    if not matches:
        raise RuntimeError(f"binary not found inside {name}")
    # Prefer the shallowest match (avoids picking docs/aux files in deep dirs).
    return min(matches, key=lambda p: len(p.parts))


def install_binary(src: Path, dest_dir: Path, final_name: str) -> None:
    dest_dir.mkdir(parents=True, exist_ok=True)
    target = dest_dir / final_name
    tmp = dest_dir / (final_name + ".new")
    shutil.copy2(src, tmp)
    tmp.chmod(tmp.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    os.replace(tmp, target)


# ── state ────────────────────────────────────────────────────────────────────
def load_state(dest_dir: Path) -> dict:
    f = dest_dir / STATE_FILE
    if f.exists():
        try:
            return json.loads(f.read_text())
        except json.JSONDecodeError:
            pass
    return {}


def save_state(dest_dir: Path, state: dict) -> None:
    dest_dir.mkdir(parents=True, exist_ok=True)
    (dest_dir / STATE_FILE).write_text(
        json.dumps(state, indent=2, sort_keys=True) + "\n"
    )


# ── main ─────────────────────────────────────────────────────────────────────
def process(tool, osname, arch, dest_dir, state, args, brew_prefix):
    """Dispatch to brew or binary, honoring the requested preference.

    Default on macOS: brew (when a formula exists), else binary download.
    --prefer-binary: binary download (when available for this platform), and
    only fall back to brew if no binary exists here.
    --no-brew: binary only (sets brew_prefix=None upstream).
    """
    brew_ok = bool(brew_prefix and brew_formula(tool))
    if args.prefer_binary:
        try:
            return process_binary(tool, osname, arch, dest_dir, state, args)
        except Skip:
            if brew_ok:
                return process_brew(tool, dest_dir, brew_prefix, state, args)
            raise
    if brew_ok:
        return process_brew(tool, dest_dir, brew_prefix, state, args)
    return process_binary(tool, osname, arch, dest_dir, state, args)


def process_binary(tool, osname, arch, dest_dir, state, args):
    name = tool["name"]
    resolver = RESOLVERS.get(tool["provider"])
    if not resolver:
        return "fail", f"unknown provider {tool['provider']!r}"
    version, url, asset_name = resolver(tool, osname, arch)

    installed = state.get(name)
    present = (dest_dir / tool["bin"]).exists()
    if args.list or args.dry_run:
        flag = "up-to-date" if (installed == version and present) else "would install"
        return "plan", f"{version:<14} {flag}  ({asset_name})"
    if installed == version and present and not args.force:
        return "skip", f"up to date ({version})"

    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        blob = tmp / asset_name
        download(url, blob)
        binpath = extract_binary(blob, tmp, tool) if is_archive(asset_name) else blob
        install_binary(binpath, dest_dir, tool["bin"])
    state[name] = version
    return "ok", f"installed {version} -> {tool['bin']}"


def main(argv=None):
    here = Path(__file__).resolve().parent
    ap = argparse.ArgumentParser(
        description="Install latest tool binaries into ~/.local/bin"
    )
    ap.add_argument("--manifest", type=Path, default=here / "manifest.json")
    ap.add_argument(
        "--dest", type=Path, default=None, help="install dir (default from manifest)"
    )
    ap.add_argument(
        "--only", nargs="+", metavar="TOOL", help="restrict to these tool names"
    )
    ap.add_argument(
        "--force", action="store_true", help="re-download even if up to date"
    )
    ap.add_argument(
        "--dry-run", action="store_true", help="resolve versions, download nothing"
    )
    ap.add_argument("--list", action="store_true", help="show plan and exit")
    ap.add_argument(
        "--no-brew",
        action="store_true",
        help="ignore Homebrew entirely, always fetch binaries",
    )
    ap.add_argument(
        "--prefer-binary",
        action="store_true",
        help="prefer downloaded binaries over brew, falling back to brew only when no binary exists for this platform",
    )
    args = ap.parse_args(argv)

    manifest = json.loads(args.manifest.read_text())
    dest_dir = (
        args.dest or Path(os.path.expanduser(manifest.get("dest", "~/.local/bin")))
    ).expanduser()
    osname, arch = detect_platform()

    brew_prefix = None
    if osname == "darwin" and not args.no_brew and brew_path():
        brew_prefix = _brew("--prefix").strip()
    if not brew_prefix:
        method = "binary downloads"
    elif args.prefer_binary:
        method = f"binary downloads (brew @ {brew_prefix} fallback)"
    else:
        method = f"brew @ {brew_prefix} (binary fallback)"
    print(f"platform: {osname}/{arch}   dest: {dest_dir}   method: {method}\n")

    tools = manifest["tools"]
    if args.only:
        wanted = set(args.only)
        tools = [t for t in tools if t["name"] in wanted]
        missing = wanted - {t["name"] for t in tools}
        if missing:
            sys.exit(f"unknown tool(s): {', '.join(sorted(missing))}")

    state = load_state(dest_dir)
    counts = {"ok": 0, "skip": 0, "plan": 0, "skip-platform": 0, "fail": 0}
    for tool in tools:
        try:
            status, msg = process(
                tool, osname, arch, dest_dir, state, args, brew_prefix
            )
        except Skip as e:
            status, msg = "skip-platform", str(e)
        except (urllib.error.HTTPError, urllib.error.URLError) as e:
            status, msg = "fail", f"download error: {e}"
        except Exception as e:  # noqa: BLE001 - report and continue
            status, msg = "fail", f"{type(e).__name__}: {e}"
        counts[status] = counts.get(status, 0) + 1
        glyph = {
            "ok": "✓",
            "skip": "=",
            "plan": "·",
            "skip-platform": "–",
            "fail": "✗",
        }[status]
        print(f"  {glyph} {tool['name']:<12} {msg}")

    if not (args.list or args.dry_run):
        save_state(dest_dir, state)

    print(
        f"\n{counts['ok']} installed, {counts['skip']} up-to-date, "
        f"{counts['skip-platform']} n/a here, {counts['fail']} failed"
    )
    if dest_dir.is_dir() and str(dest_dir) not in os.environ.get("PATH", "").split(
        os.pathsep
    ):
        print(f"\nnote: {dest_dir} is not in your PATH.")
    return 1 if counts["fail"] else 0


if __name__ == "__main__":
    sys.exit(main())
