## Roommate

- Name: Sawyer
- YNAB transfer account: Sawyer
- Linked transfer payee: `Transfer : Sawyer`

### Receipt and grocery purchases

Split one third of the grocery portion and one third of the Household Basics
portion. The grocery portion includes Shared groceries, Junk Food, Beverages,
and Alcohol. Keep the remaining amounts in their original categories. On mixed
receipts, clothing and Household Extras receive a share only when the user
specifies one.

### Amazon purchases

Split one third of Household Basics. Keep the remainder in Household Basics.

### Auto-budget

For purchases, split one third of identifiable grocery and Household Basics
spending using the same category rules as receipt and grocery.

For identifiable monthly utility payments, split one third and keep the
remainder in the utility category:

- NYSEG (New York State Electric & Gas) → Electricity & Gas
- Spectrum internet → Internet
- Casella garbage service → Garbage

The utility rule excludes refunds, red-flagged transactions, and existing
splits. Round the share to the nearest cent and subtract it from the payment to
get the category amount.

### Rules for all workflows

Apply an explicit transaction-specific split before these defaults. Automatic
splits apply to purchases or the listed utility payments. Exclude refunds.
Keep the transaction in the original paying account. Use `search_payees` to
find the linked transfer payee and verify that its `transfer_account_id` matches
the configured roommate account. Use that payee ID on the roommate split line.
The plain `Transfer Sawyer` payee is unlinked. If the destination cannot be
verified, ask the user to clarify before preparing an exact write preview.
