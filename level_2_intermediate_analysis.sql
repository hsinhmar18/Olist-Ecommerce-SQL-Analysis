-- Q1. Find monthly order count and monthly revenue.
-- SELECT TO_CHAR(o.order_purchase_timestamp, 'Month') as Month_Name,
Select Date_Trunc('month', o.order_purchase_timestamp) as Month,
Count(Distinct o.order_id) as Total_Orders, 
Round(Sum(oi.price),2) as Total_Revenue 
from orders o 
join order_items oi
	on o.order_id = oi.order_id 
group by Month
order by Total_Revenue desc;

-- Q2. Identify states with highest revenue.
With State_Revenue as (
select c.customer_state as State, o.order_id from Customers c join orders o
on c.customer_id = o.customer_id where o.order_status = 'delivered'
)
Select s.state, Round(Sum(oi.price),2) as Total_Revenue 
from state_revenue s join Order_Items oi on s.order_id = oi.order_id 
group by s.state order by Total_Revenue desc ;

-- 2nd Method using multiple joins

SELECT 
    c.customer_state AS state,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- Q3. Which product categories generate the highest revenue?
Select COALESCE(p.Product_Category_name, 'Unknown') as Category,
Round(Sum(oi.price),2) as Total_revenue 
from products p 
join order_items oi
	On p.product_id = oi.product_id 
group by category 
order by Total_Revenue desc ;

-- Q4. Find customers who placed more than 1 order.
Select c.customer_unique_id , count(o.order_id) as Total_Orders from customers c 
JOIN orders o 
	On c.customer_id = o.customer_id
where o.order_status = 'delivered'
group by customer_unique_id
having count(o.order_id) > 1
order by Total_orders desc ;

-- Q5. What is the average delivery time (order to delivery)?
Select avg(order_delivered_customer_date - order_purchase_timestamp) as average_delivery_time 
from Orders 
where order_delivered_customer_date is not null 
And order_purchase_timestamp is not null ;

-- Q6. Identify late deliveries (delivered after estimated date).
Select Order_id, order_estimated_delivery_date as Estimate_Date,
order_delivered_customer_date as Delivered_date, 
order_delivered_customer_date - order_estimated_delivery_date as Total_Late_Duration
from orders
where order_delivered_customer_date > order_estimated_delivery_date
And order_estimated_delivery_date is Not Null
And order_delivered_customer_date is not null
order by Total_Late_Duration desc ;


-- Q7. Find orders with highest freight cost.
Select Order_id, Round(Sum(freight_value), 2) as Total_Freight_Value
from order_items
where order_id in (
Select order_id from orders where order_status = 'delivered'
)
group by order_id 
order by Total_freight_value desc limit 20; 

-- Q8. What percentage of orders are cancelled?
Select Round(Sum(Case when order_status = 'canceled' then 1 else 0 end)*100.0/ count(*),2) as cancelled_order_percentage 
from orders
Where order_status in ('delivered', 'canceled');
