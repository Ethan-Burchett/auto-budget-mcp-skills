#!/bin/zsh
set -eu
umask 077

budget_dir="$HOME/.config/household-budget"
token_file="$budget_dir/ynab-token"
writes_file="$budget_dir/ynab-writes-enabled"

case "${1:-connect}" in
  connect)
    printf "Paste your own YNAB personal access token (input is hidden): " >&2
    IFS= read -rs ynab_token
    printf '\n' >&2
    if [[ -z "$ynab_token" || "$ynab_token" == *[[:space:]]* ]]; then
      print -u2 "Enter the token as one line without spaces."
      exit 1
    fi
    mkdir -p "$budget_dir"
    chmod 700 "$budget_dir"
    temp_token="$(mktemp "$budget_dir/.token.XXXXXX")"
    trap 'rm -f "$temp_token"' EXIT
    printf '%s\n' "$ynab_token" > "$temp_token"
    mv -f "$temp_token" "$token_file"
    rm -f "$writes_file"
    print "Token saved. YNAB is configured for read-only access. Restart Codex."
    ;;
  enable-writes)
    if [[ ! -s "$token_file" ]]; then
      print -u2 "Run the token setup first."
      exit 1
    fi
    touch "$writes_file"
    print "YNAB write tools enabled. Restart Codex."
    ;;
  disable-writes)
    rm -f "$writes_file"
    print "YNAB set to read-only. Restart Codex."
    ;;
  *)
    print -u2 "Usage: zsh setup-ynab.zsh [connect|enable-writes|disable-writes]"
    exit 2
    ;;
esac
