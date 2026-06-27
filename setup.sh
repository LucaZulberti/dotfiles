#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Helpers
# -----------------------------

command_exists() {
  command -v "$1" >/dev/null 2>&1
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
    echo "error: Homebrew installed but brew binary not found" >&2
    exit 1
  fi

  eval "$("$brew_bin" shellenv)"
}

init_cargo() {
  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
  fi
}

# -----------------------------
# Install Homebrew
# -----------------------------

if ! command_exists brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Required on first installation
init_homebrew

# -----------------------------
# Install Brew packages
# -----------------------------

brew install \
  1password-cli \
  bash-language-server \
  bat \
  bottom \
  broot \
  chezmoi \
  clang-format \
  commitlint \
  doxygen \
  efm-langserver \
  eza \
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
  nvim \
  parallel \
  ripgrep \
  ruff \
  scooter \
  sesh \
  shfmt \
  sk \
  television \
  tmux gitmux \
  tombi \
  tree-sitter-cli \
  uv \
  vips \
  yaml-language-server \
  yazi ffmpeg-full sevenzip jq poppler resvg imagemagick-full font-symbols-only-nerd-font \
  zoxide

# -----------------------------
# Install Node.js
# -----------------------------

# Required before using fnm/npm in the current script
eval "$(fnm env --shell bash)"

fnm install --lts
fnm use lts-latest
fnm default lts-latest

# Refresh shell command lookup
hash -r

# -----------------------------
# Install npm-based tooling
# -----------------------------

npm install -g \
  devmoji \
  prettier \
  typescript-language-server \
  @angular/language-server \
  vscode-langservers-extracted

# -----------------------------
# Install Yazi packages
# -----------------------------

ya pkg install

# -----------------------------
# Install Rust
# -----------------------------

init_cargo

if ! command_exists rustup; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# Required on first installation
init_cargo

# -----------------------------
# Install Cargo binstall extension
# -----------------------------

if ! command_exists cargo-binstall; then
  curl -L --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh |
    bash

  # cargo-binstall may have just been installed
  init_cargo
fi

# -----------------------------
# Install Rust-based tooling
# -----------------------------

cargo binstall zellij
cargo install vhdl_ls

# Track every temp dir in one trap so a later mktemp does not orphan an earlier
# one (the trap body re-reads the array on exit).
tmpdirs=()
cleanup_tmpdirs() {
  for d in "${tmpdirs[@]}"; do
    rm -rf "$d"
  done
}
trap cleanup_tmpdirs EXIT

rust_tmp="$(mktemp -d)"
tmpdirs+=("$rust_tmp")

git clone --depth 1 --filter=blob:none --sparse \
  "https://github.com/VHDL-LS/rust_hdl.git" \
  "$rust_tmp/rust_hdl"

git -C "$rust_tmp/rust_hdl" sparse-checkout set "vhdl_libraries"

rm -rf "$HOME/.cargo/vhdl_libraries"
mv "$rust_tmp/rust_hdl/vhdl_libraries" "$HOME/.cargo/vhdl_libraries"

# -----------------------------
# Install Python with Miniconda
# -----------------------------

case "$(uname -s)" in
Darwin)
  arch="$(uname -m)"
  case "$arch" in
  arm64)
    installer="Miniconda3-latest-MacOSX-arm64.sh"
    ;;
  x86_64)
    installer="Miniconda3-latest-MacOSX-x86_64.sh"
    ;;
  *)
    echo "error: unsupported macOS architecture: $arch" >&2
    exit 1
    ;;
  esac
  ;;
Linux)
  arch="$(uname -m)"
  case "$arch" in
  x86_64)
    installer="Miniconda3-latest-Linux-x86_64.sh"
    ;;
  aarch64)
    installer="Miniconda3-latest-Linux-aarch64.sh"
    ;;
  *)
    echo "error: unsupported Linux architecture: $arch" >&2
    exit 1
    ;;
  esac
  ;;
*)
  echo "error: unsupported OS: $(uname -s)" >&2
  exit 1
  ;;
esac

if [ ! -x "$HOME/miniconda3/bin/conda" ]; then
  conda_tmp="$(mktemp -d)"
  tmpdirs+=("$conda_tmp")

  curl -fsSLo "$conda_tmp/$installer" "https://repo.anaconda.com/miniconda/$installer"
  bash "$conda_tmp/$installer" -b -p "$HOME/miniconda3"
fi

# Activate conda so subsequent pip installs target Miniconda, not system Python
eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
conda activate base

# -----------------------------
# Install Python-based tooling
# -----------------------------

uv tool install emoji-fzf
uv tool install "vsg @ git+https://github.com/lzulberti/vhdl-style-guide.git@3.35.0+multiblock"

# -----------------------------
# Initialize or update chezmoi dotfiles
# -----------------------------

if chezmoi status >/dev/null 2>&1; then
  echo "chezmoi is already initialized, running update..."
  chezmoi update
else
  echo "chezmoi is not initialized, running init..."
  chezmoi init LucaZulberti
fi

echo "Verifying chezmoi managed files..."
chezmoi verify || {
  echo "chezmoi verify failed — check template errors or missing 1Password items" >&2
  exit 1
}
