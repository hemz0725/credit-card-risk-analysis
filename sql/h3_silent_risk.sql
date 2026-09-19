-- H3: Silent Risk Concentration

-- top 50 customers who owe and their relation with churn
select
  p.customer_id,
  c.city,
  c.income_band,
  c.occupation,
  count(distinct p.card_id) as no_of_cards,
  count(p.billing_month) as min_due_months,
  sum(p.total_amount_due) as total_due,
  sum(p.amount_paid) as total_paid,
  sum(p.total_amount_due) - sum(p.amount_paid) as shortfall,
  sum(p.interest_charged) as total_interest_accrued,
  sum(p.late_fee) as total_late_fees,
  cl.churn_flag
from payments p
left join customers c
  on p.customer_id = c.customer_id
left join churn_labels cl
  on c.customer_id = cl.customer_id
where payment_status = 'Minimum Due Paid'
group by p.customer_id, c.city, c.income_band, c.occupation, cl.churn_flag
order by shortfall desc
limit 50;

-- H3 verification: late fees vs interest across top 50 min-due customers
select
  sum(late_fee) as total_late_fees,
  sum(interest_charged) as total_interest
from payments
where payment_status = 'Minimum Due Paid'
  and customer_id in (
    select customer_id
    from payments
    where payment_status = 'Minimum Due Paid'
    group by customer_id
    order by sum(total_amount_due - amount_paid) desc
    limit 50
  );
