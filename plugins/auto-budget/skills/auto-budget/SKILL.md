---
name: auto-budget
description: Review the 10 latest uncategorized transactions in a YNAB budget, recommend categories using transaction history and receipt-budget rules, and apply only user-approved changes.
---

# Categorize recent transactions

## Select transactions

1. Default to **Joint Budget - Current** unless the user names another plan.
   Ignore surrounding whitespace in returned plan names. Resolve the selected
   plan ID once and pass its explicit `budgetId` to every
   plan operation. Inspect only the live tool schemas needed for the current
   step.
2. Find uncategorized transactions, page through results as needed, and select
   the 10 latest by transaction date, newest first. If fewer than 10 exist,
   review all available transactions. Use a consistent tie-breaker for equal
   dates.
3. Exclude deleted transactions, linked transfers, existing splits, and
   purchases from Target or Amazon. Those merchants are handled by another
   skill. Treat common name variants and imported payee names as the same
   merchant. Continue past excluded transactions until you have 10 eligible
   transactions or have exhausted the uncategorized list. Never create duplicate
   transactions.

## Recommend categories

For each selected transaction, consider its payee, original imported payee,
memo, account, amount, date, and the budget's categorized transaction history.
Look for the same payee's past categories and memos, then compare similar
purchases and recurring spending patterns. Prefer a consistent, recent pattern
supported by transaction details. Resolve current active category IDs before
preparing writes.

Reuse these receipt-budget rules when the transaction details support them:

- Ordinary groceries go to Shared groceries. Clearly identified snacks and
  sweets go to Junk Food, drinks to Beverages, and alcohol to Alcohol.
- Everyday consumables go to Household Basics. Durable household goods such
  as towels, sheets, blankets, and throws go to Household Extras.
- Clothing goes to Clothing - Ethan, India Clothing, or Baby only when the
  wearer is known from transaction details or established history. Ask when
  the wearer is unclear.

A retailer name alone may cover many kinds of purchases. Do not infer item
contents, clothing wearer, or a mixed-purchase split from a broad payee alone.
When evidence is weak, show the transaction as uncertain and ask rather than
guessing. Do not change existing splits or linked transfers.

## Roommate

Read the `## Roommate` section in `~/.config/auto-budget/roommate.md` before
proposing roommate splits. Apply rules for this workflow, with any explicit
transaction-specific instruction taking precedence. If the file or an applicable
rule is missing, continue without an automatic roommate split. Before adding
any roommate transfer, use `search_payees` to verify that its
`transfer_account_id` matches the intended YNAB account.

## Review and approval

If write tools are unavailable, show the proposed changes as a read-only review.
Explain that the user can enable writes via the plugin setup to request an exact
preview and approve it. Treat approval of a read-only review as feedback. If any
plan or connector choice is ambiguous, ask the user before changing YNAB.

Present one numbered list for the selected transactions. For each, show date,
payee, account, amount, proposed category or split, confidence, and a short
reason based on transaction details or budget history. Clearly mark uncertain
items and state what information is needed.

Accept a single reply with per-item decisions, such as “1 approve, 2 change to
Shared groceries, 3 skip.” Treat a correction as the user's intended category
for that item. Do not write changes for skipped or unresolved items.

For approved changes, call `preview_write_tool` with the exact proposed
inputs. Show the original transaction and proposed category or split, amounts,
transfer destination, memos, and flag. Apply only after explicit approval of
the exact preview. Use `update_transaction` for one row and
`update_transactions` for a batch when supported. Omit unrelated fields,
including `approved`. Use orange (`agent-generated`) for purchases and red
for refunds, and call out existing flags that would change.

After writing, read back every changed transaction and compare category,
amount, memo, flag, and split lines. Verify linked roommate transfers and their
amounts in the destination account. Report any failed or partial changes and retain
operation or journal references returned by the server.
