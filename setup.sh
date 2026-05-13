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
  television \
  tmux tmuxp gitmux \
  tree-sitter-cli \
  yazi ffmpeg-full sevenzip jq poppler resvg imagemagick-full font-symbols-only-nerd-font \
  zoxide

# Install Node.js
fnm i --lts --use

# Install yarn packages
ya pkg install

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Python with Miniconda
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda3"
rm ./Miniconda3-latest-Linux-x86_64.sh

# Install LSPs from Homebrew
brew install \
  bash-language-server \
  clang-format \
  fish-lsp \
  marksman \
  ruff \
  tombi

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
pip install --upgrade --force-reinstall \                                                                                                     (base) │ NOR   setup.sh [+]                                                                                                                     1 sel  73:1  bash
  "vsg @ git+https://github.com/lzulberti/vhdl-style-guide.git@3.35.0+multiblock"
