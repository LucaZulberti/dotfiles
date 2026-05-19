if type -q git
    alias gs="git status"
    alias gd="git diff"
    alias gp="git push"
    alias gP="git pull -p"
    alias gf="git fetch -p --all"
    alias gr="git rebase -i"
    if type -q devmoji
        alias gl="git l --all --color | devmoji --log --color"
    else
        alias gl="git l --all --color"
    end
end
