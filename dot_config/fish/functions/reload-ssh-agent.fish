function reload-ssh-agent --description "Reload SSH agent socket for SSH/zellij/tmux"
    set -l candidates

    # Current value, only if it is a real socket.
    if set -q SSH_AUTH_SOCK; and test -S "$SSH_AUTH_SOCK" 2>/dev/null
        set -a candidates "$SSH_AUTH_SOCK"
    end

    # Forwarded SSH agent sockets from active SSH logins.
    for sock in /tmp/ssh-*/agent.*
        if test -S "$sock" 2>/dev/null
            if not contains -- "$sock" $candidates
                set -a candidates "$sock"
            end
        end
    end

    for sock in $candidates
        env SSH_AUTH_SOCK="$sock" ssh-add -l >/dev/null 2>&1
        set -l rc $status

        # ssh-add:
        #   0 = agent reachable and has identities
        #   1 = agent reachable but has no identities
        #   2 = cannot contact agent
        if test $rc -lt 2
            set -gx SSH_AUTH_SOCK "$sock"
            echo "SSH_AUTH_SOCK set to: $SSH_AUTH_SOCK"
            return 0
        end
    end

    echo "No usable SSH agent socket found"
    return 1
end
