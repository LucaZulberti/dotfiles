if status --is-interactive
    # -----------------------------
    # Auto-start Zellij
    # -----------------------------

    if type -q zellij
        set -q ZELLIJ_AUTO_ATTACH; or set -gx ZELLIJ_AUTO_ATTACH true
        set -q ZELLIJ_AUTO_EXIT; or set -gx ZELLIJ_AUTO_EXIT false

        if not set -q ZELLIJ
            set -l zellij_started false

            if test "$ZELLIJ_AUTO_ATTACH" = true
                set -l sessions (zellij list-sessions 2>/dev/null)
                set -l new_entry "New session"

                if test -n "$sessions"
                    set -l selection (
                        begin
                            printf '%s\n' "$new_entry"
                            printf '%s\n' $sessions
                        end | sk -1 --ansi
                    )

                    if test -n "$selection"
                        if test "$selection" = "$new_entry"
                            zellij
                            set zellij_started true
                        else
                            set -l session (
                                printf '%s\n' "$selection" |
                                string replace -r '\s*\[Created.*$' '' |
                                string trim
                            )

                            if test -n "$session"
                                zellij attach "$session"
                                set zellij_started true
                            end
                        end
                    end
                else
                    zellij
                    set zellij_started true
                end
            else
                zellij
                set zellij_started true
            end

            if test "$zellij_started" = true
                and test "$ZELLIJ_AUTO_EXIT" = true
                kill $fish_pid
            end
        end
    end

    # -----------------------------
    # Set time zone
    # -----------------------------

    if not set -q TZ
        set -l zone (readlink -f /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||')

        if test -n "$zone"
            set -gx TZ "$zone"
        end
    end
end
