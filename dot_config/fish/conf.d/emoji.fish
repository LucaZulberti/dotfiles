if type -q emoji-fzf
    alias emoji="emoji-fzf preview --prepend | fzf | gawk '{ print \$1 }'"
end
