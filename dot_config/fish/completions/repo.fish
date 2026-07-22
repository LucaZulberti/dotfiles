function __fish_repo_current_command
    set -l tokens (commandline -opc)
    set -e tokens[1]

    for token in $tokens
        switch $token
            case '-*'
                continue
            case '*'
                echo $token
                return 0
        end
    end

    return 1
end

function __fish_repo_subcommand_options
    set -l subcommand (__fish_repo_current_command)

    test -n "$subcommand"
    or return 1

    command repo --no-pager --color=never "$subcommand" -h 2>/dev/null |
        awk '
            function trim(value) {
                sub(/^[[:space:]]+/, "", value)
                sub(/[[:space:]]+$/, "", value)
                return value
            }

            function emit(specification, description, alternative_count, i, part, candidate) {
                if (specification == "")
                    return

                description = trim(description)
                gsub(/[[:space:]]+/, " ", description)

                alternative_count = split(specification, alternatives, /,[[:space:]]*/)

                for (i = 1; i <= alternative_count; i++) {
                    part = trim(alternatives[i])

                    if (part !~ /^-/)
                        continue

                    candidate = part

                    if (candidate ~ /^--[^[:space:]=]+=/)
                        sub(/=.*/, "=", candidate)
                    else
                        sub(/[[:space:]].*$/, "", candidate)

                    if (description != "")
                        printf "%s\t%s\n", candidate, description
                    else
                        print candidate
                }
            }

            function flush() {
                emit(pending_specification, pending_description)
                pending_specification = ""
                pending_description = ""
                pending_indent = -1
            }

            {
                match($0, /^[[:space:]]*/)
                indent = RLENGTH
                content = substr($0, indent + 1)

                if (content == "") {
                    flush()
                    next
                }

                if (pending_specification != "" && indent > pending_indent) {
                    continuation = trim(content)

                    if (continuation != "") {
                        if (pending_description != "")
                            pending_description = pending_description " " continuation
                        else
                            pending_description = continuation
                    }

                    next
                }

                if (content ~ /^-/) {
                    flush()

                    if (match(content, /[[:space:]][[:space:]]+/)) {
                        pending_specification = substr(content, 1, RSTART - 1)
                        pending_description = substr(content, RSTART + RLENGTH)
                    } else {
                        pending_specification = content
                    }

                    pending_indent = indent
                    next
                }

                flush()
            }

            END {
                flush()
            }
        '
end

complete -c repo -n __fish_repo_current_command -a "(__fish_repo_subcommand_options)"
