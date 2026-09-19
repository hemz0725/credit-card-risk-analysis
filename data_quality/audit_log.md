[audit_log.md](https://github.com/user-attachments/files/32412813/audit_log.md)
# Fintech Audit

# Data Quality Audit Log

Audit of all tables before analysis. Each table was checked for:
PK uniqueness, NULLs, duplicates, orphans, categorical consistency,
numeric ranges, and date trustworthiness.

---

## 1. customers

| Check | Result | Verdict | Action |
| --- | --- | --- | --- |
| Total rows | 12,144 | — | — |
| PK uniqueness (customer_id) | 12,144 = 12,144 | ✅ | None |
| NULL customer_id | 0 | ✅ | None |
| Duplicate customer_id | 0 | ✅ | None |
| signup_date trustworthy | 7,257 (59.8%) | ⚠️ | Scope time-based analysis |
| signup_date ambiguous | 4,836 (39.8%) | ⚠️ | Exclude from date-dependent analysis |
| signup_date unusable | 51 (0.4%) | ⚠️ | Exclude |

**Verdict:** Reliable anchor table. `signup_date` is trustworthy for 59.8% of rows.

**Impact on analysis:**

- Non-date analysis (H1, H2, H4, H5): use all 12,144 customers
- Date-based analysis: scope to the 7,257 trustworthy rows

---

## 2. accounts

| Check | Result | Verdict | Action |
| --- | --- | --- | --- |
| Total rows | 10,165 | — | — |
| PK uniqueness (account_id) | 10,165 = 10,165 | ✅ | None |
| NULL account_id | 0 | ✅ | None |
| NULL customer_id | 0 | ✅ | None |
| Duplicate account_id | 0 | ✅ | None |
| Orphan customer refs | 0 | ✅ | None |
| account_type values | 4 values, clean casing | ✅ | None |
| account_status values | 4 values, clean casing | ✅ | None |
| account_open_date trustworthy | 6,106 (60.1%) | ⚠️ | Scope time-based analysis |
| account_open_date ambiguous | 4,015 (39.5%) | ⚠️ | Exclude from date-dependent analysis |
| account_open_date non-numeric | 44 (0.4%) | ⚠️ | Exclude |

**Verdict:** Clean table. PK solid, no orphans. Date column has the same 60/40 split as customers.

**Impact on analysis:** 

- 15.9% of accounts are Dormant/Inactive/Closed — decide inclusion per analysis
- Balance reporting must use median, not mean
- Date analysis scoped to 60.1% trustworthy rows

---

## 3. credit_cards

| Check | Result | Verdict | Action |
| --- | --- | --- | --- |
| Total rows | 7,268 | — | — |
| PK uniqueness (card_id) | 7,268 = 7,268 | ✅ | None |
| NULL card_id | 0 | ✅ | None |
| NULL customer_id | 0 | ✅ | None |
| Duplicate card_id | 0 | ✅ | None |
| Orphan customer refs | 0 | ✅ | None |
| card_status | Active 6176, Blocked 392, Closed 458, Expired 242 | ✅ | None |
| card_type | Signature 490, Silver 1722, Classic 1255, Gold 2330, Platinum 1471 | ✅ | None |
| credit_limit | Min ₹10,000, Max ₹62.1L, Avg ₹3.68L, no NULLs/negatives | ⚠️ | Check outliers before averaging |
| annual_fee | Min ₹0, Max ₹7,999, Avg ₹2,024, no NULLs/negatives | ✅ | None |
| current_utilization_pct | Min 0%, Max 133.46%, Avg 32.58%, no NULLs/negatives | ⚠️ | Investigate >100% utilization |
| issue_date trustworthy (numeric) | 4,404 (60.6%) | ✅ | Use for date analysis |
| issue_date trustworthy (DD-Mon-YY) | 28 (0.4%) | ✅ | Use for date analysis |
| issue_date ambiguous | 2,836 (39.0%) | ⚠️ | Exclude from date-dependent analysis |
| issue_date invalid/unusable | 0 | ✅ | None |
| credit_limit distribution | Median ₹1.93L, Avg ₹3.68L, P95 ₹13.98L | ⚠️ | Right-skewed. Use median for reporting |
| current_utilization_pct > 100 | 28 (0.39%) | ⚠️ | Over-limit balances — risk signal, not error. Keep, flag for H2. |

**Verdict:** Clean table. PK solid, no orphans. Two numeric anomalies to investigate (`credit_limit` outliers, `utilization >100%`).

**Impact on analysis:**

- 8.4% of cards are Blocked/Closed/Expired — decide inclusion per analysis
- Use median for `credit_limit` reporting (outlier skew)
- Investigate `current_utilization_pct > 100` before using in analysis
- Date analysis scoped to 61.0% trustworthy rows

---

## 4. transactions

| Check | Result | Verdict | Action |
| --- | --- | --- | --- |
| Total rows | 150,000 | — | — |
| PK uniqueness (transaction_id) | 150,000 = 150,000 | ✅ | None |
| NULL transaction_id | 0 | ✅ | None |
| NULL customer_id | 0 | ✅ | None |
| NULL card_id | 0 | ✅ | None |
| NULL account_id | 0 | ✅ | None |
| Duplicate transaction_id | 0 | ✅ | None |
| Orphan customer refs | 0 | ✅ | None |
| Orphan card refs | 98,536 (65.7%) | ✅ | Expected — only Card Purchase joins credit_cards |
| transaction_type values | Card Purchase, UPI Transfer, Debit, Bill Payment, Wallet Load, ATM Withdrawal | ✅ | None |
| transaction_channel values | UPI, Mobile App, POS, Net Banking, Wallet, ATM, Branch | ✅ | None |
| transaction_city values | 14 clean city names | ✅ | None |
| transaction_status values | successful, failed, reversed, refunded | ✅ | None |
| merchant_category values | 14 categories | ✅ | None |
| transaction_amount range | -₹4.95L to ₹6.36L, median ₹2,516, mean ₹5,556 | ⚠️ | Right-skewed — use median |
| transaction_amount negatives | 4,669 | ✅ | All match is_refund=1 |
| cashback_amount range | ₹0 to ₹2,430.77 | ✅ | None |
| reward_points range | 0 to 5,794 | ✅ | None |
| net_revenue range | -₹1,348.99 to ₹6,050.48 | ⚠️ | 5,706 negatives — 97% from non-refund/dispute txns |
| is_refund distribution | 0: 145,331 / 1: 4,669 | ✅ | 3.1% refund rate |
| is_disputed distribution | 0: 148,347 / 1: 1,653 | ✅ | 1.1% dispute rate |
| transaction_date trustworthy | 89,862 (59.9%) | ⚠️ | Scope time-based analysis |
| transaction_date ambiguous | 60,138 (40.1%) | ⚠️ | Exclude from date-dependent analysis |
| transaction_date unusable | 0 | ✅ | None |

**Verdict:** Structurally clean. Two behavioral signals to investigate (negative revenue on normal txns, expected orphan cards).

**Impact on analysis:**

- Use median for amount reporting, not mean
- H5 must analyze negative-revenue transactions as a business signal
- Joins to credit_cards only valid for Card Purchase type
- Date analysis scoped to 59.9% trustworthy rows

---

## 5. payments

| Check | Result | Verdict | Action |
| --- | --- | --- | --- |
| Total rows | 52,214 | — | — |
| PK uniqueness (payment_id) | 52,214 = 52,214 | ✅ | None |
| NULL payment_id | 0 | ✅ | None |
| NULL customer_id | 0 | ✅ | None |
| NULL card_id | 0 | ✅ | None |
| Duplicate payment_id | 0 | ✅ | None |
| Orphan customer refs | 0 | ✅ | None |
| Orphan card refs | 0 | ✅ | None |
| payment_status values | Paid 49,808 / Late 819 / Minimum Due Paid 655 / Partial 521 / Unpaid 411 | ✅ | None |
| payment_status × min_due_flag | Late splits: 562 min-paid-late / 257 underpaid-late | ⚠️ | Treat as two sub-groups in H2 |
| minimum_due_paid_flag | 0: 50,476 / 1,738 | ✅ | None |
| total_amount_due | Min ₹76.75, Max ₹3,70,710, Avg ₹10,006, Median ₹5,032 | ⚠️ | Right-skewed — use median |
| amount_paid | Min ₹0, Max ₹3,62,187, Avg ₹9,605, Median ₹4,749 | ⚠️ | Right-skewed — use median |
| days_late | Min 0, Max 626, Avg 2.27 | ⚠️ | Max 626 noted for H2 |
| late_fee | Min ₹0, Max ₹1,200, Avg ₹33.33 | ✅ | Capped fee |
| interest_charged | Min ₹0, Max ₹29,252, Avg ₹14.37 | ⚠️ | Max noted for H3 (silent risk) |
| due_date trustworthy | 52,077 (99.7%) | ✅ | Use for date analysis |
| due_date ambiguous | 0 | ✅ | None |
| due_date unusable | 137 (0.3%) | ⚠️ | Exclude |
| payment_date NULL (not yet paid) | 411 (0.8%) | ✅ | Expected for Unpaid rows |
| payment_date trustworthy | 20,046 (38.4%) | ⚠️ | Scope time-based analysis |
| payment_date ambiguous | 31,705 (60.7%) | ⚠️ | Structural — early-month payments. Exclude from date analysis. |
| payment_date unusable | 52 (0.1%) | ⚠️ | Empty strings. Flagged and set to NULL. |

**Verdict:** Structurally clean. Two fixes applied post-import. Date ambiguity on `payment_date` is structural (early-month payments), not a defect.

**Impact on analysis:**

- Use **median** for amount reporting (`total_amount_due`, `amount_paid`)
- `payment_status × minimum_due_paid_flag` cross-tab reveals **Late splits into two sub-groups** — treat separately in H2
- `days_late` max of 626 → investigate severity buckets in H2
- `interest_charged` max of ₹29,252 → likely silent-risk case for H3
- Time-based analysis on `payment_date` scoped to 38.4% trustworthy rows
- All joins to `customers`, `credit_cards` are clean — safe for H1, H2, H3, H4

**Corrections applied post-import:**

1. 411 `Unpaid` rows with non-NULL `payment_date` → set to NULL (verified `amount_paid = 0` on all)
2. 52 rows with empty-string `payment_date` → set to NULL

---

## 6. churn_labels

| Check | Result | Verdict | Action |
| --- | --- | --- | --- |
| Total rows | 12,000 | ⚠️ | 144 customers have no churn record — H4 scoped to 12,000 |
| PK uniqueness (customer_id) | 12,000 = 12,000 | ✅ | None |
| NULL customer_id | 0 | ✅ | None |
| Duplicate customer_id | 0 | ✅ | None |
| Orphan refs | 0 | ✅ | None |
| churn_flag distribution | 0: 10,471 / 1: 1,529 | ✅ | 12.7% churn rate |
| churn_reason values | Low Engagement 575, Unknown 363, Product Closed 315, Service Issue 173, Inactive 62, Competitor Switch 28, Payment Stress 13 | ✅ | 7 clean categories |
| churn_risk_score | Min 0.01, Max 0.98, Avg 0.231, Median 0.206 | ✅ | No skew |
| inactive_days | Min 1, Max 727, Avg 36.98 | ⚠️ | Max flagged for H4 |
| churn_date trustworthy | 1,371 (11.4%) | ⚠️ | Scope date analysis |
| churn_date ambiguous | 158 (1.3%) | ⚠️ | Exclude from date analysis |
| churn_date NULL (non-churners) | 10,471 (87.3%) | ✅ | Expected |
| last_transaction_date trustworthy | 8,699 (72.5%) | ⚠️ | Scope date analysis |
| last_transaction_date ambiguous | 3,225 (26.9%) | ⚠️ | Exclude from date analysis |
| last_transaction_date NULL | 59 (40 non-churners + 19 churners) | ⚠️ | Data integrity gap for the 19 churners |

**Verdict:** Structurally clean after fixes. Churn rate 12.7%. Three blank-string contamination issues corrected. 144 customers outside scope, 19 churners missing last_txn_date.

**Impact on analysis:**

- H4 scoped to 12,000 customers (144 have no churn records)
- `churn_reason = 'Payment Stress'` (13 customers) — cross-reference with H3 minimum-due patterns
- `inactive_days` max 727 → investigate in H4
- Time-based churn analysis scoped to 11.4% trustworthy churn_dates
- The 19 churners missing last_txn_date → flag as gap, exclude from last-txn-based analyses

**Corrections applied post-import:**

1. 10,471 empty-string `churn_reason` → NULL
2. 10,471 empty-string `churn_date` → NULL
3. 59 empty-string `last_transaction_date` → NULL

---

## 7. complaints

| Check | Result | Verdict | Action |
| --- | --- | --- | --- |
| Total rows | 8,000 | — | — |
| PK uniqueness (complaint_id) | 8,000 = 8,000 | ✅ | None |
| NULL complaint_id | 0 | ✅ | None |
| NULL customer_id | 0 | ✅ | None |
| Duplicate complaint_id | 0 | ✅ | None |
| Orphan refs | 0 | ✅ | None |
| complaint_category values | 10 clean categories | ✅ | None |
| complaint_channel values | 6 clean channels | ✅ | None |
| priority values | Critical 375, High 1,678, Medium 3,384, Low 2,563 | ✅ | None |
| resolution_status values | Resolved 5,699, Pending 1,249, Escalated 801, Rejected 251 | ✅ | None |
| tat_days | Min 1, Max 36, Avg 7.33, no negatives | ✅ | Range realistic |
| satisfaction_score | Min 1, Max 5, Avg 3.56, no negatives | ✅ | Within expected bounds |
| resolution_status × resolution_date | Pending/Escalated had blank dates (2,050 rows) | ❌ → Fixed | Set to NULL |
| complaint_date trustworthy | 4,879 (61.0%) | ⚠️ | Scope date analysis |
| complaint_date ambiguous | 3,097 (38.7%) | ⚠️ | Exclude from date analysis |
| complaint_date unusable | 24 (0.3%) | ⚠️ | Exclude |
| resolution_date trustworthy | 3,676 (46.0%) | ⚠️ | Scope date analysis |
| resolution_date ambiguous | 2,260 (28.3%) | ⚠️ | Exclude from date analysis |
| resolution_date NULL | 2,064 (25.8%) | ⚠️ | 2,050 expected (unresolved) + 14 gap (Resolved but missing) |
| resolution_date unusable | 0 | ✅ | Fixed |

**Verdict:** Structurally clean after one fix. Complaint volume is realistic and well-distributed.

**Impact on analysis:**

- M5 (Complaints) can use full 8,000 rows for volume/status analysis
- `resolution_date` based analysis scoped to 5,685 resolved complaints with valid dates
- The 14 Resolved-without-date rows → flag as gap, exclude from TAT analyses
- `tat_days` and `satisfaction_score` are clean → usable for service-quality analysis

**Corrections applied post-import:**

1. 2,050 blank `resolution_date` on Pending/Escalated → NULL (logical contradiction)
2. 14 blank `resolution_date` on Resolved → NULL (data gap)

---

## 8–11. Reference Tables

| Table | Rows | PK clean | Verdict |
| --- | --- | --- | --- |
| branch_reference | 14 | ✅ | Usable |
| city_reference | 14 | ✅ | Usable |
| merchant_category_reference | 14 | ✅ | Usable |
| product_reference | 10 | ✅ | Usable |

---
