# gitlab-token.sh - expose the IngeniArs GitLab CLI PAT to glab and other GitLab tooling.
#
# The token file is written by chezmoi at apply time from 1Password (see
# dot_config/glab-cli/private_token.tmpl). Sourced automatically by dot_bashrc via ~/.bashrc.d/*.

if [[ -r $HOME/.config/glab-cli/token ]]; then
  GITLAB_TOKEN=$(<"$HOME/.config/glab-cli/token")
  export GITLAB_TOKEN
  GITLAB_HOST="gitlab.ingeniars.com"
  export GITLAB_HOST
fi
