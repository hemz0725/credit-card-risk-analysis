-- H2: Collection Health Segmentation

-- one row per income_band
select
  c.income_band,
  p.payment_status,
  sum(p.total_amount_due) as total_due,
  sum(p.amount_paid) as total_paid,
  sum(p.total_amount_due) - sum(p.amount_paid) as shortfall,
  sum(p.amount_paid) * 100.0 / sum(p.total_amount_due) as collection_rate
from payments p
left join customers c
  on p.customer_id = c.customer_id
where p.payment_status in ('Partial', 'Minimum Due Paid')
group by c.income_band, p.payment_status
order by shortfall desc;

-- one row per acquisition_channel
select
  c.acquisition_channel,
  p.payment_status,
  sum(p.total_amount_due) as total_due,
  sum(p.amount_paid) as total_paid,
  sum(p.total_amount_due) - sum(p.amount_paid) as shortfall,
  sum(p.amount_paid) * 100.0 / sum(p.total_amount_due) as collection_rate
from payments p
left join customers c
  on p.customer_id = c.customer_id
where p.payment_status in ('Partial', 'Minimum Due Paid')
group by c.acquisition_channel, p.payment_status
order by shortfall desc;

-- one row per occupation
select
  c.occupation,
  p.payment_status,
  sum(p.total_amount_due) as total_due,
  sum(p.amount_paid) as total_paid,
  sum(p.total_amount_due) - sum(p.amount_paid) as shortfall,
  sum(p.amount_paid) * 100.0 / sum(p.total_amount_due) as collection_rate
from payments p
left join customers c
  on p.customer_id = c.customer_id
where p.payment_status in ('Partial', 'Minimum Due Paid')
group by c.occupation, p.payment_status
order by shortfall desc;

-- one row per state
select
  c.state,
  p.payment_status,
  sum(p.total_amount_due) as total_due,
  sum(p.amount_paid) as total_paid,
  sum(p.total_amount_due) - sum(p.amount_paid) as shortfall,
  sum(p.amount_paid) * 100.0 / sum(p.total_amount_due) as collection_rate
from payments p
left join customers c
  on p.customer_id = c.customer_id
where p.payment_status in ('Partial', 'Minimum Due Paid')
group by c.state, p.payment_status
order by shortfall desc;

-- one row per city
select
  lower(trim(c.city)),
  p.payment_status,
  sum(p.total_amount_due) as total_due,
  sum(p.amount_paid) as total_paid,
  sum(p.total_amount_due) - sum(p.amount_paid) as shortfall,
  sum(p.amount_paid) * 100.0 / sum(p.total_amount_due) as collection_rate
from payments p
left join customers c
  on p.customer_id = c.customer_id
where p.payment_status in ('Partial', 'Minimum Due Paid')
group by lower(trim(c.city)), p.payment_status
order by shortfall desc;
