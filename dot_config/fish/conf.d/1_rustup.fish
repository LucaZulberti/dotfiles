if test -d $HOME/.cargo
    source "$HOME/.cargo/env.fish"

    if status is-interactive
        set -l stamp ~/.cache/rustup-last-check
        mkdir -p ~/.cache

        set -l today (date +%F)

        if not test -f $stamp; or test (cat $stamp) != $today
            echo $today >$stamp

            set -l output (rustup check 2>/dev/null)

            if string match -qr "Update available" -- $output
                echo
                set_color yellow
                echo "⚠ Rust toolchain update available"
                set_color normal
                echo $output
                echo
                echo "Run: rustup update"
            end
        end
    end
end
