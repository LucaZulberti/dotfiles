function zj
    set -l sessions (zellij list-sessions 2>/dev/null)
    set -l new_entry "New session"

    set -l selection (
        begin
            printf '%s\n' "$new_entry"
            printf '%s\n' $sessions
        end | sk -1 --ansi
    )

    if test -z "$selection"
        return 1
    end

    if test "$selection" = "$new_entry"
        if set -q ZELLIJ
            read -P "Session name: " session

            if test -z "$session"
                return 1
            end

            zellij action switch-session "$session"
        else
            zellij
        end

        return $status
    end

    set -l session (
        printf '%s\n' "$selection" |
        string replace -r '\s*\[Created.*$' '' |
        string trim
    )

    if test -z "$session"
        return 1
    end

    if set -q ZELLIJ
        zellij action switch-session "$session"
    else
        zellij attach "$session"
    end
end
