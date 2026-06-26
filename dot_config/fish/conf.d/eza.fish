if type -q eza
    alias ls="eza --icons"
    alias l="ls -1"
    alias la="ls -a"
    alias ll="ls -lga"
    alias lr="ls -lgaR"
    alias lt="ls -lgaT"
    alias lm="ls -lga -s modified -r"
    alias lf="ls -f"
    alias lfl="ls -lgf"
    alias ld="ls -D"
    alias ldl="ls -lgD"
    alias lg="ls -lga --git"

    function tree
        lt $argv
    end

    set -gx EZA_CONFIG_DIR ~/.config/eza
end
