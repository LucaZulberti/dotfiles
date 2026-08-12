# reload-ssh-agent.sh - restore a working SSH_AUTH_SOCK in restored tmux/zellij sessions.
#
# Bash counterpart of dot_config/fish/functions/reload-ssh-agent.fish, for the rare cases this
# user runs bash directly instead of fish (dot_bashrc execs into fish for interactive shells, so
# this normally only matters for non-interactive or non-tty bash). Keep the two in sync when
# changing the selection logic.
#
# Sourced automatically by dot_bashrc via ~/.bashrc.d/*. Usage:
#
#   reload-ssh-agent

__remove_stale_ssh_agent_socket() {
    local sock=$1

    # Never remove arbitrary SSH_AUTH_SOCK paths.
    [[ $sock =~ ^/tmp/ssh-[^/]+/agent\.[0-9]+$ ]] || return 1

    # Only remove files and directories owned by the current user.
    [[ -O $sock ]] || return 1

    local socket_dir
    socket_dir=$(dirname -- "$sock")

    [[ -O $socket_dir ]] || return 1

    command rm -f -- "$sock" || return 1

    # Remove the OpenSSH temporary directory only when it is empty.
    command rmdir -- "$socket_dir" 2>/dev/null

    echo "Removed stale SSH agent socket: $sock" >&2
    return 0
}

reload-ssh-agent() {
    local -a candidates=()
    local -a empty_agents=()
    local sock

    # Check the currently configured socket first.
    if [[ -n $SSH_AUTH_SOCK ]]; then
        if [[ -S $SSH_AUTH_SOCK ]]; then
            candidates+=("$SSH_AUTH_SOCK")
        else
            __remove_stale_ssh_agent_socket "$SSH_AUTH_SOCK"
        fi
    fi

    # Find forwarded SSH agent sockets.
    for sock in /tmp/ssh-*/agent.*; do
        # Skip a literal, non-matching glob when nothing under /tmp matches it.
        [[ -e $sock ]] || continue

        if [[ -S $sock ]]; then
            local already=0 c
            for c in "${candidates[@]:-}"; do
                [[ $c == "$sock" ]] && already=1 && break
            done
            [[ $already -eq 1 ]] || candidates+=("$sock")
        else
            # Clean up unexpected stale files matching the agent pattern.
            __remove_stale_ssh_agent_socket "$sock"
        fi
    done

    for sock in "${candidates[@]:-}"; do
        [[ -n $sock ]] || continue

        local public_keys_file
        public_keys_file=$(mktemp) || continue

        local rc
        if command -v timeout >/dev/null 2>&1; then
            SSH_AUTH_SOCK="$sock" timeout 2s ssh-add -L >"$public_keys_file" 2>/dev/null
        else
            SSH_AUTH_SOCK="$sock" ssh-add -L >"$public_keys_file" 2>/dev/null
        fi
        rc=$?

        case $rc in
        0)
            # Ensure the agent returned parseable public keys.
            if ssh-keygen -lf "$public_keys_file" >/dev/null 2>&1; then
                command rm -f -- "$public_keys_file"

                export SSH_AUTH_SOCK="$sock"
                echo "SSH_AUTH_SOCK set to: $SSH_AUTH_SOCK"
                return 0
            fi

            echo "SSH agent returned invalid public-key data: $sock" >&2
            __remove_stale_ssh_agent_socket "$sock"
            ;;
        1)
            # Reachable agent without identities: retain as fallback.
            empty_agents+=("$sock")
            ;;
        2 | 124)
            # 2: ssh-add cannot contact the agent.
            # 124: timeout expired.
            __remove_stale_ssh_agent_socket "$sock"
            ;;
        *)
            echo "SSH agent probe failed with status $rc: $sock" >&2
            ;;
        esac

        command rm -f -- "$public_keys_file"
    done

    # Use a reachable empty agent only when no populated agent was found.
    if [[ ${#empty_agents[@]} -gt 0 ]]; then
        export SSH_AUTH_SOCK="${empty_agents[0]}"
        echo "SSH_AUTH_SOCK set to empty agent: $SSH_AUTH_SOCK"
        return 0
    fi

    unset SSH_AUTH_SOCK
    echo "No usable SSH agent socket found" >&2
    return 1
}
