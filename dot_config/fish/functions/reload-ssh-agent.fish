function __remove_stale_ssh_agent_socket \
    --argument-names sock \
    --description "Remove a stale forwarded SSH agent socket"

    # Never remove arbitrary SSH_AUTH_SOCK paths.
    string match -qr '^/tmp/ssh-[^/]+/agent\.[0-9]+$' -- "$sock"
    or return 1

    # Only remove files and directories owned by the current user.
    test -O "$sock"
    or return 1

    set -l socket_dir (path dirname "$sock")

    test -O "$socket_dir"
    or return 1

    command rm -f -- "$sock"
    or return 1

    # Remove the OpenSSH temporary directory only when it is empty.
    command rmdir -- "$socket_dir" 2>/dev/null

    echo "Removed stale SSH agent socket: $sock" >&2
    return 0
end

function reload-ssh-agent \
    --description "Reload SSH agent socket for SSH/zellij/tmux"

    set -l candidates
    set -l empty_agents

    # Check the currently configured socket first.
    if set -q SSH_AUTH_SOCK
        if test -S "$SSH_AUTH_SOCK"
            set -a candidates "$SSH_AUTH_SOCK"
        else
            __remove_stale_ssh_agent_socket "$SSH_AUTH_SOCK"
        end
    end

    # Find forwarded SSH agent sockets.
    for sock in /tmp/ssh-*/agent.*
        if test -S "$sock"
            if not contains -- "$sock" $candidates
                set -a candidates "$sock"
            end
        else
            # Clean up unexpected stale files matching the agent pattern.
            __remove_stale_ssh_agent_socket "$sock"
        end
    end

    for sock in $candidates
        set -l public_keys_file (mktemp)
        or continue

        # Query complete public-key data rather than only fingerprints.
        if type -q timeout
            env SSH_AUTH_SOCK="$sock" \
                timeout 2s ssh-add -L >"$public_keys_file" 2>/dev/null
        else
            env SSH_AUTH_SOCK="$sock" \
                ssh-add -L >"$public_keys_file" 2>/dev/null
        end

        set -l rc $status

        switch $rc
            case 0
                # Ensure the agent returned parseable public keys.
                if ssh-keygen -lf "$public_keys_file" >/dev/null 2>&1
                    command rm -f -- "$public_keys_file"

                    set -gx SSH_AUTH_SOCK "$sock"
                    echo "SSH_AUTH_SOCK set to: $SSH_AUTH_SOCK"
                    return 0
                end

                echo "SSH agent returned invalid public-key data: $sock" >&2
                __remove_stale_ssh_agent_socket "$sock"

            case 1
                # Reachable agent without identities: retain as fallback.
                set -a empty_agents "$sock"

            case 2 124
                # 2: ssh-add cannot contact the agent.
                # 124: timeout expired.
                __remove_stale_ssh_agent_socket "$sock"

            case '*'
                echo "SSH agent probe failed with status $rc: $sock" >&2
        end

        command rm -f -- "$public_keys_file"
    end

    # Use a reachable empty agent only when no populated agent was found.
    if test (count $empty_agents) -gt 0
        set -gx SSH_AUTH_SOCK "$empty_agents[1]"
        echo "SSH_AUTH_SOCK set to empty agent: $SSH_AUTH_SOCK"
        return 0
    end

    set -e SSH_AUTH_SOCK
    echo "No usable SSH agent socket found" >&2
    return 1
end
