#!/bin/zsh
set -eu

# Desktop launches may have a shorter PATH than Terminal.
export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin"

case "${1:-}" in
  ynab)
    budget_dir="$HOME/.config/household-budget"
    token_file="$budget_dir/ynab-token"
    if [[ ! -s "$token_file" ]]; then
      print -u2 "Auto Budget: run the YNAB setup step in README.md."
      exit 1
    fi
    if ! command -v npx >/dev/null; then
      print -u2 "Auto Budget: install Node.js 20 or newer, then restart Codex."
      exit 1
    fi
    export YNAB_API_TOKEN="$(<"$token_file")"
    export YNAB_ALLOW_WRITES=0
    if [[ -f "$budget_dir/ynab-writes-enabled" ]]; then
      export YNAB_ALLOW_WRITES=1
    fi
    exec npx --yes --package @oliverames/mcp-server-for-ynab@6.1.1 -- ynab-mcp-server
    ;;
  amazon-orders)
    if ! command -v uvx >/dev/null; then
      print -u2 "Auto Budget: install uv to use Amazon Orders, then restart Codex."
      exit 1
    fi
    exec uvx amazon-orders-mcp@2.4.0
    ;;
  *)
    print -u2 "Usage: run-connector.zsh ynab|amazon-orders"
    exit 2
    ;;
esac
