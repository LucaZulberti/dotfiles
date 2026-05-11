# Fish completions for Claude Code CLI
# Generated from `claude --help`

function __fish_claude_seen_command
    set -l tokens (commandline -opc)
    set -e tokens[1]

    for token in $tokens
        switch $token
            case agents auth auto-mode doctor install mcp plugin plugins project setup-token ultrareview update upgrade
                return 0
        end
    end

    return 1
end

function __fish_claude_using_command
    set -l tokens (commandline -opc)
    set -e tokens[1]
    contains -- $argv[1] $tokens
end

function __fish_claude_complete_setting_sources
    printf "%s\n" user project local
end

function __fish_claude_complete_effort
    printf "%s\n" low medium high xhigh max
end

function __fish_claude_complete_input_format
    printf "%s\n" text stream-json
end

function __fish_claude_complete_output_format
    printf "%s\n" text json stream-json
end

function __fish_claude_complete_permission_mode
    printf "%s\n" acceptEdits auto bypassPermissions default dontAsk plan
end

# Commands
complete -c claude -f -n "not __fish_claude_seen_command" -a agents -d "Manage background and configured agents"
complete -c claude -f -n "not __fish_claude_seen_command" -a auth -d "Manage authentication"
complete -c claude -f -n "not __fish_claude_seen_command" -a auto-mode -d "Inspect auto mode classifier configuration"
complete -c claude -f -n "not __fish_claude_seen_command" -a doctor -d "Check Claude Code auto-updater health"
complete -c claude -f -n "not __fish_claude_seen_command" -a install -d "Install Claude Code native build"
complete -c claude -f -n "not __fish_claude_seen_command" -a mcp -d "Configure and manage MCP servers"
complete -c claude -f -n "not __fish_claude_seen_command" -a plugin -d "Manage Claude Code plugins"
complete -c claude -f -n "not __fish_claude_seen_command" -a plugins -d "Manage Claude Code plugins"
complete -c claude -f -n "not __fish_claude_seen_command" -a project -d "Manage Claude Code project state"
complete -c claude -f -n "not __fish_claude_seen_command" -a setup-token -d "Set up a long-lived authentication token"
complete -c claude -f -n "not __fish_claude_seen_command" -a ultrareview -d "Run cloud-hosted multi-agent code review"
complete -c claude -f -n "not __fish_claude_seen_command" -a update -d "Check for updates and install if available"
complete -c claude -f -n "not __fish_claude_seen_command" -a upgrade -d "Check for updates and install if available"

# install targets
complete -c claude -f -n "__fish_claude_using_command install" -a stable -d "Install stable version"
complete -c claude -f -n "__fish_claude_using_command install" -a latest -d "Install latest version"

# Global options
complete -c claude -l add-dir -r -a "(__fish_complete_directories)" -d "Additional directories to allow tool access"
complete -c claude -l agent -r -d "Agent for the current session"
complete -c claude -l agents -r -d "JSON object defining custom agents"
complete -c claude -l allow-dangerously-skip-permissions -d "Enable permission bypass option"
complete -c claude -l allowedTools -r -d "Allowed tool names"
complete -c claude -l allowed-tools -r -d "Allowed tool names"
complete -c claude -l append-system-prompt -r -d "Append a system prompt"
complete -c claude -l bare -d "Minimal mode"
complete -c claude -l betas -r -d "Beta headers to include in API requests"
complete -c claude -l brief -d "Enable SendUserMessage tool"
complete -c claude -l chrome -d "Enable Claude in Chrome integration"

complete -c claude -s c -l continue -d "Continue most recent conversation in current directory"
complete -c claude -l dangerously-skip-permissions -d "Bypass all permission checks"
complete -c claude -s d -l debug -r -d "Enable debug mode with optional filter"
complete -c claude -l debug-file -r -a "(__fish_complete_path)" -d "Write debug logs to file"
complete -c claude -l disable-slash-commands -d "Disable all skills"
complete -c claude -l disallowedTools -r -d "Denied tool names"
complete -c claude -l disallowed-tools -r -d "Denied tool names"
complete -c claude -l effort -r -f -a "(__fish_claude_complete_effort)" -d "Effort level"
complete -c claude -l exclude-dynamic-system-prompt-sections -d "Move per-machine sections out of system prompt"
complete -c claude -l fallback-model -r -d "Fallback model for overloaded default model"
complete -c claude -l file -r -d "File resource spec: file_id:relative_path"
complete -c claude -l fork-session -d "Create new session ID when resuming"
complete -c claude -l from-pr -r -d "Resume session linked to PR"

complete -c claude -s h -l help -d "Display help"
complete -c claude -l ide -d "Automatically connect to IDE"
complete -c claude -l include-hook-events -d "Include hook lifecycle events in stream-json"
complete -c claude -l include-partial-messages -d "Include partial message chunks"
complete -c claude -l input-format -r -f -a "(__fish_claude_complete_input_format)" -d "Input format"
complete -c claude -l json-schema -r -d "JSON Schema for structured output validation"
complete -c claude -l max-budget-usd -r -d "Maximum API spend in USD"
complete -c claude -l mcp-config -r -a "(__fish_complete_path)" -d "Load MCP servers from JSON files or strings"
complete -c claude -l mcp-debug -d "Deprecated: enable MCP debug mode"
complete -c claude -l model -r -d "Model alias or full model name"

complete -c claude -s n -l name -r -d "Set display name for session"
complete -c claude -l no-chrome -d "Disable Claude in Chrome integration"
complete -c claude -l no-session-persistence -d "Disable session persistence"
complete -c claude -l output-format -r -f -a "(__fish_claude_complete_output_format)" -d "Output format"
complete -c claude -l permission-mode -r -f -a "(__fish_claude_complete_permission_mode)" -d "Permission mode"
complete -c claude -l plugin-dir -r -a "(__fish_complete_path)" -d "Load plugin directory or .zip"
complete -c claude -l plugin-url -r -d "Fetch plugin .zip from URL"

complete -c claude -s p -l print -d "Print response and exit"
complete -c claude -l remote-control -r -d "Start session with Remote Control enabled"
complete -c claude -l remote-control-session-name-prefix -r -d "Remote Control session name prefix"
complete -c claude -l replay-user-messages -d "Re-emit stdin user messages to stdout"
complete -c claude -s r -l resume -r -d "Resume conversation by session ID or search term"
complete -c claude -l session-id -r -d "Use specific session UUID"
complete -c claude -l setting-sources -r -f -a "(__fish_claude_complete_setting_sources)" -d "Setting sources to load"
complete -c claude -l settings -r -a "(__fish_complete_path)" -d "Settings JSON file or JSON string"
complete -c claude -l strict-mcp-config -d "Only use MCP servers from --mcp-config"
complete -c claude -l system-prompt -r -d "System prompt for the session"
complete -c claude -l tmux -r -d "Create tmux session for worktree"
complete -c claude -l tools -r -d "Available built-in tools"
complete -c claude -l verbose -d "Override verbose mode setting"

complete -c claude -s v -l version -d "Output version number"
complete -c claude -s w -l worktree -r -d "Create new git worktree for session"
