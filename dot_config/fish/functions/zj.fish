function zj
    set -l sessions (zellij list-sessions 2>/dev/null)
    if test -n "$sessions"
        set -l session (
            printf '%s\n' $sessions | sk -1 --ansi | string replace -r '\[Created.*' '' | string trim
        )
        zellij attach "$session"
    else
        zellij
    end

    if test "$ZELLIJ_AUTO_EXIT" = true
        kill $fish_pid
    end
end
