# Household Budget for Codex

Use a receipt photo or PDF to match a charge in **Joint Budget - Current**.
Codex proposes categories, item notes, and Sawyer's share, then asks you to
approve the exact change before saving it. The plugin also handles Amazon
purchases and helps review recent uncategorized transactions.

## First-time setup on a Mac

1. **Check the shared plan.** Sign in to YNAB with your own account and confirm
   you can open **Joint Budget - Current**. If it isn't there, have the plan
   owner share it with you through [YNAB Together][together].
2. **Install Node.js 20 or newer** from [nodejs.org][node] so Codex can run the
   YNAB connector. For Amazon, install [uv][uv] as well. If you already use
   Homebrew, `brew install node uv` covers both. Open a new Terminal window
   and check `node --version` and, for Amazon, `uvx --version`.
3. **Connect YNAB.** Create a personal access token in your own [YNAB
   Developer Settings][token]. In Terminal, switch to this repository's
   folder and run:

   ```sh
   zsh setup-ynab.zsh
   ```

   Paste the token at the hidden Terminal prompt. The script stores it in a
   private file under `~/.config/household-budget/`, outside the repo.
   Keep the token out of chat. Setup starts in read-only mode.
4. **Install the plugin.** Open this repository folder as a project in
   Codex desktop. Restart the app if needed. In **Plugins**, choose the
   **Household Tools** source, then install **Household Budget**. Start a new
   Codex chat in the project.
5. **Check access.** In that chat, ask: “Using Household Budget, check whether
   my YNAB connection can see Joint Budget - Current. List only the matching
   plan name.” Opening the plan in YNAB checks sharing. Seeing it here checks
   the API access your token actually has.

   If the marketplace is missing, use the Codex CLI if installed. From this
   repository's folder, run these commands and restart the desktop app:

   ```sh
   codex plugin marketplace add .
   codex plugin add household-budget@household-tools
   ```

   Once the repo is on a private GitHub remote, the first command can use
   `OWNER/REPO` in place of `.` if your computer already has GitHub access
   to that repo. Keep a local copy for the token setup script. See the
   [Codex marketplace documentation][marketplace] for details.

## Reconcile a receipt

Add a clear receipt photo or PDF in a Codex chat and send:

> Use `$receipt-budget` to reconcile this receipt in Joint Budget - Current.
> Show me the match and proposed split.

Use `$grocery-budget` if you prefer a grocery-specific entry point. If the
receipt date and the posted date differ, Codex asks you to confirm the match.
If the charge has not imported, wait for it to show up in YNAB and try again.

When you're ready for Codex to apply a proposal, run this once in Terminal
from the repo folder, then restart Codex:

```sh
zsh setup-ynab.zsh enable-writes
```

Ask Codex for an exact preview. After you approve that preview, Codex saves
and verifies the change, including any linked Sawyer transfer. To return to
read-only mode, run `zsh setup-ynab.zsh disable-writes` and restart Codex.

## Review Amazon purchases or uncategorized charges

- For Amazon, ask Codex to sign you in to the bundled Amazon Orders connector.
  Complete the sign-in on Amazon's page in the browser. Then say “Use
  `$amazon-budget` to review my latest Amazon charges in Joint Budget -
  Current.” If Amazon expires your session, repeat the browser sign-in.
- For other transactions, say “Use `$auto-budget` to review my ten latest
  eligible uncategorized charges.”

## Troubleshooting and maintenance

- If YNAB is unavailable, confirm the app can start `npx`. The launcher checks
  the app's PATH and common Homebrew and uv install locations. If Node was
  installed with a shell-only version manager, use a Node installation the
  desktop app can find, such as the official macOS installer.
- The first launch downloads the pinned connector packages. If startup times
  out during that download, restart Codex and try the connection check again.
- If a plan is missing from the API check, verify the account that created the
  token is the account you used to open the shared plan in YNAB. For expired or
  revoked credentials, run the token setup again.
- If Codex shows two similarly named connectors, choose the ones provided
  by Household Budget. Disable duplicate connections if you no longer use
  them, especially when they sign into a different account.
- The household rules live in [receipt-budget](plugins/household-budget/skills/receipt-budget/SKILL.md).
  Pantry and grocery receipts use the same rules. Amazon and auto-budget have
  workflow-specific instructions in their own skill folders.
- Keep the repository private if publishing to GitHub. It contains household
  category and split rules. Commit the plugin files and documentation, and
  keep tokens, Amazon sessions, and receipt photos outside Git.
- The launcher pins both connector packages. When changing a version, check
  that each connector loads and that it still exposes the expected tools.
  Use one real receipt to verify lookup and preview, then confirm the saved
  split in YNAB if you choose to approve it.

[together]: https://support.ynab.com/en_us/ynab-together-B1nS78Cki
[token]: https://app.ynab.com/settings/developer
[node]: https://nodejs.org/en/download
[uv]: https://docs.astral.sh/uv/getting-started/installation/
[marketplace]: https://developers.openai.com/plugins/build/plugins#add-a-marketplace-from-the-cli
