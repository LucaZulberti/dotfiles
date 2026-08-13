#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Helpers
# -----------------------------

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

skip_step() {
  local step="$1"
  shift
  printf 'Skipping %s: %s\n' "$step" "$*" >&2
}

commands_exist() {
  local cmd=""
  local missing=0

  for cmd in "$@"; do
    if ! command_exists "$cmd"; then
      warn "required command not found: $cmd"
      missing=1
    fi
  done

  return "$missing"
}

user_has_sudo() {
  # Root can proceed without sudo.
  if ((EUID == 0)); then
    return 0
  fi

  # sudo must exist and the user must be allowed to use it.
  command_exists sudo && sudo -v
}

init_homebrew() {
  local brew_bin=""

  if command_exists brew; then
    brew_bin="$(command -v brew)"
  elif [ -x /opt/homebrew/bin/brew ]; then
    brew_bin="/opt/homebrew/bin/brew"
  elif [ -x /usr/local/bin/brew ]; then
    brew_bin="/usr/local/bin/brew"
  elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
  else
    return 1
  fi

  eval "$("$brew_bin" shellenv)"
}

current_user_name() {
  if command_exists id; then
    id -un 2>/dev/null || printf '%s\n' "${USER:-unknown}"
  else
    printf '%s\n' "${USER:-unknown}"
  fi
}

homebrew_is_writable() {
  local brew_prefix=""

  if ! command_exists brew; then
    warn "brew is not available"
    return 1
  fi

  brew_prefix="$(brew --prefix 2>/dev/null || true)"
  if [ -z "$brew_prefix" ] || [ ! -d "$brew_prefix" ]; then
    warn "Homebrew prefix is not available"
    return 1
  fi

  if [ ! -w "$brew_prefix" ]; then
    warn "Homebrew prefix is not writable by $(current_user_name): $brew_prefix"
    warn "fix Homebrew ownership/permissions before running brew install"
    return 1
  fi
}

init_cargo() {
  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
  fi
}

tmpdirs=()
cleanup_tmpdirs() {
  command_exists rm || return 0

  local d=""
  for d in "${tmpdirs[@]}"; do
    if [ -n "$d" ] && [ -d "$d" ]; then
      rm -rf "$d"
    fi
  done
}
trap cleanup_tmpdirs EXIT

# -----------------------------
# Install Homebrew
# -----------------------------

if ! command_exists brew; then
  if user_has_sudo; then
    if commands_exist curl bash; then
      bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      skip_step "Homebrew installation" "curl or bash is not available"
    fi
  else
    skip_step "Homebrew installation" "user does not have sudo privileges"
  fi
fi

# Required on first installation. This is also safe when brew was already installed
# but not yet available in PATH.
if init_homebrew && command_exists brew; then
  # -----------------------------
  # Install Brew packages
  # -----------------------------

  if homebrew_is_writable; then
    brew install \
      1password-cli \
      bash-language-server \
      bat \
      bottom \
      broot \
      chezmoi \
      clang-format \
      commitlint \
      d2 \
      doxygen \
      efm-langserver \
      fd \
      fish fisher \
      fish-lsp \
      fnm \
      fzf \
      gawk \
      git git-delta git-filter-repo \
      git-cliff \
      gitui \
      golang \
      helix \
      marksman \
      parallel \
      ripgrep \
      ruff \
      scooter \
      sesh \
      shellcheck \
      shfmt \
      sk \
      tmux gitmux \
      tombi \
      tree-sitter-cli \
      uv \
      vips \
      yaml-language-server \
      yazi ffmpeg-full sevenzip jq poppler resvg imagemagick-full font-symbols-only-nerd-font \
      zoxide
  else
    skip_step "Brew packages" "Homebrew prefix is not writable by $(current_user_name)"
  fi
else
  skip_step "Brew packages" "brew is not available"
fi

# Refresh shell command lookup after possible Homebrew changes.
hash -r

# -----------------------------
# Install Fisher and its plugins
# -----------------------------

if command_exists fish; then
  # Fisher
  fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source'

  # Plugins
  fish -c 'fisher update'
fi

# -----------------------------
# Install Node.js
# -----------------------------

if command_exists fnm; then
  # Required before using fnm/npm in the current script.
  fnm_env="$(fnm env --shell bash)"
  eval "$fnm_env"

  fnm install --lts
  fnm use lts-latest
  fnm default lts-latest

  # Refresh shell command lookup so npm installed by fnm can be found.
  hash -r
else
  skip_step "Node.js installation" "fnm is not available"
fi

# -----------------------------
# Install npm-based tooling
# -----------------------------

if command_exists npm; then
  npm install -g \
    devmoji \
    prettier \
    typescript-language-server \
    @angular/language-server \
    vscode-langservers-extracted
else
  skip_step "npm-based tooling" "npm is not available"
fi

# -----------------------------
# Install Yazi packages
# -----------------------------

if command_exists ya; then
  ya pkg install
else
  skip_step "Yazi packages" "ya is not available"
fi

# -----------------------------
# Install Rust
# -----------------------------

init_cargo

if ! command_exists rustup; then
  if commands_exist curl sh; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  else
    skip_step "Rust installation" "curl or sh is not available"
  fi
fi

# Required on first installation.
init_cargo
hash -r

# -----------------------------
# Install Cargo binstall extension
# -----------------------------

if ! command_exists cargo-binstall; then
  if commands_exist curl bash; then
    curl -L --proto '=https' --tlsv1.2 -sSf \
      https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh |
      bash

    # cargo-binstall may have just been installed.
    init_cargo
    hash -r
  else
    skip_step "cargo-binstall installation" "curl or bash is not available"
  fi
fi

# -----------------------------
# Install Rust-based tooling
# -----------------------------

if commands_exist cargo cargo-binstall; then
  cargo binstall cargo-update
  cargo binstall eza
  cargo binstall zellij
else
  skip_step "cargo binstall binaries" "cargo or cargo-binstall is not available"
fi

if command_exists cargo; then
  cargo install vhdl_ls
else
  skip_step "vhdl_ls installation" "cargo is not available"
fi

# -----------------------------
# Install VHDL-LS libraries
# -----------------------------

if commands_exist git mktemp rm mv; then
  rust_tmp="$(mktemp -d)"
  tmpdirs+=("$rust_tmp")

  git clone --depth 1 --filter=blob:none --sparse \
    "https://github.com/VHDL-LS/rust_hdl.git" \
    "$rust_tmp/rust_hdl"

  git -C "$rust_tmp/rust_hdl" sparse-checkout set "vhdl_libraries"

  rm -rf "$HOME/.cargo/vhdl_libraries"
  mv "$rust_tmp/rust_hdl/vhdl_libraries" "$HOME/.cargo/vhdl_libraries"
else
  skip_step "VHDL-LS libraries" "git, mktemp, rm, or mv is not available"
fi

# -----------------------------
# Install Python with Miniconda
# -----------------------------

installer=""

if command_exists uname; then
  os_name="$(uname -s)"
  arch="$(uname -m)"

  case "$os_name" in
  Darwin)
    case "$arch" in
    arm64)
      installer="Miniconda3-latest-MacOSX-arm64.sh"
      ;;
    x86_64)
      installer="Miniconda3-latest-MacOSX-x86_64.sh"
      ;;
    *)
      skip_step "Miniconda installation" "unsupported macOS architecture: $arch"
      ;;
    esac
    ;;
  Linux)
    case "$arch" in
    x86_64)
      installer="Miniconda3-latest-Linux-x86_64.sh"
      ;;
    aarch64)
      installer="Miniconda3-latest-Linux-aarch64.sh"
      ;;
    *)
      skip_step "Miniconda installation" "unsupported Linux architecture: $arch"
      ;;
    esac
    ;;
  *)
    skip_step "Miniconda installation" "unsupported OS: $os_name"
    ;;
  esac
else
  skip_step "Miniconda installation" "uname is not available"
fi

if [ -n "$installer" ] && [ ! -x "$HOME/miniconda3/bin/conda" ]; then
  if commands_exist curl bash mktemp; then
    conda_tmp="$(mktemp -d)"
    tmpdirs+=("$conda_tmp")

    curl -fsSLo "$conda_tmp/$installer" "https://repo.anaconda.com/miniconda/$installer"
    bash "$conda_tmp/$installer" -b -p "$HOME/miniconda3"
  else
    skip_step "Miniconda installation" "curl, bash, or mktemp is not available"
  fi
fi

if [ -x "$HOME/miniconda3/bin/conda" ]; then
  # Activate conda so subsequent pip installs target Miniconda, not system Python.
  eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
  conda activate base
else
  skip_step "Conda activation" "conda is not available at $HOME/miniconda3/bin/conda"
fi

# -----------------------------
# Install Python-based tooling
# -----------------------------

if command_exists uv; then
  uv tool install emoji-fzf
  uv tool install "vsg @ git+https://github.com/lzulberti/vhdl-style-guide.git@3.35.0+multiblock"
else
  skip_step "Python-based tooling" "uv is not available"
fi

# -----------------------------
# Initialize or update chezmoi dotfiles
# -----------------------------

if command_exists chezmoi; then
  if chezmoi status >/dev/null 2>&1; then
    printf 'chezmoi is already initialized, running update...\n'
    chezmoi update
  else
    printf 'chezmoi is not initialized, running init...\n'
    chezmoi init LucaZulberti
  fi

  printf 'Verifying chezmoi managed files...\n'
  chezmoi verify || {
    printf 'chezmoi verify failed — check template errors or missing 1Password items\n' >&2
    exit 1
  }
else
  skip_step "chezmoi initialization" "chezmoi is not available"
fi
