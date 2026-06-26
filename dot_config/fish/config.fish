if status --is-interactive
    # -----------------------------
    # Terminal feature probing
    # -----------------------------

    # fish 4 queries the TTY at startup (kitty keyboard \e[?u, XTVERSION,
    # OSC 11 background, XTGETTCAP, DA1). zellij 0.44 misroutes those replies to
    # freshly spawned pane and nested shells, so the responses leak onto the
    # command line (garbage like "1e1d/2cfc", "…u", "…R"). Export the opt-out so
    # every child shell (zellij panes, `chezmoi cd`, …) skips the probing.
    #
    # Feature flags are locked before config.fish runs, so the current shell is
    # unaffected: a top-level shell launched directly by the terminal keeps the
    # probing (the terminal answers correctly there, no leak) while its children
    # inherit the opt-out.
    set -gx fish_features no-query-term

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
