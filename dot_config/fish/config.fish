if status --is-interactive
    if type -q zellij
        set ZELLIJ_AUTO_ATTACH true
        set ZELLIJ_AUTO_EXIT false

        if not set -q ZELLIJ
            set -l session (
                zellij list-sessions 2>/dev/null |
                sk -0 -1 --ansi |
                string replace -r '\[Created.*' '' |
                string trim
            )

            if test -n "$session" && test "$ZELLIJ_AUTO_ATTACH" = true
                zellij attach "$session"
            else
                zellij
            end

            if test "$ZELLIJ_AUTO_EXIT" = true
                kill $fish_pid
            end
        end
    end

    # Set time zone
    if not set -q TZ
        set -l zone (readlink -f /etc/localtime | sed 's|.*/zoneinfo/||')
        if test -n "$zone"
            set -gx TZ "$zone"
        end
    end
end
