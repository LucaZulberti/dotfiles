function head --wraps=head --description 'head piped through bat'
    set -l file $argv[-1]

    if test -f "$file"
        command head $argv | bat -pp --file-name "$file"
    else
        command head $argv | bat -pp
    end

    return $pipestatus[1]
end
