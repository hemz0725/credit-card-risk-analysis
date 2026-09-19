-- H5: Transaction success/failure

-- baseline status distribution
select
  transaction_status,
  count(*) as count,
  count(*) * 100.0 / sum(count(*)) over () as pct
from transactions
group by transaction_status
order by count desc;

-- failure rate by merchant category (with value impact)
select
  merchant_category,
  count(*) as total,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) as failed,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) * 100.0 / count(*) as failure_rate,
  sum(case when transaction_status = 'Failed' then transaction_amount else 0 end) as failed_value,
  avg(case when transaction_status = 'Failed' then transaction_amount end) as avg_failed_amount
from transactions
group by merchant_category
order by failed_value desc;

-- failure rate by transaction channel
select
  transaction_channel,
  count(*) as total,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) as failed,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) * 100.0 / count(*) as failure_rate
from transactions
group by transaction_channel
order by failure_rate desc;

-- failure rate by transaction type
select
  transaction_type,
  count(*) as total,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) as failed,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) * 100.0 / count(*) as failure_rate
from transactions
group by transaction_type
order by failure_rate desc;

-- failure rate by transaction city
select
  transaction_city,
  count(*) as total,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) as failed,
  sum(case when transaction_status = 'Failed' then 1 else 0 end) * 100.0 / count(*) as failure_rate
from transactions
group by transaction_city
order by failure_rate desc;

-- negative revenue by transaction type and status
select
  transaction_type,
  transaction_status,
  count(*) as count,
  avg(transaction_amount) as avg_amount,
  avg(net_revenue) as avg_net_revenue,
  sum(net_revenue) as total_negative_revenue
from transactions
where net_revenue < 0
  and is_refund = 0
  and is_disputed = 0
group by transaction_type, transaction_status
order by total_negative_revenue;

-- cashback verification on negative-revenue transactions
select
  case when cashback_amount > 0 then 'has_cashback' else 'no_cashback' end as cashback_state,
  count(*) as count,
  avg(net_revenue) as avg_net_revenue,
  sum(net_revenue) as total_negative_revenue
from transactions
where net_revenue < 0
  and is_refund = 0
  and is_disputed = 0
group by cashback_state;

-- loss scaling by transaction amount bucket
select
  case
    when transaction_amount < 1000 then '<1000'
    when transaction_amount < 5000 then '1000-5000'
    when transaction_amount < 10000 then '5000-10000'
    else '10000+'
  end as amount_bucket,
  count(*) as count,
  avg(net_revenue) as avg_net_revenue
from transactions
where net_revenue < 0
  and is_refund = 0
  and is_disputed = 0
group by amount_bucket
order by min(transaction_amount);
