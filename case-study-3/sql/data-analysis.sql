
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

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with cte as (select
*,            
LAG(start_date,1) over(partition by customer_id) as churn_date
from
foodie_fi.subscriptions
where plan_id = 0 or plan_id = 4
            )

select
round(count(case
      when extract(day from start_date::timestamp - churn_date::timestamp) = 7
     then 1 else NULL end)::decimal / count(distinct customer_id) *100) as churned_after_trial_percentage
from cte


-- 6. What is the number and percentage of customer plans after their initial free trial?



SELECT plan_name, COUNT(plan_name) AS number_of_plans_after_trial,
ROUND(
    (
      COUNT(plan_name) / (
        SELECT
          COUNT(distinct customer_id)
        FROM
          foodie_fi.subscriptions
      ) ::numeric * 100
    ), 1
  ) AS percentage_of_total_customers
FROM
  (SELECT
      s.customer_id,
      trial_ended,
      plan_name
    FROM
      foodie_fi.subscriptions AS s
      JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
      JOIN (
        SELECT
          customer_id,
          (start_date + interval '7' day) AS trial_ended
        FROM
          foodie_fi.subscriptions
        WHERE
          plan_id = 0
      ) AS t ON s.customer_id = t.customer_id
 WHERE
start_date = trial_ended
    GROUP BY
      start_date,
      s.customer_id,
      trial_ended,
      plan_name) AS count_plans
      GROUP BY plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

select 
plan_name,
customer_count,
customer_percentage
from
(select 
plan_id,
customer_count,
round(customer_count * 100 / sum(customer_count) over () , 2) as customer_percentage
from
(select 
plan_id,
count(customer_id) as customer_count
from
(select 
customer_id,
plan_id
from
(select 
*,
lead(start_date,1) over (partition by customer_id) as end_date
from foodie_fi.subscriptions
where start_date <= '2020-12-31' :: date)t1
where end_date is NULL)t2
group by plan_id)t3)t4
join foodie_fi.plans t5
on t4.plan_id = t5.plan_id

-- 8. How many customers have upgraded to an annual plan in 2020?


with cte as (select
switched_plan,
count(customer_id) as upgraded_customers
from
(select 
customer_id,
plan_id as initial_plan,
lead(plan_id,1) over (partition by customer_id) as switched_plan,
lead(start_date,1) over (partition by customer_id) as switched_date
from foodie_fi.subscriptions)t1
where switched_date > '2019-12-31' :: date and
 switched_date <= '2020-12-31' :: date
group by switched_plan)

select 
plan_name,
upgraded_customers
from cte a
join
foodie_fi.plans b
on b.plan_id = a.switched_plan
where plan_name = 'pro annual'

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?





