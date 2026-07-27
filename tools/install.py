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
import random
import re
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
import time
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
MAX_RETRIES = 5
RETRY_BASE_DELAY = 2.0  # seconds, doubles each attempt


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
def _is_rate_limited(e: urllib.error.HTTPError) -> bool:
    if e.code == 429:
        return True
    # GitHub's primary rate limit is sometimes reported as a 403 with
    # X-RateLimit-Remaining: 0 rather than a 429.
    return e.code == 403 and e.headers.get("X-RateLimit-Remaining") == "0"


def _retry_delay(e: urllib.error.HTTPError, attempt: int) -> float:
    retry_after = e.headers.get("Retry-After")
    if retry_after:
        try:
            return float(retry_after)
        except ValueError:
            pass
    reset = e.headers.get("X-RateLimit-Reset")
    if reset:
        try:
            return max(0.0, float(reset) - time.time())
        except ValueError:
            pass
    return RETRY_BASE_DELAY * (2**attempt) + random.uniform(0, 1)


def _request(url: str, accept: str | None = None) -> bytes:
    headers = {"User-Agent": UA}
    if accept:
        headers["Accept"] = accept
    req = urllib.request.Request(url, headers=headers)
    for attempt in range(MAX_RETRIES + 1):
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                return resp.read()
        except urllib.error.HTTPError as e:
            if attempt == MAX_RETRIES or not _is_rate_limited(e):
                raise
            delay = _retry_delay(e, attempt)
            print(
                f"  … {e.code} from {url}, retrying in {delay:.0f}s "
                f"({attempt + 1}/{MAX_RETRIES})",
                file=sys.stderr,
            )
            time.sleep(delay)
    raise AssertionError("unreachable")  # loop always returns or raises


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


def unpack_archive(archive: Path, workdir: Path) -> Path:
    """Extract an archive into a fresh dir and return its root."""
    out = workdir / "x"
    out.mkdir()
    if archive.name.endswith(".zip"):
        with zipfile.ZipFile(archive) as z:
            z.extractall(out)
    else:
        with tarfile.open(archive) as t:
            t.extractall(out)
    return out


def find_binary(root: Path, tool) -> Path:
    if tool.get("archive_bin"):
        wanted = re.compile(tool["archive_bin"])
    else:
        wanted = re.compile(re.escape(tool["bin"]))
    matches = [p for p in root.rglob("*") if p.is_file() and wanted.fullmatch(p.name)]
    if not matches:
        raise RuntimeError(f"binary not found inside {root.name}")
    # Prefer the shallowest match (avoids picking docs/aux files in deep dirs).
    return min(matches, key=lambda p: len(p.parts))


# man page filenames: foo.1, foo.8, foo.1.gz, foo.1.zst, ...
MAN_RE = re.compile(r"\.([1-8])(?:\.(?:gz|bz2|xz|zst))?$")
_MAN_COMPRESSED = (".gz", ".bz2", ".xz", ".zst")


def install_manpages(root: Path, man_root: Path) -> int:
    """Copy any man pages bundled in the extracted archive into
    <man_root>/man<section>/. Returns the number installed.

    A '.TH' sniff on uncompressed files guards against picking up unrelated
    files that merely end in a digit; compressed pages are trusted as-is.
    """
    count = 0
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        m = MAN_RE.search(p.name)
        if not m:
            continue
        if not p.name.endswith(_MAN_COMPRESSED):
            try:
                if b".TH" not in p.read_bytes()[:4096]:
                    continue
            except OSError:
                continue
        dst_dir = man_root / f"man{m.group(1)}"
        dst_dir.mkdir(parents=True, exist_ok=True)
        tmp = dst_dir / (p.name + ".new")
        shutil.copy2(p, tmp)
        os.replace(tmp, dst_dir / p.name)
        count += 1
    return count


def install_binary(src: Path, dest_dir: Path, final_name: str) -> None:
    dest_dir.mkdir(parents=True, exist_ok=True)
    target = dest_dir / final_name
    tmp = dest_dir / (final_name + ".new")
    shutil.copy2(src, tmp)
    tmp.chmod(tmp.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    os.replace(tmp, target)


# ── state ────────────────────────────────────────────────────────────────────
def load_state(path: Path) -> dict:
    if path.exists():
        try:
            return json.loads(path.read_text())
        except json.JSONDecodeError:
            pass
    return {}


def save_state(path: Path, state: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n")


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


def process_binary(tool, osname, arch, dest_dir, state, args, install_man=True):
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

    # Man pages install as a sibling of the bin dir (~/.local/bin ->
    # ~/.local/share/man), which man-db and macOS man auto-discover because the
    # bin dir is on PATH. No MANPATH configuration required.
    man_root = dest_dir.parent / "share" / "man"
    man_added = 0
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        blob = tmp / asset_name
        download(url, blob)
        if is_archive(asset_name):
            root = unpack_archive(blob, tmp)
            binpath = find_binary(root, tool)
            if install_man:
                man_added = install_manpages(root, man_root)
        else:
            binpath = blob
        install_binary(binpath, dest_dir, tool["bin"])
    state[name] = version
    msg = f"installed {version} -> {tool['bin']}"
    if man_added:
        msg += f" (+{man_added} man)"
    return "ok", msg


def _select_tools(manifest: dict, only: list[str] | None) -> list:
    tools = manifest["tools"]
    if only:
        wanted = set(only)
        tools = [t for t in tools if t["name"] in wanted]
        missing = wanted - {t["name"] for t in tools}
        if missing:
            sys.exit(f"unknown tool(s): {', '.join(sorted(missing))}")
    return tools


def _run_tools(tools, process_one) -> dict:
    """Run process_one(tool) -> (status, msg) over tools, printing progress."""
    counts = {"ok": 0, "skip": 0, "plan": 0, "skip-platform": 0, "fail": 0}
    for tool in tools:
        try:
            status, msg = process_one(tool)
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
    return counts


# ── controller-side caching ───────────────────────────────────────────────────
def parse_platform(spec: str) -> tuple[str, str]:
    osname, _, arch = spec.partition("/")
    osname, arch = osname.lower(), arch.lower()
    if osname not in ("darwin", "linux"):
        sys.exit(f"invalid --for {spec!r}: unsupported OS {osname!r}")
    if arch not in ARCH_ALIASES:
        sys.exit(f"invalid --for {spec!r}: unsupported architecture {arch!r}")
    return osname, arch


def cache_main(args) -> int:
    """Resolve/download/extract binaries for one or more platforms into
    --cache-dir, without installing anywhere. Always binary-only (no brew,
    since a brew install isn't portable to another host/arch). Intended to
    run once on the Ansible controller; the caller then copies
    <cache-dir>/<os>-<arch>/ to each target host's install dir.
    """
    manifest = json.loads(args.manifest.read_text())
    tools = _select_tools(manifest, args.only)
    targets = [parse_platform(p) for p in args.targets]

    total_fail = 0
    for osname, arch in targets:
        dest_dir = args.cache_dir / f"{osname}-{arch}"
        state_path = args.cache_dir / ".state" / f"{osname}-{arch}.json"
        state = load_state(state_path)
        print(f"\ncaching {osname}/{arch} -> {dest_dir}")
        counts = _run_tools(
            tools,
            # Cache slices map directly onto the target's bin dir, so they carry
            # no share/man sibling; man pages are installed by the on-host run.
            lambda tool: process_binary(
                tool, osname, arch, dest_dir, state, args, install_man=False
            ),
        )
        if not (args.list or args.dry_run):
            save_state(state_path, state)
        print(
            f"  {counts['ok']} cached, {counts['skip']} up-to-date, "
            f"{counts['skip-platform']} n/a, {counts['fail']} failed"
        )
        total_fail += counts["fail"]
    return 1 if total_fail else 0


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
    ap.add_argument(
        "--cache-dir",
        type=Path,
        default=None,
        help=(
            "controller-side mode: resolve/download/extract binaries into "
            "<cache-dir>/<os>-<arch> for each --for platform instead of "
            "installing to --dest. Requires --for."
        ),
    )
    ap.add_argument(
        "--for",
        dest="targets",
        nargs="+",
        metavar="OS/ARCH",
        help="with --cache-dir: platform(s) to cache, e.g. linux/amd64 darwin/arm64",
    )
    args = ap.parse_args(argv)

    if args.cache_dir:
        if not args.targets:
            sys.exit("--cache-dir requires --for OS/ARCH [OS/ARCH ...]")
        return cache_main(args)

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

    tools = _select_tools(manifest, args.only)
    state_path = dest_dir / STATE_FILE
    state = load_state(state_path)
    counts = _run_tools(
        tools,
        lambda tool: process(tool, osname, arch, dest_dir, state, args, brew_prefix),
    )

    if not (args.list or args.dry_run):
        save_state(state_path, state)

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
