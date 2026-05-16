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

# Enhanced Claude - resume latest session (uses default settings.json)
claude() {
    local config_dir="$HOME/.claude"
    local resume_args=()

    # Find most recent session to resume
    local sessions_dir="$config_dir/sessions"
    if [[ -d "$sessions_dir" ]]; then
        local latest_session=$(find "$sessions_dir" -maxdepth 1 -type d -name "sess_*" ! -name "*-backup" -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
        if [[ -n "$latest_session" ]]; then
            local session_id=$(basename "$latest_session")
            resume_args=(--resume "$session_id")
        fi
    fi

    [[ ${#resume_args[@]} -gt 0 ]] && echo "Resuming: ${resume_args[1]}"
    command claude "${resume_args[@]}" "$@"
}

# Claude Model Switcher
ccg() { ~/.claude/claude-with-model.sh glm; }
cco() { ~/.claude/claude-with-model.sh official; }
cll() { ~/.claude/claude-with-model.sh llama-local; }
clc() { ~/.claude/claude-with-model.sh llama-cesarsal1nas; }
clu() { ~/.claude/claude-with-model.sh llama-unsloth-qwen; }
col() { ~/.claude/claude-with-model.sh ollama; }
cor() { ~/.claude/claude-with-model.sh openrouter; }
