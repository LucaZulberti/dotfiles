if status --is-interactive
    # Set time zone
    if not set -q TZ
        set -l zone (readlink -f /etc/localtime | sed 's|.*/zoneinfo/||')
        if test -n "$zone"
            set -gx TZ "$zone"
        end
    end
end
