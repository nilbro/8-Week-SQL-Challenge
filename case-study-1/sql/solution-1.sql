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
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?