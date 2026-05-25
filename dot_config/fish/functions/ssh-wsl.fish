function ssh-wsl
    if not set -q OP_SERVICE_ACCOUNT_TOKEN; or test -z "$OP_SERVICE_ACCOUNT_TOKEN"
        set -gx OP_SERVICE_ACCOUNT_TOKEN (op read 'op://IngeniArs/IngeniArs Read Token/credential')
    end

    set -l entry OP_SERVICE_ACCOUNT_TOKEN/w

    if set -q WSLENV
        set -l entries (string split : -- $WSLENV)

        if not contains -- $entry $entries
            set -gx WSLENV "$WSLENV:$entry"
        end
    else
        set -gx WSLENV $entry
    end

    /mnt/c/Windows/System32/OpenSSH/ssh.exe $argv
end
