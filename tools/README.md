# Tool Installer

`install.py` deploys the latest released binaries of command-line tools into
`~/.local/bin`, reading `manifest.json`. It supports macOS and Linux on AMD64
and ARM64, and is pure standard library (Python 3.8+).

On macOS a Homebrew formula is preferred when one exists, and the resulting
binary is symlinked into the destination; otherwise a public release binary is
downloaded. GitHub release metadata is fetched anonymously, so no token or
`gh` login is required.

## Groups

Tools are organized into groups. Only groups marked `"default": true` install
when no group arguments are given — currently just `general`.

| Group | Default | Contents |
| --- | --- | --- |
| `general` | yes | Shell, search, and file tools: starship, carapace, atuin, zoxide, direnv, assh, fzf, ripgrep, fd, eza, bat, vivid, glow, tldr, jless, fx, xh, gdu, jq, yq |
| `git` | no | gh, delta, lazygit, gitleaks |
| `docker` | no | lazydocker, docker-compose |
| `k8s` | no | kubectl, kubecolor, k9s, helm, helmfile, kubectx, kubens, switcher |
| `security` | no | step |
| `tanzu` | no | tanzu-cli, velero, clusterctl, and the Carvel tools (ytt, imgpkg, kbld, kapp, kwt, kctrl, vendir) |

`+NAME` selects a group. Any `+` argument makes the selection explicit, so
`+k8s +docker` installs those two groups and nothing else.

`all` is a pseudo-group meaning every group, so `+all` installs everything and
`+all -tanzu` is everything except tanzu.

`-NAME` deselects a group **and removes its installed binaries and man
pages**. Removal only touches tools recorded in the installer's state file
(`<dest>/.tools-installed.json`), so binaries installed by other means are
left alone, and re-running is a no-op.

```sh
./install.py                  # the default groups (general)
./install.py +k8s             # k8s only
./install.py +k8s +docker     # k8s and docker
./install.py +all             # every group
./install.py +all -tanzu      # every group except tanzu
./install.py -k8s             # defaults minus k8s, removing its files
./install.py --groups         # list groups and exit
```

## Other options

```sh
./install.py --list           # show the resolved plan, install nothing
./install.py --dry-run        # resolve versions, download nothing
./install.py --only fzf bat   # restrict to these tools
./install.py --force          # re-download even when up to date
./install.py --dest ~/bin     # override the destination
./install.py --prefer-binary  # prefer downloads, brew only as fallback
./install.py --no-brew        # never use brew
```

Re-running only re-downloads tools whose latest version differs from what was
last installed. Man pages bundled in an archive are installed alongside the
binary, into `<dest>/../share/man/man<section>/` (`~/.local/share/man`), which
`man` discovers automatically because the bin directory is on `PATH`.

## Caching for other hosts

`--cache-dir` resolves and downloads binaries for other platforms without
installing them locally — intended to run once on an Ansible controller, which
then copies each `<cache-dir>/<os>-<arch>/` slice to the matching host. This
mode is always binary-only, since a Homebrew install is not portable.

```sh
./install.py --cache-dir /srv/tools --for linux/amd64 darwin/arm64
```

## Adding a tool

Add an entry to the appropriate group's `tools` array in `manifest.json`:

```json
{
  "name": "example",
  "provider": "github",
  "repo": "owner/example",
  "bin": "example",
  "match": {
    "darwin": "example-.*-{arch}-apple-darwin\\.tar\\.gz",
    "linux": "example-.*-{arch}-unknown-linux-(?:musl|gnu)\\.tar\\.gz"
  }
}
```

- `provider` — `github` (releases), `kubectl`, or `helm` (upstream endpoints).
- `match` — a Python regex matched against release asset names with
  `re.fullmatch`; `{arch}` expands to the architecture synonyms for the running
  machine. Omit an OS to skip the tool there (it reports as not applicable).
- `bin` — the installed executable name. `archive_bin` overrides the pattern
  used to locate it inside an archive when it differs.
- `brew` — a formula name when it differs from `name`, or `false` to opt out
  of Homebrew for that tool.
- `dest` — an install directory for that tool alone, overriding the run's
  destination. Used for Docker CLI plugins, which must live in
  `~/.docker/cli-plugins` rather than the bin directory. Ignored in
  `--cache-dir` mode, whose slices are flat.

**Docker Desktop and `docker-compose`:** Desktop ships its own compose plugin
in `~/.docker/cli-plugins`. Installing the `docker` group overwrites it with
the upstream release, and a Desktop update may overwrite it back. On a machine
running Docker Desktop, prefer letting Desktop manage compose (`-docker`, or
`--only` the other docker tools); the manifest entry is aimed at hosts with
Docker Engine but no Desktop.
