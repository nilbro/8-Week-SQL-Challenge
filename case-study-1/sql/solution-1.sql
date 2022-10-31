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
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?