# Data Dictionary: Raw Source Extract

The source file is `data/raw/activity_extract.csv`, a single
comma delimited file with a header row, UTF-8 encoded. It is a raw,
uncleaned export exactly as it left the source system. There are no
separate tables and no ready made primary keys. Each row represents one
event for one client: a product enrollment, a CRM interaction, or a
transaction. The event type is named in the `event_type` column, and which
of the remaining columns are populated depends on that type.

This is deliberate. A real system export often looks exactly like this: one
undifferentiated activity log rather than a set of clean, pre modelled
tables. Recognizing the three event types hiding in the file, and working
out what to key each one on, is part of the exercise.

## Columns present on every row (client details)

These repeat on every row belonging to the same client, since the client's
details are carried along with each of their events rather than stored
once.

| Column | Notes |
|---|---|
| client_number | Business identifier for the client. Not guaranteed to be the only way to recognize the same client, profile it. |
| first_name | |
| last_name | |
| email | May be blank. Formatting is not standardized. |
| mobile_number | May be blank. Multiple formats are present. |
| date_of_birth | YYYY-MM-DD |
| gender | Values seen: F, M, U, blank |
| province | South African province |
| city | |
| signup_date | Date the client joined the bank, YYYY-MM-DD |

## Event columns

| Column | Notes |
|---|---|
| event_type | One of: `Product Enrollment`, `CRM Interaction`, `Transaction` |
| event_date | The date of the event. Meaning depends on event_type (enrollment date, interaction date, or transaction date). |

## Columns populated only when event_type is Product Enrollment

| Column | Notes |
|---|---|
| account_number | Business identifier for the product account this enrollment created. |
| product_type | Savings, Credit Card, or Personal Loan |
| account_status | Active, Closed, or Suspended |
| credit_limit | Only meaningful for Credit Card |
| loan_amount | Only meaningful for Personal Loan |
| account_balance | Balance at extract time |

## Columns populated only when event_type is CRM Interaction

| Column | Notes |
|---|---|
| channel | Call, Chat, Email, Branch, or WhatsApp |
| interaction_type | Query, Complaint, Product Application, Feedback, or Fraud Report |
| resolved_flag | Y, N, or blank |

## Columns populated only when event_type is Transaction

| Column | Notes |
|---|---|
| account_number | The product account the transaction happened against. Should relate back to an account_number seen on a Product Enrollment row for the same client. |
| product_type | Carried along for convenience, should agree with the enrollment row for that account_number. |
| transaction_type | Deposit, Withdrawal, POS Purchase, EFT Payment, Debit Order, Fee, or Refund |
| channel | ATM, POS, Branch, Online Banking, Mobile App, or EFT |
| amount | Sign convention is not explained here, profile it and decide what it means |

## What is not told to you on purpose

This dictionary describes the columns, not their quality, and it does not
tell you how to split this file into a dimensional model. Before building
anything, profile the extract: row counts per event_type, null rates,
format consistency within a column, whether the same client_number always
carries the same client details, whether every account_number used on a
Transaction row also appears on a Product Enrollment row, and the date
range covered. Document what you find in your data quality note, that
write up is a deliverable.
