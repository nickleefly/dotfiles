if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi

export HISTSIZE=10000
export HISTFILESIZE=1000000000
export HISTCONTROL=ignoreboth:erasedups
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# Sync shared resources once for profile dirs
_claude_init_profile() {
    local target_dir="$1"
    # Skip if already initialized (check for plugins symlink)
    [ -L "$target_dir/plugins" ] && return 0

    mkdir -p "$target_dir"

    # List of things to sync from the main ~/.claude
    # Note: settings.json, keybindings.json, CLAUDE.md, and history should be per-instance
    local items=("plugins" "agents" "mcp" "skills" "rules" "RTK.md")

    for item in "${items[@]}"; do
        if [ -e "$HOME/.claude/$item" ]; then
            ln -sfn "$HOME/.claude/$item" "$target_dir/$item"
        fi
    done
}

# Enhanced Claude Profile Switcher
claude() {
    # If first arg is a flag (starts with -), passthrough directly
    [[ "$1" == -* ]] && { command claude "$@"; return; }

    local profile="${1:-default}" # Default to 'default' if no argument

    # Map friendly names to directories
    case "$profile" in
        internal|in)
            export CLAUDE_CONFIG_DIR="$HOME/.claude-internal"
            _claude_init_profile "$CLAUDE_CONFIG_DIR"
            ;;
        official|off)
            export CLAUDE_CONFIG_DIR="$HOME/.claude-official"
            _claude_init_profile "$CLAUDE_CONFIG_DIR"
            ;;
        *)
            export CLAUDE_CONFIG_DIR="$HOME/.claude"
            ;;
    esac

    echo "Using Claude Profile: $profile ($CLAUDE_CONFIG_DIR)"
    command claude "${@:2}" # Pass all remaining arguments to the real claude command
}
