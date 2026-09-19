-- H1: Collection Health Baseline

-- base metrics
select
  p.payment_status,
  count(distinct p.customer_id),
  sum(p.total_amount_due) as total_due,
  sum(p.amount_paid) as total_paid,
  sum(p.amount_paid) * 100.0 / sum(p.total_amount_due) as collection_rate,
  sum(p.total_amount_due) - sum(p.amount_paid) as shortfall
from payments p
group by p.payment_status;
