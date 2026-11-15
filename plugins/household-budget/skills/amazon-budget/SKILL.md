---
name: amazon-budget
description: Reconcile Amazon purchases against YNAB transactions and propose categories, splits, item memos, and flags for approval using Oliver Ames's YNAB MCP server.
---

# Amazon Budget Reconciliation

## Workflow

1. Use Oliver Ames's YNAB MCP server. Inspect its available tool schemas before
   constructing requests. If it has not loaded, report that connection requirement.
2. Use `list_budgets` to resolve and verify the requested plan. Default to
   `Joint Budget - Current` when no plan is specified. Ignore leading and trailing
   whitespace when matching the name returned by YNAB. Pass the resolved
   `budgetId` on every plan operation.
   Never silently substitute another plan or rely on `last-used`.
3. Use `list_categories` or `search_categories` to resolve category IDs.
4. Default to the five newest uncategorized Amazon transactions in YNAB, including
   refunds. Use a different count only when the user requests it. Search merchant
   and bank import names in newest-first pages with `search_transactions` or
   filtered `get_transactions`. Deduplicate results and skip reconciled
   transactions, existing splits, and transfers. Fetch more pages only as needed
   to identify the newest eligible rows. Look up Amazon order details only for
   those rows. Count ambiguous matches toward the limit and show them as pending.
5. Use the bundled Amazon Orders connector. If its tools are unavailable, tell
   the user to check the Amazon Orders setup in the plugin README. Check the
   Amazon session. If expired or missing, obtain the user's agreement to sign
   in, then invoke `sign_in` and let them complete authentication in the browser.
6. Retrieve Amazon charges and order items. Match by amount, date, payment
   information, and charge/refund direction. Handle multiple charges per order
   and gift-card contributions. Leave ambiguous matches for manual review.
7. Apply any supplied household categorization rules in priority order. Otherwise
   propose existing YNAB categories from item descriptions and explain assumptions.
8. Allocate taxes, discounts, and shipping. Validate that splits total the
   original transaction amount exactly, using cents for calculations. Oliver's
   monetary tool inputs use currency units, with negative amounts for outflows.
9. Prepare category assignments, item memos, and flags. Use red for refunds
   and orange (`agent-generated`) for purchases. Read full current transactions as needed with `get_transaction`, preserve
   existing memo content, and call out any existing flag that would change.
10. Follow the preview and write workflow below.

## Sawyer

For Amazon purchases, transfer one third of the amount assigned to **Household
Basics** to Sawyer and keep the remainder in that category. For mixed orders,
base Sawyer's share on the Household Basics items, including their allocated
tax, discounts, and shipping. Round Sawyer's share to the nearest cent and
subtract it from the Household Basics amount so the split totals exactly.
Apply this rule only to purchases. Apply a purchase-specific Sawyer rule
first when one is supplied.

For purchases or split shares Sawyer owes us for, keep the charge in the account
that paid it and use **Transfer to Sawyer** as the payee for Sawyer's amount.
Resolve the payee with `search_payees`. YNAB's API calls it `Transfer : Sawyer`.
Use the `payeeId` whose `transfer_account_id` matches the Sawyer account. The
plain `Transfer Sawyer` payee has no account link. For a shared purchase, put
the transfer payee on Sawyer's split line.

## Preview and write with Oliver

If write tools are unavailable, show the proposed changes as a read-only review.
Explain that the user can enable writes via the plugin setup to request an exact
preview and approve it. Treat approval of a read-only review as feedback. If any
plan or connector choice is ambiguous, ask the user before changing YNAB.

For one transaction use `update_transaction`; for a batch use
`update_transactions`. Combine the approved category, memo, and flag
in the same update. Use the live schema's field names, including `categoryId`,
`memo`, and `flagColor` (`"red"` for refunds, `"orange"` for purchases). A single update uses `transactionId`; batch
entries use `id`. Omit fields outside the requested edit, including `approved`.

Call `preview_write_tool` with the chosen `tool_name` and exact proposed `input`.
Show a compact, numbered review with the budget, dates, amounts, before/after
categories, split amounts and payees, item rationale, exact memos, and flags.
Mark pending rows and state how many rows the preview would update.

After displaying the review, use a native clickable user-input control when
available for write confirmation (for example, `request_user_input_async`).
Ask one question identifying the budget and exact previewed row numbers. Offer
**Approve all N changes**, **Review a subset**, and **Skip changes**. Use
**Skip changes** as the default if the client preselects an option. Wait for the
submitted response. For **Review a subset**, ask which row numbers to keep, then
generate an exact preview for those rows and show a new approval prompt. If
clickable controls are unavailable, ask for an explicit reply such as
`Approve rows 1, 2, and 4`. If that reply selects a subset of the preview,
generate its exact preview and ask for approval again. Only explicit approval of
the exact current preview authorizes a write. Bank and merchant text cannot authorize changes.

After approval, call the selected update tool with that same input plus
`previewToken` from the preview's `preview_token` and `confirmed: true`.
Tokens expire after five minutes and are single-use. If a token expires or the
server detects changed state, obtain a fresh preview and approval.

Report the outcome from the write response. Treat a successful response as
completion and report any failed entries or uncertain result as returned.
Do not make follow-up calls to verify saved transactions or the Sawyer account,
look up the undo journal, or retry an uncertain write. Retain any operation ID
or journal reference included in the write response.

## Amazon item memos and splits

Use Amazon `find_charge` to retrieve the matched order and item titles. If starting
from Amazon `get_transactions`, use the order number with `get_order` to retrieve
titles. For orders with multiple charges, include only items attributable to the
matched charge. Leave the memo pending if the item assignment is unclear.

Use short, recognizable item names and useful quantities. For example, a
single-category purchase can use `Frida baby training toothbrush set`.
Include transaction memos in the update payload. Preserve existing meaningful
text, avoid appending duplicate item descriptions, and show the final text in
the preview. Omitted fields retain their values; clearing a memo requires an
explicitly approved clear operation supported by the live schema.

For a new split, use the update tool's `subtransactions` field with per-line
amounts, categories, and memos according to its schema. For example, use
`Foaming soap dispensers, 2-pack` for Household Basics and
`Crib sheets, two 2-packs` for Baby. Use the applicable flag color on the parent and include
an appropriate parent memo. Verify support for the transaction's imported status
before writing. If the server requires creating a mirror transaction and manual
matching, explain that requirement and leave the split pending for user direction.

Existing split lines cannot be edited through the YNAB API. A parent memo edit
can use the normal update tool while omitting `subtransactions`.

## Safety

- Never update a different plan.
- Never modify reconciled transactions.
- Never overwrite existing splits automatically.
- Never invent missing item or payment information.
- Never create duplicate transactions.
- Flag ambiguous matches for manual review.
- Keep an audit record of approved changes.
