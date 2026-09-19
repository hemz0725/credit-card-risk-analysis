-- H4: Churn Correlation with Payment Behavior

-- churn rate by ever_min_due flag
with behavior as (
  select
    customer_id,
    max(case when payment_status = 'Minimum Due Paid' then 1 else 0 end) as ever_min_due,
    max(case when payment_status = 'Late' then 1 else 0 end) as ever_late,
    max(case when payment_status = 'Unpaid' then 1 else 0 end) as ever_unpaid,
    max(case when payment_status = 'Partial' then 1 else 0 end) as ever_partial,
    count(case when payment_status = 'Minimum Due Paid' then 1 end) as min_due_months,
    sum(interest_charged) as total_interest,
    sum(late_fee) as total_late_fees
  from payments
  group by customer_id
)
select
  ever_min_due,
  count(*) as total_customers,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) as churned,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) * 100.0 / count(*) as churn_rate
from behavior
left join churn_labels cl
  on behavior.customer_id = cl.customer_id
group by ever_min_due;

-- churn rate by ever_late flag
with behavior as (
  select
    customer_id,
    max(case when payment_status = 'Minimum Due Paid' then 1 else 0 end) as ever_min_due,
    max(case when payment_status = 'Late' then 1 else 0 end) as ever_late,
    max(case when payment_status = 'Unpaid' then 1 else 0 end) as ever_unpaid,
    max(case when payment_status = 'Partial' then 1 else 0 end) as ever_partial,
    count(case when payment_status = 'Minimum Due Paid' then 1 end) as min_due_months,
    sum(interest_charged) as total_interest,
    sum(late_fee) as total_late_fees
  from payments
  group by customer_id
)
select
  ever_late,
  count(*) as total_customers,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) as churned,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) * 100.0 / count(*) as churn_rate
from behavior
left join churn_labels cl
  on behavior.customer_id = cl.customer_id
group by ever_late;

-- churn rate by ever_unpaid flag
with behavior as (
  select
    customer_id,
    max(case when payment_status = 'Minimum Due Paid' then 1 else 0 end) as ever_min_due,
    max(case when payment_status = 'Late' then 1 else 0 end) as ever_late,
    max(case when payment_status = 'Unpaid' then 1 else 0 end) as ever_unpaid,
    max(case when payment_status = 'Partial' then 1 else 0 end) as ever_partial,
    count(case when payment_status = 'Minimum Due Paid' then 1 end) as min_due_months,
    sum(interest_charged) as total_interest,
    sum(late_fee) as total_late_fees
  from payments
  group by customer_id
)
select
  ever_unpaid,
  count(*) as total_customers,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) as churned,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) * 100.0 / count(*) as churn_rate
from behavior
left join churn_labels cl
  on behavior.customer_id = cl.customer_id
group by ever_unpaid;

-- churn rate by ever_partial flag
with behavior as (
  select
    customer_id,
    max(case when payment_status = 'Minimum Due Paid' then 1 else 0 end) as ever_min_due,
    max(case when payment_status = 'Late' then 1 else 0 end) as ever_late,
    max(case when payment_status = 'Unpaid' then 1 else 0 end) as ever_unpaid,
    max(case when payment_status = 'Partial' then 1 else 0 end) as ever_partial,
    count(case when payment_status = 'Minimum Due Paid' then 1 end) as min_due_months,
    sum(interest_charged) as total_interest,
    sum(late_fee) as total_late_fees
  from payments
  group by customer_id
)
select
  ever_partial,
  count(*) as total_customers,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) as churned,
  sum(case when cl.churn_flag = 1 then 1 else 0 end) * 100.0 / count(*) as churn_rate
from behavior
left join churn_labels cl
  on behavior.customer_id = cl.customer_id
group by ever_partial;
