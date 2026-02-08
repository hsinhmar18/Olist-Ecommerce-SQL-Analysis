-- Q1: How many total customers are there?
Select count( Distinct customer_unique_id) as Total_Customers from customers ; -- Add distinct to avoid repetition.

-- Q2: How many total orders have been placed?
Select Count(*) as Total_Orders from Orders ;

-- Q3: How many orders are delivered vs cancelled?
Select Order_Status , Count(order_id) as Total_Orders
from Orders Where Order_Status in ('delivered', 'canceled')
group by Order_Status ;

-- Q4: List the top 10 cities with highest number of orders.
Select c.customer_city as City, count(o.order_id) as No_Of_Orders 
from Customers c join orders o on c.customer_id = o.customer_id 
group by c.customer_city order by No_Of_Orders desc limit 10;

-- Q5: Find the total revenue generated (use order_items).
Select Round(SUM(price),2) as Total_revenue from Order_Items ;

-- Q6: What is the average order value (AOV)?
Select Round(Avg(Order_total), 2) As AOV
from(
select Order_id, Sum(price) as Order_total
from order_items group by Order_id
) t;

-- Q7: Which are the top 5 product categories by number of items sold?
Select p.Product_category_name, count(oi.order_item_id) as Total_items_sold
from Products p join order_items oi on p.Product_id = oi.Product_id
group by p.Product_category_name order by Total_items_sold desc limit 5 ; 

-- Q8: What are the most used payment types?
Select Payment_Type, count(*) as Total_Transactions 
from Payments group by Payment_Type order by Total_transactions desc ;