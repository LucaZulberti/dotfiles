# Keep updated with latest Brew image
FROM lucazulberti/brew:latest

# Install needed system packages
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        libclang-dev \
        pkg-config \
        openssh-client \
        rsync \
        wget \
        direnv \
        man-db \
        manpages \
        vim \
        subversion \
        git-lfs \
        doxygen \
        libreadline-dev \
        libssl-dev \
        yarn && \
    sudo apt-get autoremove --purge -y && \
    sudo rm -rf /var/lib/apt/lists/*

# Install base brew packages (matches setup.sh)
RUN brew install \
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
    gitmux \
    golang \
    helix \
    lazygit \
    nvim \
    ripgrep \
    scooter \
    sesh \
    sk \
    television \
    tmux tmuxp \
    tree-sitter-cli \
    yazi \
    zoxide

# Install language servers / formatters (matches setup.sh)
RUN brew install \
    bash-language-server \
    clang-format \
    fish-lsp \
    marksman \
    ruff \
    shfmt \
    tombi \
    yaml-language-server

# Fix linuxbrew user home permissions
RUN sudo chmod o+rx /home/linuxbrew
