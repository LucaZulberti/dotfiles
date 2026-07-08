# Final PATH normalization and priority.

set -l priority_paths

for p in "$HOME/.cargo/bin" "$HOME/.local/bin"
    if test -d "$p"
        set -a priority_paths "$p"
    end
end

set -l clean_path

for p in $PATH
    if not contains -- "$p" $priority_paths
        if not contains -- "$p" $clean_path
            set -a clean_path "$p"
        end
    end
end

set -gx PATH $priority_paths $clean_path
