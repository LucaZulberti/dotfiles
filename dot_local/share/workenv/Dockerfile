# Keep updated with latest Brew image
FROM lucazulberti/brew:latest

# Install needed packages
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends software-properties-common && \
    sudo add-apt-repository -y ppa:fish-shell/release-4 && \
    sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        libclang-dev \
        pkg-config \
        openssh-client \
        fish \
        rsync \
        tmux \
        wget \
        fzf \
        ripgrep \
        zoxide \
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
    sudo apt-get remove --purge -y software-properties-common && \
    sudo apt-get autoremove --purge -y  && \
    sudo rm -rf /var/lib/apt/lists/*

# Install brew packages
RUN brew install \
    bat \
    chezmoi \
    eza \
    fd \
    fnm \
    gitmux \
    helix \
    lazygit \
    nvim \
    sesh \
    television \
    tmuxp \
    tree-sitter-cli

# Fix linuxbrew user home permissions
RUN sudo chmod o+rx /home/linuxbrew
