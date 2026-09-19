# Credit Card Portfolio Health: Repayment Behavior & Risk Signals

A risk-focused analysis of **₹52.25Cr in billed credit-card payments**, identifying hidden repayment risk, customer concentration, churn signals, and transaction-level revenue leakage.

---

## The Findings

* Portfolio collects **96.0%**, but **₹49.1L** is trapped in Minimum Due Paid customers.
* **Top 50 silent-risk customers carry ₹19L exposure** — **84% remain active**, meaning the risk has not yet materialized as churn.
* Customers who ever paid only the minimum churn at 16.89% vs 11.60% for those who never did (1.46×), comparable to customers who were ever unpaid (16.41%).
* **5,539 transactions generate ₹1.53L negative net revenue**; 100% receive cashback, with ₹10K+ transactions averaging **-₹105 per transaction**.
* Transaction failures are broadly uniform across types, channels, and cities (**3.96%–4.90%**), pointing toward an operational issue rather than a segment-specific problem.

---

## Business Context

The stakeholder is the **Head of Risk at a credit-card issuer** who wants to understand whether a healthy portfolio-level collection rate is masking customers moving toward financial stress. The analysis supports decisions around **collections prioritization, early-risk identification, churn intervention, and transaction economics**.

---

## Data

| Table            |    Rows | Purpose                                                  |
| ---------------- | ------: | -------------------------------------------------------- |
| customers        |  12,144 | Customer demographics and acquisition attributes         |
| accounts         |  10,165 | Account-level status and balances                        |
| credit_cards     |   7,268 | Card type, limits, utilization, and fees                 |
| transactions     | 150,000 | Transaction behavior, failures, cashback, and revenue    |
| payments         |  52,214 | Repayment behavior, amounts due/paid, fees, and interest |
| churn_labels     |  12,000 | Churn status and churn-related attributes                |
| complaints       |   8,000 | Customer service and complaint outcomes                  |
| Reference tables |       — | Branch, city, merchant category, and product mappings    |

---

## Data Quality

All **8 core tables** were audited for primary-key integrity, NULLs, duplicates, orphan references, categorical consistency, numeric ranges, and date trustworthiness. **6 post-import corrections** were applied during the cleaning process, with changes documented and verified. Date fields have a structural limitation: approximately **60% of dates are trustworthy and 40% are ambiguous**, so time-dependent analysis was scoped accordingly. One structural finding was that **orphan card references in transactions are expected**, because only Card Purchase transactions should join to the credit-card table.

[Data quality audit log](data_quality/audit_log.md)

---

## Methodology

The analysis follows a consistent five-step framework:

**Business Question → Metric → Query → Interpretation → Recommendation**

Date-dependent analysis uses a three-layer audit:

**Trustworthy → Ambiguous → Unusable**

Ambiguous and unusable dates are excluded from analyses where date accuracy would affect the conclusion.

---

## H1 — Portfolio Collection Health

**Business Question:** Of everything we billed, how much did we actually collect, and where is the shortfall?

**Output:**

| payment_status   | count | total_billed | total_collected | collection_rate |   shortfall |
| ---------------- | ----: | -----------: | --------------: | --------------: | ----------: |
| Paid             | 6,884 |     ₹50.10Cr |        ₹49.09Cr |           98.0% |     ₹1.00Cr |
| Late             |   710 |      ₹0.73Cr |         ₹0.68Cr |           92.2% |      ₹5.71L |
| Minimum Due Paid |   586 |      ₹55.52L |          ₹6.36L |       **11.5%** | **₹49.15L** |
| Partial          |   495 |      ₹48.17L |         ₹31.69L |       **65.8%** | **₹16.48L** |
| Unpaid           |   384 |      ₹38.00L |              ₹0 |          **0%** |     ₹38.00L |

**Overall:** ₹52.25Cr billed / ₹50.15Cr collected = **96.0%**

**Interpretation:** The portfolio collects **96.0%**, which appears healthy at aggregate level. The breakdown exposes a concentrated problem: Minimum Due Paid customers have only **11.5% collection**, leaving **₹49.1L** uncollected. Unlike Unpaid customers, they are making payments and therefore appear compliant, but are leaving most of their billed balance outstanding. Partial customers also materially underperform at **65.8%**, creating another ₹16.5L shortfall.

**Recommendation:** Prioritize Minimum Due Paid and Partial customers for targeted collections and early-risk investigation.

**Query:** `sql/h1_collection_health.sql`

---

## H2 — Collection Health Segmentation

**Business Question:** Which customer segments carry the Min Due Paid and Partial shortfall?

**Key finding:** Salaried employees carry **₹27.6L of Min Due Paid shortfall**, representing **56%** of the total. The pattern is occupational rather than regional or acquisition-channel specific.

**Output:**

| Occupation        | Min Due Paid Shortfall | Partial Shortfall | Combined Shortfall |
| ----------------- | ---------------------: | ----------------: | -----------------: |
| Salaried          |             **₹27.6L** |            ₹10.3L |         **₹37.9L** |
| Other occupations |                 ₹21.6L |             ₹6.2L |             ₹27.8L |
| **Total**         |             **₹49.1L** |        **₹16.5L** |         **₹65.6L** |

**Interpretation:** Salaried customers account for the largest concentration of the shortfall, with **₹27.6L** in Minimum Due Paid exposure alone. The same pattern appears across cities and acquisition channels, so the concentration is not explained by a single geography or channel. Metro cities contribute significant exposure, but this reflects the concentration of salaried customers rather than a standalone geographic effect. No major acquisition channel dominates the pattern.

**Recommendation:** Prioritize Salaried Min Due Paid customers for collections outreach and segment them further by credit-limit or tenure bands.

**Query:** `sql/h2_collection_segmentation.sql`

---

## H3 — Silent Risk Concentration

**Business Question:** Which customers look compliant but are accumulating risk?

**Key findings:**

* Top 50 customers represent approximately **₹19L of ₹49.1L** total Min Due Paid shortfall — about **40%**.
* Largest single exposure: **₹1,04,464** shortfall from one customer.
* Most top-50 customers have only **1–2 Min Due Paid months** — exposure-driven rather than chronic behavior.
* **84% remain active**; only 8 of 50 have churned.
* Late fees of **₹46,950** exceed interest of **₹28,824** across the top 50.

**Interpretation:** Min Due Paid shortfall is highly concentrated, with roughly 40% sitting among only 50 customers. Most of these customers are not repeatedly paying minimum due; instead, high balances make even one or two Min Due Paid months financially significant. The largest customer exposure exceeds ₹1L, while **84% of the top 50 remain active**, meaning the risk is visible before it has translated into churn. Late fees also exceed interest, indicating that repayment stress is accompanied by additional delinquency costs.

**Recommendation:** Create a targeted early-risk queue for the top Min Due Paid exposures and intervene while customers remain active.

**Query:** `sql/h3_silent_risk.sql`

---

## H4 — Churn Correlation with Payment Behavior

**Business Question:** Does repayment behavior predict churn?

**Base population:** **6,896 customers** appearing in both payment and churn data, with a **12.0% baseline churn rate**.

| Behavior     | Churn (flag=0) | Churn (flag=1) |      Lift |
| ------------ | -------------: | -------------: | --------: |
| ever_min_due |         11.60% |     **16.89%** | **1.46×** |
| ever_late    |         11.61% |         15.92% |     1.37× |
| ever_unpaid  |         11.79% |         16.41% |     1.39× |
| ever_partial |         11.84% |         14.75% |     1.25× |

**Interpretation:** All four repayment behaviors are associated with higher churn rates. Minimum Due Paid shows the strongest observed association at **16.89% churn**, or **1.46×** the baseline. Notably, its churn rate is higher than the rate among customers who were ever unpaid (**16.41%**), reinforcing the silent-risk signal. These results identify an association, not proof that repayment behavior causes churn.

**Recommendation:** Use Minimum Due Paid status as an early-warning indicator alongside exposure and customer-level repayment history.

**Query:** `sql/h4_churn_correlation.sql`

---

## H5 — Transaction Success/Failure Analysis

**Business Question:** Where are transactions failing, and what's the pattern?

**Three findings:**

**1. Failure rates are uniform:**

| Dimension           | Failure Rate |
| ------------------- | -----------: |
| transaction_type    |  4.22%–4.74% |
| transaction_channel |  4.42%–4.90% |
| transaction_city    |  3.96%–4.81% |

This consistency suggests an operational issue rather than a failure pattern isolated to one customer, channel, city, or transaction type.

**2. Merchant category exception:**

| Category  | Failure Rate | Failed Value |
| --------- | -----------: | -----------: |
| Insurance |    **6.26%** |       ₹41.6L |
| Hotel     |    **6.00%** |       ₹23.8L |
| Travel    |    **5.00%** |   **₹63.9L** |

**3. Cashback-driven negative revenue:**

* **5,539** successful, non-refund, non-dispute transactions have negative `net_revenue`.
* **100%** of them have cashback.
* Total negative revenue: **₹1.53L**.
* Card Purchase represents **83% of transactions and 91% of the loss**.
* ₹10K+ transactions average **-₹105.10 net revenue per transaction**.

**Interpretation:** Transaction failures are broadly uniform across major dimensions, pointing toward an operational rather than segment-specific issue. Insurance and Hotel have elevated failure rates, while Travel has the highest failed transaction value at **₹63.9L**. A separate economics issue appears in cashback: **5,539 transactions generate ₹1.53L of negative net revenue**, and the loss per transaction increases with transaction size. This indicates that the current cashback economics can become increasingly unfavorable on higher-value transactions.

**Recommendation:** Investigate the Insurance/Hotel failure paths operationally and review cashback caps or thresholds for high-value transactions.

**Query:** `sql/h5_transaction_failure.sql`

---

## Final Recommendations

* **Prioritize silent repayment risk:** Build collections queues around Minimum Due Paid customers, especially high-exposure Salaried customers and the top customer-level exposures.
* **Add Min Due Paid to early-warning monitoring:** Its **1.46× churn lift** makes it a useful signal when combined with exposure and repayment history rather than treated as a standalone risk indicator.
* **Review transaction economics separately from credit risk:** Investigate merchant-category failures and redesign high-value cashback economics where transactions currently generate negative net revenue.

---

## Limitations

* Approximately **40% of relevant dates are ambiguous by construction**, so time-based analysis is scoped to trustworthy dates.
* H4 covers **6,896 payment-active customers**, rather than all 12,000 customers in `churn_labels`.
* **Correlation ≠ causation** throughout; observed repayment/churn relationships may reflect underlying financial stress or other factors.
* Negative revenue analysis assumes `net_revenue` captures the full economics of each transaction; additional costs or revenue components may not be represented.
* The **Top 50 cutoff in H3 is arbitrary** and captures concentration within that selected group rather than defining a natural risk boundary.

---

## Tools

SQL (PostgreSQL) · Excel / Power Query (cleaning) · Power BI (dashboard) · GitHub

---

## Author

**Hemanthkumar M**
B.Com (General), Loyola College, Chennai
[LinkedIn](https://www.linkedin.com/in/hemanthkumar-m-13082b23b) · [GitHub](https://github.com/Hemz0725)

---

*This project was built as a portfolio piece to demonstrate end-to-end analyst capability: business framing → data cleaning → SQL analysis → insight generation → business recommendation.*
