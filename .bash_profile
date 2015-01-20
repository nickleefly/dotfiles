. ~/.profile
# {{{
# Node Completion - Auto-generated, do not touch.
shopt -s progcomp
for f in $(command ls ~/.node-completion); do
  f="$HOME/.node-completion/$f"
  test -f "$f" && . "$f"
done
# }}}

# The next line updates PATH for the Google Cloud SDK.
source /Users/nick/google-cloud-sdk/path.bash.inc

# The next line enables bash completion for gcloud.
source /Users/nick/google-cloud-sdk/completion.bash.inc
