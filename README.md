# Profile Configuration

Personal shell and development environment configuration.

## Shell Configuration

- **Shell**: zsh with Powerlevel10k prompt
- **File Manager**: eza (ls replacement), fd (find replacement)
- **File Search**: rg (ripgrep), fzf
- **Git**: gh, fzf, fzf-git.sh
- **Directory Navigation**: zoxide
- **History**: atuin
- **Terminal Multiplexer**: tmux

## Structure

```
config/zsh/
├── .zshrc                 # Main zsh configuration
├── .zshenv                # Environment variables (all sessions)
├── .p10k.zsh              # Powerlevel10k prompt config
└── zshrc.d/
    ├── global/            # Host-agnostic configs
    │   ├── prompts.zshrc
    │   └── grep.zshrc
    ├── platform/          # OS-specific configs
    │   └── darwin.zshrc
    ├── applications/      # Application configs (44 apps)
    └── functions/         # Custom shell functions
```

## Applications Configured

### Development Tools

- **Git**: gh, gitea, fd, fzf, fzf-git.sh
- **Docker**: docker, lazydocker (recommended)
- **Kubernetes**: kubernetes, minikube, tanzu
- **Cloud**: aws, az, oracle, vault, step

### Editors & Pagers

- **vim**, **bat**, **less**, **eza**, **ncdu**

### Version Management

- **conda**, **pyenv**, **rbenv**, **asdf**, **nodenv**, **goenv**

### Utilities

- **direnv**, **tmux**, **zoxide**, **atuin**, **fzf**, **fd**, **rg**

### Other

- **1password**, **gnupg**, **sqlite**, **yq**, **pandoc**

## Key Features

### Instant Prompt

Powerlevel10k instant prompt enabled for fast shell startup.

### Completion

- fzf-tab for interactive tab completion
- bash completion support
- Case-insensitive completion

### Git Workflow

- `gco` - checkout branch via fzf
- `gbr` - list branches via fzf
- `glog` - visualize git log via fzf
- `gcf` - fixup commits via fzf

### Directory Navigation

- `z` - zoxide jump
- `zf` - zoxide fzf picker

## Performance Optimizations

- One-shot compdump rebuild (daily)
- Lazy-loaded bash completion
- Instant prompt for Powerlevel10k
- Minimal application loading

## Adding Applications

Add a new application config in `config/zsh/zshrc.d/applications/<name>.zshrc`:

```zsh
is-executable <app> || return

# Configure application
export <VAR>="value"

# Or add aliases
alias <alias>="<command>"
```

## License

Private configuration.
