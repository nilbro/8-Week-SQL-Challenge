
-- 1. How many customers has Foodie-Fi ever had?

select
count(distinct customer_id) as total_customers
from
foodie_fi.subscriptions;

-- 2. What is the monthly distribution of trial plan `start_date` values for our dataset - use the start of the month as the group by value

select 
TO_CHAR(start_date, 'yyyy-mm-01') as trial_month,
count(customer_id) as trials
from foodie_fi.subscriptions
where plan_id=0
group by TO_CHAR(start_date, 'yyyy-mm-01');

-- 3. What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`

select 
plan_name,
count(t1.plan_id)
from 
foodie_fi.subscriptions t1
join
foodie_fi.plans t2
on t1.plan_id=t2.plan_id
where TO_CHAR(start_date, 'yyyy') > '2020'
group by  plan_name
;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

select
count(distinct customer_id) as total_customers,
count(case 
      when 
      plan_id = 4 then 1 else null end)::decimal as churned_customers,
round(count(case 
      when 
      plan_id = 4 then 1 else null end)::decimal / count(distinct customer_id) * 100,1) as churn_percentage
from
foodie_fi.subscriptions

