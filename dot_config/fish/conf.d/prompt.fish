# Check if inside a tmux session
if set -q TMUX || set -q ZELLIJ
    # Inside multiplexer add a custom indicator and overwrite fish prompts

    function fish_prompt --description 'Write out the prompt (overriden)'
        set -l last_pipestatus $pipestatus
        set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
        set -l normal (set_color normal)
        set -q fish_color_status
        or set -g fish_color_status red

        # Write pipestatus
        # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
        set -l bold_flag --bold
        set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
        if test $__fish_prompt_status_generation = $status_generation
            set bold_flag
        end
        set __fish_prompt_status_generation $status_generation
        set -l status_color (set_color $fish_color_status)
        set -l statusb_color (set_color $bold_flag $fish_color_status)
        set -l prompt_status (__fish_print_pipestatus "[" "] " "|" "$status_color" "$statusb_color" $last_pipestatus)

        echo -n -s (prompt_login) ' ' $normal $prompt_status "⚡"
    end

    if functions -q fish_right_prompt
        if not functions -q __fish_right_prompt_orig_custom
            functions -c fish_right_prompt __fish_right_prompt_orig_custom
        end
        functions -e fish_right_prompt
    else
        function __fish_right_prompt_orig_custom
        end
    end

    function fish_right_prompt --description 'Write out the rigth prompt (overriden)'
        fish_vcs_prompt && echo -n ' '
        __fish_right_prompt_orig_custom
    end
end
