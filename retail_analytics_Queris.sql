select * from customers c ;
select * from orders o ;

--Section A — SQL fundamentals (Q1–Q10) --
-- this section tests the understanding of the following *Concepts:* `SELECT`, `WHERE`, `DISTINCT`, `ORDER BY`, `LIMIT`, `LIKE`, `BETWEEN`

-- Q1. Retrieve all customer records.

select * from customers c ;

--Q2. Display customer names, cities, and segments.

select c.customer_name, c.city, c.customer_segment
from customers c ;

--Q3. Find customers living in Nairobi.

select * from customers c 
where c.city = 'Nairobi'; 													-- 48 customers

--Q4. Find customers registered after January 1, 2025.

select * from customers c 
where c.registration_date > '2025-01-01'
order by c.registration_date asc ;											-- 116 customers

--Q5. Display all unique customer cities.

select distinct c.city as customer_cities
from customers c ;															

--Q6. Retrieve the 10 most recent orders. 
/*Focus columns - order_id, order_date - 
 * concept -order by  -DESC 
 * Limit 10 rows only
 * */

select order_id , order_date
from orders o 
order by o.order_date desc
limit 10;

--Q7. Find orders with unit prices above KSh 10,000.
/*	Focus - order_id, unit_price
 * concept Where unit price above 10000
 * from table - orders
 * */
select o.order_id , o.unit_price
from orders o 
where o.unit_price > 10000;

--Q8. Find customers whose names start with A.
/*Customer tabe
 * What? - customer_names, 
 * Focus - Starts with A
 * Concept WHERE ... 'like' 'A%'
 * */

select customer_name
from customers c 
where c.customer_name like 'A%'
order by c.customer_name asc ;

--Q9. Retrieve orders with quantities between 2 and 5.
/* from - orders table
 * What? order_id, Quantity
 *	Interest- Quantity between 2 and 5
 * */

select order_id, o.quantity
from orders o 
where o.quantity between 2 and 5
order by o.order_id ;

--Q10. Find orders paid through M-Pesa.
/* From - orders
 * what? order_ids, payment_method
 * Interest - paid via M-Pesa
 * */
select  o.order_id, payment_method
from orders o 
where o.payment_method = 'M-Pesa'
order by o.order_id ;												--441 ORDERS

--========================================### Section B — Aggregation and grouping (Q11–Q20)===================================--
--In this section focus in on the following Concepts:( `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`, `ROUND`)---------

--Q11. Count all customers.
/*	From - customers
 *	Count total customers 
 * */

select count(*) total_customers
from customers c ;													-- 150 customers

--Q12. Count all orders.
/* From orders
 * concept - count(*)
 * */
select count(*) total_orders
from orders o ;														-- 800 orders

--Q13. Calculate completed-order revenue.
/* From Orders
 * Check - order_status (Completed)
 * interest - Revenue
 * what? quantity sold, unit_price, discount
 * */

select SUM(quantity * unit_price * (1 - discount / 100)) as completed_order_revenue
from orders o 
where o.order_status = 'Completed';									-- sh.24,155,371.7

--Q14. Calculate the average completed-order value.
/* FROM ORDERS
 * Calculate Avg (order value)
 * Interest (o.quantity * unit_price * (1 - discount / 100.0)) - Net Value or the orders
 * */

select round(AVG(o.quantity * unit_price * (1 - discount / 100.0)),2) as average_order_value
from orders o 
where o.order_status = 'Completed';									-- sh.38,099.96

--Q15. Find the highest and lowest product prices.
/* orders
 * Concept - Max(), Min()
 * Interest - unit_price
 * */

select MAX(unit_price) as highest_product_price, MIN(unit_price) as lowest_product_price
from orders o ;														-- Highest (sh.89,999) and Lowest (sh.1,899)

--Q16. Calculate revenue by product category.
/* ORDERS
 * REVENUE/P.CATEGORY
 * Interest - product_category, quantity, unit_price, discount
 * check order_status 'Completed' - This is the only actual realized revenue
 * */

select product_category, round(SUM(o.quantity*unit_price*(1-discount/100.0)),2) as revenue_per_category
from 		orders o 
where		o.order_status = 'Completed'
group by 	o.product_category
order by 	revenue_per_category desc;

--Q17. Count customers by city.
/* CUSTOMERS
 * Customers in each cit
 * */

select c.city, count(*) as total_customers
from 		customers c 
group by 	c.city 
order by 	total_customers desc;

--Q18. Calculate quantity sold by product.
/* Orders
 *Focus - product_name, quantity
 *concept - Count quantity sold
 *Interest -  Completed sales
 * */
select  product_name, count(quantity) as total_sales
from 		orders o 
where		order_status = 'Completed'
group by 	o.product_name 
order by 	total_sales desc;

--Q19. Find categories generating more than KSh 100,000 in revenue.
/*ORDERS
 * Net revenue per product category
 * Only catgegories gerenerating more tha 100,000
 * Focus - product_category,quantity, unit price, discount 
 * */
select product_category, SUM(o.quantity*unit_price * (1-discount/100.00)) as revenue
from 		orders o 
where 		o.order_status = 'Completed'
group by 	o.product_category 
having 		SUM(o.quantity*unit_price * (1-discount/100.00)) > 100000
order by 	revenue desc;

--Q20.Calculate the percentage of cancelled orders.
/*Orders
 * order_status - Cancelled
 * use Filter to count only the cancelled order in the order_status
 * */
 select 100.0* count(*)filter (where order_status = 'Cancelled') / count(*) as percentage_cancelled
 from orders o ;													-- 9.5% of total orders placed were cancelled. 
 
 
 --======================================### Section C — Joins and customer analytics (Q21–Q28) ================================-----------
 -- In this section we focus on on Concepts:* `INNER JOIN`, `LEFT JOIN`, `GROUP BY`, `HAVING ----------------------------------------------
 
 --Q21. Display orders with customer names and cities.
 /* Customers and orders table
  * Interest - custromer_name, cities, order_id ( from orders)
  * join - inner join - to pick every match
  * */
 
 select c.customer_name, c.city, count(o.order_id) as total_orders
 from customers c 
 join orders o using (customer_id)
 group by c.customer_name, c.city
 order by total_orders desc;

--Q22. Calculate total spending by customer.
 /*customers and orders table
  * JOIN ORDERS (iNNER JOIN)
  * CUSTOMER_NAME,quantity, unit price, quantity
  * on completed sales
  * */
 select c.customer_name, SUM(o.quantity * unit_price *(1-discount/100.0)) as expediture
 from customers c 
 join orders o using (customer_id)
 where o.order_status = 'Completed'
 group by c.customer_name 
 order by expediture desc;

--Q23. Identify customers who have never ordered.
/* CUSTOMERS AND ORDERS
 * JOIN  - left join. Fetch exact matches only
 * customer_name, order_id
 * */

select customer_name 
from customers c 
left join orders o using (customer_id)
where order_id is null;

--Q24. Find the 10 highest-spending customers.
 /*customers and orders table
  * JOIN ORDERS (iNNER JOIN)
  * CUSTOMER_NAME,quantity, unit price, quantity
  * on completed sales
  * 	
  * */
 select c.customer_name, SUM(o.quantity * unit_price *(1-discount/100.0)) as expediture
 from customers c 
 join orders o using (customer_id)
 where o.order_status = 'Completed'
 group by c.customer_name 
 order by expediture desc
 Limit 10;

--Q25. Calculate revenue by customer city.
/*customers and orders table
  * JOIN ORDERS (iNNER JOIN)
  * CITY,quantity, unit price, quantity
  * on completed sales 	
  * */
 select distinct c.city , round(SUM(o.quantity * unit_price *(1-discount/100.0)),2) as total_spent
 from customers c 
 join orders o using (customer_id)
 where o.order_status = 'Completed'
 group by c.city 
 order by total_spent  desc
 Limit 10;

--Q26. Identify customers with more than five orders.
/*customers and orders table
  * JOIN ORDERS 
  * customer_name,quantity 	
  * */
select o.customer_id, count(*) total_orders 
from 		orders o 
group by 	o.customer_id 
having 		count (*) >5
order by total_orders  desc;
 -- using a join to include customer_names
select c.customer_id, customer_name, count(*) total_orders
from 	orders o 
join	customers c using (customer_id)
group by c.customer_id , c.customer_name 
having 	count(*) >5
order by total_orders desc;

--27. Calculate average customer spending by segment.
/*customers and orders table
  * JOIN ORDERS 
  * customer_id,customer_segment,quantity, unit price, quantity
  * on completed sales 
  * coalesce to return nulls from customers with 0 orders
  * find sum of total spent by customers
  * divide total spent by total distinct customers to get average per customer	
  * */

 select c.customer_segment ,  
 		count(distinct c.customer_id) as customers,
 		count (distinct o.customer_id) as buyers,
 		sum(o.quantity * unit_price *(1-discount/100.0)) as revenue,
 		round(coalesce (sum(o.quantity * unit_price *(1-discount/100.0)),0)/count(distinct c.customer_id ),2) as avg_total_spent
 from 	customers c 
 left join 	orders o  on c.customer_id = o.customer_id
 			and o.order_status = 'Completed'
 group by 	c.customer_segment 
 order by 	avg_total_spent  desc;
 

--Q28. Identify the most popular category among VIP customers.
 /* customers na d orders tables
  * count of orders, total quantity sold, revenue generated per category
  * completed sales
  * Popular is this case means number of units ordered and sold
  * */
select O.product_category, count(*) as orders, SUM(O.quantity) as units_sold, sum(o.quantity * unit_price *(1-discount/100.0))as VIP_revenue
from orders o 
join customers using (customer_id)
where customer_segment = 'VIP' and o.order_status = 'Completed'
group by o.product_category 
order by orders desc;									-- Home appliances are most popular relative to number of orders placed and sold.
														-- however, its sales revenue are low compared to Mombile phones which rank second by populality


--=================================================### Section D — Subqueries and CTEs (Q29–Q34) ============================================
-- Concepts:* subqueries, `WITH` (CTEs), nested aggregation -----------

--Q29. Find customers spending above the average total spending per purchasing customer.
-- calculate total spending first from completed sales
--Average from the total

with customer_spending as(
	select customer_id, sum(quantity * unit_price * (1-discount/100.0)) as total_spent
	from retail_analytics.orders o 
	where order_status = 'Completed'
	group by customer_id)
select customer_id, total_spent
from customer_spending 
where total_spent > (select avg(total_spent ) from customer_spending)
order by total_spent desc;

--Q30. Find products priced above the overall average unit price.
/*find Avg unit price
 * apply a sub query of the avg to find producst above the unit price. Use it in the 'WHERE' clause
 * */

select distinct product_name, o.unit_price
from  orders o 
where o.unit_price > (select AVG(o.unit_price ) from retail_analytics.orders o )
order by o.product_name   ;

--Q31. Use a CTE to identify the three highest-revenue months.
/* find months and their subsequent revenue on completed sales
 * enclose in a CTE
 * from the CTE pull highest revenue per month
 * limit to 3
 * */

with monthly_rev as (select TO_CHAR(o.order_date, 'YYYY-MM') as month, SUM(o.quantity * unit_price * (1 - discount / 100.0)) as month_revenue
		from retail_analytics.orders o 
		where order_status = 'Completed'
		group by TO_CHAR(o.order_date, 'YYYY-MM')
		order by month_revenue)
select month, max(month_revenue)
from monthly_rev 
group by month, month_revenue  
order by month_revenue  desc
limit 3;

--Q32. Find customers purchasing from at least three categories.

with purchased_categories as (
			select customer_id, count(distinct product_category) as bought_categories
			from orders o 
			where order_status = 'Completed'
			group by o.customer_id)
select customer_name, customer_id, bought_categories
from purchased_categories 
join customers c using(customer_id)
where bought_categories >=3
order by bought_categories desc;

--Q33. Use a CTE to calculate category revenue, cost, profit, and profit margin.
/* 
 * 
 * */

with category_aggregates  as (
		select o.product_category, 
		SUM(quantity*unit_price * (1-discount/100.0))as category_revenue, 
		sum(cost_price*quantity) as category_cost
		from orders o 
		where o.order_status = 'Completed'
		group by o.product_category )
select 	product_category,
		category_revenue,
		category_cost,
		category_revenue - category_cost as profit,
		round(100.0 * (category_revenue - category_cost)/ category_revenue ,2) as profit_margin
from category_aggregates 
order by profit desc;

--Q34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.
/* Look for customers most recent order
 * compare recent order with newest order
 * */
with last_orders as (select customer_id, MAX(order_date) as recent_order_date
			from orders o 
			where order_status = 'Completed'
			group by o.customer_id )
select customer_id, customer_name,
		recent_order_date,
		(select MAX(order_date) from orders o where o.order_status = 'Completed' ) - recent_order_date  as days_after_last_order
		from last_orders 
		join customers c using (customer_id)
		where recent_order_date < (select MAX(order_date) from orders o where o.order_status = 'Completed' ) - 90
		order by last_orders.recent_order_date desc;

---35. Rank customers by spending using `RANK()`.
/* Order table - using customer_id
 * 3 columns needed - Customer_id, total_spending, ranked_spending
 * first get each customers total spending after discount
 * rank the amount spent on purchases with the highest spender coming first (DESC)
 * filter for all completed purchases	
 * GROUP BY customer_id to show one row per customers total spending
 * */
select o.customer_id,
		SUM(quantity*unit_price * (1-discount/100.0))as total_expenditure,
		rank() over(order by SUM(quantity*unit_price * (1-discount/100.0))desc) as expenditure_rank
from orders o 
where order_status = 'Completed'
group by customer_id
order by expenditure_rank;

--Q36. Number each customer's orders by recency using `ROW_NUMBER()`.
/*Orders - customer_id, order_id, order_date(recency - newest)
 * What? numbering customers orders from newest to oldest - i.e most recent order.....
 * Number them 
 * order by order_date and order_id DESC	 To number most recent to oldest and 
 * all orders  either cancelled, pending or completed
 * */

select customer_id, o.order_id ,order_date, 
		row_number() over(partition by customer_id order by order_date desc, order_id desc) as order_recency
from orders o  
order by  order_recency;

--37. Rank products within categories using `DENSE_RANK()`.
/* orders, product_catgory, product_name
 * total sales
 * We rank by sales (revenue generated from each product - from highest to lowest in each category
 * rank 1 is the top product in the category
 * */

select product_category, product_name,  SUM(quantity*unit_price * (1-discount/100.0)) as sales,
		dense_rank() over(partition by product_category order by  SUM(quantity*unit_price * (1-discount/100.0))desc) as category_rank
from orders o 
where o.order_status = 'Completed'
group by product_category, product_name
order by category_rank ;
 
--Q38. Calculate cumulative monthly revenue.
/*Find monthly revenue for each month
 * add running totals revenue that grows month by month (cummulative)
 * Every row  shows total revenue for that month and the previous months
 * */
select to_char(o.order_date , 'yyyy-mm') as month,
		SUM(quantity*unit_price * (1-discount/100.0)) as monthly_sales,
		SUM(SUM(quantity*unit_price * (1-discount/100.0))) over (order by to_char(o.order_date , 'yyyy-mm')) as cumulative_monthly_sales
from orders o
where order_status = 'Completed'
group by to_char(o.order_date , 'yyyy-mm')
order by cumulative_monthly_sales;
-- we group by month, to group totals sales for the month
-- sum(sum(...)) over() - sums up monthly revenue in date order giving cumulative sales

--Q39. Compare monthly revenue using `LAG()`.
/*find the monthly revenue
 * Use LAG() to find previous month revenue on the same row to show
 * 
 * */
select date_trunc('month', order_date ):: date as month,	
		SUM(quantity*unit_price *(1-discount/100.0)) as monthly_revenue,
		lag(sum(quantity*unit_price *(1-discount/100.0))) over (order by date_trunc('month', order_date ) ) as previous_month_revenue
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date )
order by month ;

--Q40. Calculate month-over-month revenue growth (%).
/* get each months revenue and use LAG() to compare monthly growth.
 * subtract the previous from the current multiply by 100 to get pacentage growth.
 * I have used CTE for easier understanding and better visibility of calculations
 * 
 * */

with monthly_growth as (
					select date_trunc('month', order_date):: date as month,
					SUM(quantity*unit_price *(1-discount/100.0)) as month_revenue
			from orders o 
			where o.order_status = 'Completed'
			group by "month" )
	select to_char(month,'YYYY-MM') as month,
			month_revenue,
			lag(month_revenue) over(order by month) as previous_month_revenue,
			round(100.0 *(month_revenue-lag(month_revenue) over(order by month))/ nullif (lag(month_revenue) over(order by month),0),2) as pct_growth
	from monthly_growth
	order by monthly_growth.month;

--41. Divide customers into four spending groups using `NTILE(4)`.
/*total customers spending from completed purchases, sort from highest spender to lowest and group them in 4 equal size groups
 * result:
 * group 1 is the top spenders and group 4 are lowest spenders
 * 
 * */
select customer_id, SUM(quantity*unit_price *(1-discount/100.0)) as total_spending,
		ntile(4) over( order by SUM(quantity*unit_price *(1-discount/100.0))desc)	spending_groups
from orders o 
where o.order_status = 'Completed'
group by o.customer_id 
order by spending_groups, total_spending desc;

--Q42. Calculate each category's share of total revenue using window functions.
/* total revenue for each category
 * divide the total revenue by overall totals (totals for all categories)
 * multiply by 100 to get percentage share
 * revenue comes from completed sales, (order_status = Completed)
 * */

select product_category, SUM(quantity*unit_price *(1-discount/100.0)) as revenue,
		round(100.0* SUM(quantity*unit_price *(1-discount/100.0))/sum(SUM(quantity*unit_price *(1-discount/100.0)))
			over(),2) as pct_share
from orders o 
where order_status = 'Completed'
group by product_category
order by pct_share ;

--================================================### Section F — Advanced business intelligence (Q43–Q46)===========================
-- *Concepts:* views, PL/pgSQL functions, `CASE`, reporting queries---

--Q43. Create a `monthly_sales_summary` view (month, orders, revenue, cost, profit). Then `SELECT` from it.

create or replace view monthly_sales_summary as
		select date_trunc('month', order_date):: date as month,
				count(*) as orders,
				 SUM(quantity*unit_price *(1-discount/100.0)) as revenue,
				 sum(quantity*cost_price) as cost,
				 sum(quantity*unit_price *(1-discount/100.0)) -  sum(quantity*cost_price) as profit
		from orders o
		where order_status = 'Completed'
		group by date_trunc('month', order_date);

select * from monthly_sales_summary
order by month;

--Q44. Create a PostgreSQL function that returns completed-order revenue for a supplied customer ID. Show
    --it working for one customer **and** for an ID that does not exist (it should return 0, not NULL).
-- Understanding - save revenue calculation as a reusable function
--check a customer id and it returns that customers total completed revenue after discount
-- if the ID has no completed orders, or doest not exixst, the result will be 0 instead of Null

create or replace function get_customer_revenue(p_customer_id int)
		returns numeric
		language plpgsql
		as $$
		declare
			v_result numeric;
		begin 
			select sum(quantity*unit_price* (1-discount/100.0))
			into v_result
			from orders o
			where customer_id = p_customer_id
				and order_status = 'Completed';
			return coalesce(round(v_result,2),0);
		end;
$$;
/* calling for 2 different customer_id (56 and 88888)
 * ID 56 returns revenue 251,996
 * ID 88888 returns revenue 0 because the ID does not exist in our records
 * */
select 
	get_customer_revenue(56) as existing_customer,
	get_customer_revenue(88888) as missing_customer;

--Q45. Segment customers into High, Medium and Low Value. **Explain why you chose your thresholds** — for
    --example percentiles, or round KSh amounts based on what the data looks like.
/*Understading - getting each customers total spending and lablelling hgih, medium or low
 * find the spenidng distribution
 * */
with customer_spending as (
	select customer_id,
		sum(quantity*o.unit_price * (1-discount/100.0)) as total_spent
	from orders o 
	where order_status ='Completed'
	group by customer_id),
thresholds as (
			select PERCENTILE_CONT(0.5) within group (order by total_spent) as sp_50,
					percentile_cont(0.8) within group (order by total_spent) as sp_80
			from customer_spending
			)
select cs.customer_id, cs.total_spent,
	case
		when cs.total_spent >= t.sp_80 then 'High Value'
		when cs.total_spent >= t.sp_50 then 'Medium Value'
		else 'low Value'
	end as Value_segment
from customer_spending cs
cross join thresholds t
order by cs.total_spent desc;

/*Why thresholds
 *  - top 20% i.e 80th percentile represenst high spenders. captures high value product buyers such as TVs, fridges, laptops etc
 *  - 30% - Medium - between 50-80th percentile separates above typical and below typical spenders. 
 *  - 50% - bottom = replesents low spenders - 
 * 
 * Why percentiles
 * They guarantee  balanced split based on our data
 * */

--Q46. Produce a management report: the top five customers, top five products, the most profitable
    --category, and the lowest-revenue month.

-- TOP 5 CUSTOMERS
-- select base on spening

select c.customer_id, c.customer_name, c.city , 
		count(*) orders , 
		sum(quantity*unit_price * (1-discount/100.0)) as purchases_value
from orders o
join customers c using (customer_id)
where o.order_status = 'Completed'
group by c.customer_id , c.customer_name ,c.city 
order by purchases_value desc
limit 5;

/* Brian Chebet of ID 19, leads the top 5 customers with a purchases worth sh/848,118.75.
 * She is followed by Peter, lucy, Nancy and Purity whose purches are above sh.690,000 
 * Three come from Nairobi. 1 from Eldoret, and  1 from Mombasa, trading on iphone 13 and Laptops. Premium-device stock and loyalty offers should target them.
 * */

-- Top 5 products
-- quantity and revenue

select o.product_name , count(*) orders,sum(quantity) as unit_sold, sum(quantity*unit_price * (1-discount/100.0)) as revenue
from orders o
where o.order_status = 'Completed'
group by o.product_name 
order by revenue desc
limit 5;

/*iPhone 13 leads as the best selling product with a revenue above sh.3m, 36 orders and 45 units sold for the account period. 
 * Hp250 G9 Laptop, Hoptpoint Refrigerator, lenovo ideapad 3 and Samsung 55in smart TV follows, with all maing revenues above sh.1.8m. 
 * increassing stock of these products significant relative to units sold and revenue generated
 * */

-- Most profitable category

with category_totals as (select product_category, 
		sum(quantity*unit_price * (1-discount/100.0)) as revenue,
		sum(quantity*cost_price) as cost 
		from orders o
		where o.order_status = 'Completed'
		group by o.product_category)
select product_category,
		revenue,
		cost,
		SUM(revenue-cost) as profit,
		round(100.0* (revenue - cost)/ct.revenue,2) as profit_margin
		from category_totals  ct 
		group by ct.product_category , ct.revenue ,ct."cost" 
		order by profit desc;

/*Mobile phones are best selling category earning sh.728,760.65 in profit, and a margin 10.5% of the otal revenue.
 * Accesories are by far in margin at 42.39% althoug they have the lowest profit compared to other categories. 
 * Electronics have the thiniest margin of 9.9% despite coming second in both profit and revenue generation.
 * */
-- Lowest revenue month

select count(*) as orders, to_char(date_trunc('month', order_date), 'YYYY-Month')  as month,
		sum(quantity * o.unit_price  * (1-discount/100.0)) as revenue
from orders o 
where o.order_status = 'Completed'
group by date_trunc('month', order_date) 
order by revenue asc
limit 5;

/*January 2026 is the lowest perfoming month with a revenue of sh. 322,432.95 from 14 completed sales only. 
 * February 2025 comes second with sh. 369,565.6 in revenue, followed by January 2025 with, sh.434,902.7, April 2025 sh.632,642.9, and May 2025 with sh.682,628.6.
 *  
 * */
select SUM(quantity*unit_price* (1-discount/100.0)) as revenue
from orders o 
where o.order_status = 'Completed' ;

select SUM(quantity*unit_price* (1-discount/100.0))-sum(quantity*cost_price) as profit
from orders o
where o.order_status = 'Completed' ;
		

select * from customers c ;
select * from orders o ; 
