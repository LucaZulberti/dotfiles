function tmuxs --description "Fuzzy-pick and load a tmuxp workspace, or create a new tmux session"
    # Resolve config directory: honour $TMUXP_CONFIGDIR, fall back to XDG default
    set --local cfg_dir (test -n "$TMUXP_CONFIGDIR"; and echo $TMUXP_CONFIGDIR; or echo ~/.config/tmuxp)

    # Collect workspace names from *.yml files, stripping path and extension
    set --local sessions (
        string replace '.yml' '' \
            (path basename $cfg_dir/*.yml 2>/dev/null)
    )
    set --append sessions "<new>"

    # ── fzf UI ────────────────────────────────────────────────────────────────
    set --local title "Select Tmux session to load, or start a <new> one"
    set --local ptitle "Workspace YAML file"

    # Preview: show bat-highlighted YAML for existing workspaces, placeholder for <new>
    set --local preview "if test {} = '<new>'; echo 'New session...'; else cat --style=plain --color=always $cfg_dir/{}.yml; end"

    # Modal vi-style bindings (two modes):
    #   Normal mode  → j/k navigate list, h/l/e/b move cursor in query,
    #                  s jump, p toggle preview, d clear query,
    #                  D/U scroll preview half-page down/up
    #   i/a/A/I      → enter search mode (mirrors vim insert entry points)
    #   Esc          → return to normal mode
    set --local selected (
        string join \n $sessions | fzf -i +s --tac \
            --border=rounded \
            --border-label="╢ $title ╟" --border-label-pos=0:bottom \
            --margin=5 --padding=0 \
            --preview="$preview" \
            --preview-label="╢ $ptitle ╟" --preview-label-pos=0:top \
            --bind="j:down,k:up,s:jump,p:toggle-preview" \
            --bind="h:backward-char,l:forward-char,e:forward-word,b:backward-word" \
            --bind="d:clear-query" \
            --bind="D:preview-half-page-down,U:preview-half-page-up" \
            --bind="start:enable-search+unbind(e,s,p,h,l,é,b,d,y,E,U,c,x,X,i,a,A,I)" \
            --bind="i:enable-search+unbind(j,k,s,p,h,l,e,b,d,y,E,U,c,x,X,i,a,A,I)" \
            --bind="a:enable-search+unbind(j,k,s,p,h,l,e,b,d,y,E,U,c,x,X,i,a,A,I)+forward-char" \
            --bind="A:enable-search+unbind(j,k,s,p,h,l,e,b,d,y,E,U,c,x,X,i,a,A,I)+end-of-line" \
            --bind="I:enable-search+unbind(j,k,s,p,h,l,e,b,d,y,E,U,c,x,X,i,a,A,I)+beginning-of-line" \
            --bind="esc:disable-search+rebind(j,k,s,p,h,l,e,b,d,y,E,U,c,x,X,i,a,A,I)"
    )

    # Bail out silently on Esc / Ctrl-C
    test -z "$selected"; and return 0

    # ── Dispatch ──────────────────────────────────────────────────────────────
    if test "$selected" = "<new>"
        # Name the session after the current directory; -A attaches if it already exists
        tmux new-session -A -s (basename (pwd)) -t Main
    else
        tmuxp load "$selected"
    end
end
