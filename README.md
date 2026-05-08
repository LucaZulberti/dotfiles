# All my Dotfiles

[Chezmoi](https://www.chezmoi.io/)-based dotfiles repository.

## Setup

Packages dependencies should be installed with [Brew](https://brew.sh/).

### Automatic setup

Use setup script to install everything:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/LucaZulberti/dotfiles/HEAD/setup.sh)"
```

### Manual setup

Install Brew with:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install required packages with:

```sh
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
```

## Post-setup

Install Rust:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install Yazi packages:

```sh
ya pkg install
```

Optionally, install all LSPs:

```sh
brew install \
  bash-language-server \
  clang-format \
  fish-lsp \
  llvm \
  marksman \
  ruff \
  tombi

cargo install vhdl_ls

git clone --depth 1 --filter=blob:none --sparse "https://github.com/VHDL-LS/rust_hdl.git" .repo.git
cd .repo.git
git sparse-checkout set "vhdl_libraries"
mv vhdl_libraries ~/.cargo
cd ../ && rm -rf .repo.git
```


