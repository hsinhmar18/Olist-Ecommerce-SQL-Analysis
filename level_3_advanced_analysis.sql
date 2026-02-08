-- Q1. Rank top 5 customers by total spend.
With price_detail as (
Select o.customer_id, oi.price
From Orders o join order_items oi on o.order_id = oi.order_id
)

Select c.customer_unique_id , Round(Sum(price_detail.price),2) as Total_Spend 
from customers c join price_detail on c.customer_id = price_detail.customer_id
group by c.customer_unique_id
order by Total_Spend desc limit 5 ;

-- Or we can write this as 
With customer_spend as (
Select c.customer_unique_id , Sum(oi.price) as total_spend
From customers c
Join orders o on c.customer_id = o.customer_id
Join Order_items oi on o.order_id = oi.order_id
group by c.customer_unique_id
), 
Ranked_Customers as (
Select customer_unique_id , Round(Total_Spend, 2) as Total_Spend,
Rank() Over (Order By total_spend desc) as Spend_Rank
From Customer_Spend
)
Select * from Ranked_Customers where spend_rank <= 5;

-- Q2. Find month-over-month revenue growth.
With Monthly_Revenue as (
Select Date_Trunc('month', o.order_purchase_timestamp) as Month,
Round(Sum(oi.price),2) as Total_Revenue 
From orders o
Join Order_Items oi on o.order_id = oi.order_id
group by Date_Trunc('month', o.order_purchase_timestamp)
Order by Month 
)
Select Month , Round(Total_Revenue, 2) as Total_Revenue ,
Round(
(total_revenue - LAG(total_revenue) over (order by month))*100 / Lag(Total_revenue) over (order by month) , 2
) as mom_growth_percentage
From monthly_revenue
order by month ;

-- Q3. Identify repeat customers and their contribution to revenue.
With repeat_customers as (
Select c.customer_unique_id, count(o.order_id) as Total_Orders
From customers c Join orders o on c.customer_id = o.customer_id
Where o.order_status = 'delivered'
group by c.customer_unique_id
having count(o.order_id) > 1
)
Select rc.customer_unique_id, Round(Sum(oi.price), 2) as Revenue
From repeat_Customers rc
Join customers c on rc.customer_unique_id = c.customer_unique_id
Join orders o on c.customer_id = o.customer_id
Join order_items oi on o.order_id = oi.order_id
Where o.order_status = 'delivered'
group by rc.customer_unique_id
order by Revenue desc ;

-- Q4. Rank product categories by revenue within each month.

With Monthly_Category_Revenue as (
Select Date_Trunc('month', o.order_purchase_timestamp) as Month,
p.product_category_name as Product_Category,
Sum(oi.price) as Total_Revenue
From products p
Join order_items oi 
on p.product_id = oi.product_id
Join orders o 
on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by Date_Trunc('month', o.order_purchase_timestamp), p.product_category_name
)

Select month, product_category,
Round(Total_Revenue, 2) as Total_revenue,
Rank() Over(
	Partition By month
	order by total_revenue desc
) As Revenue_Rank
From Monthly_Category_Revenue
Order by Month , revenue_Rank ;


-- Q5. Calculate running total revenue over time.

With Monthly_Revenue as (
Select Date_Trunc('month', o.order_purchase_timestamp) as Month,
Sum(oi.Price) as Total_Revenue
From Orders o join order_items oi
On o.order_id = oi.order_id
Where o.order_status = 'delivered'
group by Date_Trunc('month', o.order_purchase_timestamp)
)
Select Month, Round(Total_Revenue, 2) as Total_revenue,
Round(Sum(Total_Revenue) Over (Order By Month), 2) As Running_Total_Revenue
From Monthly_Revenue ;

-- Q6. Find the top product per category based on sales.
With Products_Revenue as (
Select p.product_id,
p.product_Category_name as Category, 
Sum(oi.price) as Total_Sales
From Products p
Join Order_Items oi on p.product_id = oi.product_id
Join orders o on oi.order_id = o.order_id
Where o.order_status = 'delivered'
group by p.product_category_name , p.product_id
),
Ranked_Products as (
Select Category, product_id, Round(Total_Sales, 2) as Total_Sales,
Rank() over (
Partition By Category
Order by Total_Sales desc
) As Sales_Rank
from Products_revenue 
)
Select Category, Product_id, Total_Sales, Sales_rank
From Ranked_Products
Where Sales_Rank <= 3
Order by Total_Sales desc
;

-- Q7. Identify customers whose order value is above average.

With Customers_Order_Value as (
Select c.Customer_Unique_id, Sum(oi.price) as Total_Value
From Customers c Join Orders o on c.customer_id = o.customer_id
Join Order_Items oi on o.order_id = oi.order_id
Where o.order_Status = 'delivered'
group by Customer_Unique_id
)
Select Customer_Unique_Id,
Round(Total_Value, 2) as Total_Value,
Round(Avg(Total_Value) Over(), 2) As Avg_Order_Value
from Customers_Order_value
WHERE Total_Value > (
Select Avg(Total_Value) from Customers_Order_Value )
Order by Total_Value Desc ;