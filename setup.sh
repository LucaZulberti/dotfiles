#!/usr/bin/env bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install base packages
brew install \
  1password-cli \
  bat \
  bottom \
  broot \
  chezmoi \
  eza \
  fd \
  fish fisher \
  fnm \
  fzf \
  git git-delta git-filter-repo \
  golang \
  helix \
  lazygit \
  nvim \
  ripgrep \
  scooter \
  sesh \
  sk \
  television \
  tmux tmuxp gitmux \
  tree-sitter-cli \
  yazi ffmpeg-full sevenzip jq poppler resvg imagemagick-full font-symbols-only-nerd-font \
  zoxide

# Install Node.js
fnm i --lts --use

# Install Yazi packages
ya pkg install

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Cargo binstall extension
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install Python with Miniconda (OS-aware installer)
case "$(uname -s)" in
  Darwin)
    arch="$(uname -m)"
    if [ "$arch" = "arm64" ]; then
      installer="Miniconda3-latest-MacOSX-arm64.sh"
    else
      installer="Miniconda3-latest-MacOSX-x86_64.sh"
    fi
    ;;
  Linux)
    installer="Miniconda3-latest-Linux-x86_64.sh"
    ;;
esac
curl -O "https://repo.anaconda.com/miniconda/$installer"
bash "./$installer" -b -p "$HOME/miniconda3"
rm "./$installer"

# Activate conda so subsequent pip installs target the miniconda env, not system Python
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
conda activate base

# Install LSPs from Homebrew
brew install \
  bash-language-server \
  clang-format \
  fish-lsp \
  marksman \
  ruff \
  shfmt \
  tombi \
  yaml-language-server

# Install VHDL LSP from Rust Cargo
cargo install vhdl_ls
git clone --depth 1 --filter=blob:none --sparse "https://github.com/VHDL-LS/rust_hdl.git" .repo.git
cd .repo.git
git sparse-checkout set "vhdl_libraries"
mv vhdl_libraries ~/.cargo
cd ../ && rm -rf .repo.git

# Install CMake LSP using Python PIP
pip install cmakelang

# Install commitlint with Go
go install github.com/conventionalcommit/commitlint@latest

# Install EFM Language Server with Go
go install github.com/mattn/efm-langserver@latest

# Install VHDL Style Guide formatter from custom repo
pip install --upgrade --force-reinstall \
  "vsg @ git+https://github.com/lzulberti/vhdl-style-guide.git@3.35.0+multiblock"

# Install npm-based tooling (devmoji + helix-referenced LSPs/formatter)
npm install -g \
  devmoji \
  prettier \
  typescript-language-server \
  @angular/language-server \
  vscode-langservers-extracted

# Install Zellij with Cargo
cargo binstall zellij
