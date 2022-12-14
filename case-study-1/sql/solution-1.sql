/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
  	customer_id,
    sum(price) as total_spent 
FROM dannys_diner.sales t1
join
dannys_diner.menu t2
on t1.product_id = t2.product_id
group by customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT 
  	customer_id,
    count(distinct order_date) as total_days_visited
FROM dannys_diner.sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?

with cte as (SELECT 
  	customer_id,
    product_name,
    rank() over (order by order_date)
FROM dannys_diner.sales t1
join
dannys_diner.menu t2
on t1.product_id = t2.product_id)

select
distinct customer_id,
product_name
from cte
where rank = 1
order by customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select 
product_name,
count(t1.product_id) as total_bought
from 
dannys_diner.sales t1
join 
dannys_diner.menu t2
on 
t1.product_id = t2.product_id
group by t1.product_id, product_name
order by count(t1.product_id) desc
limit 1


-- 5. Which item was the most popular for each customer?

with cte as (select 
customer_id,
product_name,
count(t1.product_id) as order_count
from  
dannys_diner.sales t1
join
dannys_diner.menu t2
on t1.product_id = t2.product_id
group by customer_id, product_name
order by customer_id)

select 
customer_id, product_name
from
(SELECT 
    *,
    RANK() OVER(PARTITION BY customer_id ORDER BY order_count DESC) AS rank
  FROM cte)t1
  where rank = 1



-- 6. Which item was purchased first by the customer after they became a member?

with cte as (select 
t1.customer_id,
order_date,
product_id
from
dannys_diner.sales t1
join
dannys_diner.members t2
on t1.customer_id = t2.customer_id
where t1.order_date > t2.join_date
order by order_date)

select customer_id,
product_name

from
	(
		select *,
		rank() over (partition by customer_id order by order_date)
from cte) t1
join 
dannys_diner.menu t2
on t1.product_id=t2.product_id
where rank=1

-- 7. Which item was purchased just before the customer became a member?
with cte as (select 
t1.customer_id,
order_date,
product_id
from
dannys_diner.sales t1
join
dannys_diner.members t2
on t1.customer_id = t2.customer_id
where t1.order_date < t2.join_date
)

select 
customer_id,
product_name
from (
select *,
dense_rank() over (partition by customer_id order by order_date desc)
from cte) t1
join
dannys_diner.menu t2
on t1.product_id = t2.product_id
where dense_rank = 1
order by customer_id

-- 8. What is the total items and amount spent for each member before they became a member?

with cte as (select 
t1.customer_id,
product_id,
count(product_id) as total_ordered
from
dannys_diner.sales t1
join
dannys_diner.members t2
on t1.customer_id = t2.customer_id
where t1.order_date < t2.join_date
group by t1.customer_id, product_id
order by customer_id)



select distinct
customer_id,
sum(total_ordered) over (partition by customer_id) as total_ordered_per_customer,
sum(total_ordered * price) over (partition by customer_id) as total_spent
from cte t1
join 
dannys_diner.menu t2
on 
t1.product_id = t2.product_id
group by t1.customer_id, total_ordered, price



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte as (select 
t1.customer_id,
t1.product_id,
case
when product_name = 'sushi'
	then price * 10 * 2 
when product_name != 'sushi'
	then price * 10
end as points
from 
dannys_diner.sales t1
left join
dannys_diner.menu t2
on 
t1.product_id = t2.product_id
join
dannys_diner.members t3
on
t3.customer_id = t1.customer_id)

select
customer_id,
sum(points) as total_points
from cte
group by 1

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

with cte as (
select 
t1.customer_id,
product_id,
order_date,
order_date - join_date as member_days
from dannys_diner.sales t1
join
dannys_diner.members t2
on t1.customer_id = t2.customer_id
where t1.order_date >= t2.join_date
)

select 
customer_id,
sum(points) as total_points 
from
(
select 
customer_id,
case
	when member_days <= 7 then price * 20
    else price * 10
end as points
from cte t1
join
dannys_diner.menu t2
on t1.product_id = t2.product_id
where DATE_PART('month', order_date) = 1)t1
group by t1.customer_id
  
## Bonus Questions

-- Join all things

select 
t1.customer_id,
order_date,
product_name,
price,
case
	when join_date <= order_date 
    then 'Y'
    else 'N'
end as member
from
dannys_diner.sales as t1
left join
dannys_diner.menu as t2
on t1.product_id = t2.product_id
left join
dannys_diner.members as t3
on
t1.customer_id = t3.customer_id
order by customer_id, order_date

-- Ranking

with cte as (select 
t1.customer_id,
order_date,
product_name,
price,
case
	when join_date <= order_date 
    then 'Y'
    else 'N'
end as member
from
dannys_diner.sales as t1
left join
dannys_diner.menu as t2
on t1.product_id = t2.product_id
left join
dannys_diner.members as t3
on
t1.customer_id = t3.customer_id
order by customer_id, order_date)

select 
*,
case 
	when member = 'N' then NULL
    else rank() over (partition by customer_id, member order by order_date)
end as ranking
from cte