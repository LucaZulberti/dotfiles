if status --is-interactive
    # Set time zone
    if not set -q TZ
        set -l zone (readlink -f /etc/localtime | sed 's|.*/zoneinfo/||')
        if test -n "$zone"
            set -gx TZ "$zone"
        end
    end

    set -l token_file "$HOME/.local/share/1password/token"

    # Prompt only once, only in an interactive login shell.
    if status --is-login; and not test -s "$token_file"
        mkdir -p (dirname "$token_file")
        chmod 700 (dirname "$token_file")

        read --prompt-str "Enter 1Password Service Account token: " --silent --local token

        if test -n "$token"
            set -l old_umask (umask)
            umask 077
            printf '%s\n' "$token" >"$token_file"
            umask "$old_umask"

            chmod 600 "$token_file"
        end
    end

    # Export token for child processes.
    if test -s "$token_file"
        set -gx OP_SERVICE_ACCOUNT_TOKEN (string trim --right -- (string collect < "$token_file"))
    end
end
