[final_synthesis.md](https://github.com/user-attachments/files/32417921/final_synthesis.md)
# Final Synthesis — Credit Card Risk Analysis

A risk-focused investigation into ₹52.25Cr of billed credit-card payments,
identifying hidden repayment risk, customer concentration, churn signals,
and transaction-level revenue leakage.

---

## The 5 Findings

1. **The portfolio looks healthy at 96% collection, but ₹49.15L is trapped in
   Minimum Due Paid customers** — they've paid only 11.5% of what they owe.

2. **Salaried employees carry 54% of the shortfall.** The pattern is
   occupational, not geographic — consistent across every city and acquisition
   channel tested.

3. **50 customers account for ₹19.00L — 38.7% of the total Min Due Paid
   shortfall.** The largest single exposure is ₹1,04,464. 84% of these
   customers are still active — the risk has not yet become churn.

4. **Customers who ever paid only the minimum churn at 16.89% vs 11.6% for those who never did (1.46×), as high as customers who were ever unpaid (16.41%).

5. **Cashback economics lose money on high-value transactions.** 5,539
   transactions generate ₹1.53L negative revenue; ₹10K+ transactions average
   -₹105 per transaction.

---

## Top 3 Recommendations

1. **Build a silent-risk collections queue** for Minimum Due Paid customers —
   prioritize Salaried customers and the top 50 exposures (₹19L concentrated).

2. **Treat Minimum Due Paid as an early churn signal.** Combine with exposure
   and repayment history, not as a standalone flag.

3. **Redesign cashback economics for high-value transactions.** Introduce a
   cap or threshold where cashback currently exceeds interchange.

---

## Key Numbers

| Metric | Value |
|---|---|
| Total billed | ₹52.25Cr |
| Total collected | ₹50.15Cr |
| Overall collection rate | 96.0% |
| Min Due Paid shortfall | ₹49.15L |
| Top 50 customers shortfall | ₹19.00L (38.7%) |
| Largest single exposure | ₹1,04,464 |
| Base churn rate (payment-active) | 12.1% |
| Min Due Paid churn rate | 16.89% |
| Transactions with negative revenue | 5,539 |
| Total negative revenue | ₹1,53,240 |

---

## Limitations

- ~40% of dates are structurally ambiguous — time-based analysis is scoped
  to trustworthy rows.
- H4 covers 6,896 payment-active customers, not all 12,000 in churn_labels.
- Correlation ≠ causation throughout.

---

**Full analysis:** [README](../README.md)
