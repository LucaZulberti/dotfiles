function tail --wraps=tail --description 'tail piped through bat'
    set -l file $argv[-1]

    if test -f "$file"
        command tail $argv | bat -pp --file-name "$file"
    else
        command tail $argv | bat -pp
    end

    return $pipestatus[1]
end
