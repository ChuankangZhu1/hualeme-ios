# Hualeme Codex Guidelines

## Project identity

Hualeme is an iPhone-only Beta 0.1 app.

It is not a traditional bookkeeping app.
It is not a finance app.
It is not an investment, credit, banking, or budgeting product.

Current positioning:

A local-first, lightweight, no-account, no-bank-binding, no-cloud-upload daily spending check-in toy.

Core loop:

Record amount -> wallet status changes -> short feedback message -> daily check-in.

## Decision ownership

Product, technical, privacy, security, and scope decisions are owned by the project lead and reviewer.

Codex only implements explicitly assigned tasks.

Codex must not make product decisions.

## Git workflow

Never modify main directly.

Every task must use a new branch from main.

Use branch names like:

- codex/feature-*
- codex/fix-*
- codex/chore-*
- feature-*
- fix-*
- chore-*

Before making changes, start from main.

After making changes, show git status and git diff.

Do not commit unless explicitly approved.
Do not merge unless explicitly approved.
Do not push directly to main.
Do not automatically merge pull requests.

Prefer draft pull requests for Codex-generated work.

## Allowed Beta 0.1 scope

Allowed:

- iPhone-only SwiftUI app
- Local amount recording
- $0 / $5 / $10 / $20 / $50 / custom amount
- UserDefaults + JSON Codable local persistence
- Today / week / month totals
- Recent 7 days
- Recent records
- Settings page
- Local notification reminder
- Delete all data
- Privacy explanation
- Wallet HP
- Wallet status
- Spending reaction message
- Daily check-in streak

## Forbidden Beta 0.1 scope

Do not add:

- Account
- Login
- Backend
- Network requests
- Cloud sync
- Advertising SDK
- Analytics SDK
- Subscription
- Paid Pro
- Bank binding
- SMS reading
- Notification reading
- Bank app reading
- OCR
- AI automatic transaction reading
- Financial advice
- Credit card recommendations
- Loan recommendations
- Investment recommendations
- Complex categories
- Budget system
- Ranking
- Social features
- Apple Watch
- Widget
- Android
- Huawei version

Apple Watch is out of scope until iPhone Beta is stable and Beta 0.2 is explicitly approved.

## Privacy and security rules

Do not print spending amounts to console.

Do not print ExpenseEntry.

Do not log all expense records.

Do not add these unless explicitly approved for non-sensitive diagnostics:

- print
- debugPrint
- NSLog
- Logger
- os_log

Do not add:

- URLSession
- URLRequest
- http://
- https://
- Firebase
- Analytics
- AdMob

## Data rules

ExpenseEntry must preserve:

- id: UUID
- date: Date
- amount: Decimal
- note: String?
- createdAt: Date

Do not change amount to Double or Float.

Money calculations must use Decimal.

date means the spending or check-in date.
createdAt means the record creation timestamp.

Stats must use entry.date.

Recent records may sort by createdAt descending.

$0 is a valid record.

Do not filter out $0.

$0 means the user did not spend today, but completed a wallet check-in.

## Statistics rules

Today stats must use Calendar.startOfDay(for:).

Week stats must use Calendar.dateInterval(of: .weekOfYear, for:).

Month stats must use Calendar.dateInterval(of: .month, for:).

Recent 7 days must include today and the previous 6 natural days.

Recent 7 days should return all 7 days, including zero-amount days.

Deleting all data must:

- clear in-memory entries
- remove the UserDefaults object
- reset today / week / month totals
- reset Wallet HP and check-in state

## UI and product tone

Tone should be:

- light
- funny
- low pressure
- privacy-safe
- non-judgmental

Allowed style:

- wallet status
- wallet HP
- wallet reaction
- daily check-in
- playful feedback

Forbidden tone:

- shame
- guilt
- financial fear
- moral judgment
- poverty jokes
- investment advice
- budgeting pressure

Do not use copy that says or implies:

- you are poor
- you are bankrupt
- you failed
- you are hopeless
- you spend irresponsibly
- you should spend less
- you need financial management
- you need investment
- you need a credit card
- you need a loan

Core principle:

Roast the wallet, never judge the user.

## Implementation discipline

Keep tasks narrow.

Do not refactor project structure unless explicitly requested.

Do not introduce new architecture layers unless explicitly approved.

Do not add SwiftData or CoreData unless explicitly approved.

Do not add repositories or services unless explicitly approved.

Do not modify permissions or project configuration unless explicitly approved.

Before finishing a task, report:

1. Files changed
2. Features implemented
3. Manual test result
4. Privacy grep result
5. git diff summary
6. Any uncertainty

## Required checks before review

Check for new privacy, network, ad, analytics, or logging code.

No new matches are allowed for:

- print(
- debugPrint
- NSLog
- Logger
- os_log
- URLSession
- URLRequest
- http://
- https://
- Firebase
- Analytics
- AdMob
