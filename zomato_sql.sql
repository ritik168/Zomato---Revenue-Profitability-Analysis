-- Now Create the Order Table

create table orders
(order_id integer primary key,
customer_id numeric,
restaurant_id numeric,
order_datetime timestamp,
order_value decimal(10,2),
discount_amount decimal(10,2),
delivery_fee numeric,
commission_pct decimal(10,2),
operational_cost decimal(10,2)
);

drop table if exists zomato

-- Now create the Customers Table

create table customers
(customer_id numeric primary key,
city varchar(100)
);

-- Now create the Restaurants Table

create table restaurants
(restaurant_id numeric primary key,
city varchar(100),
cuisine varchar(100)
);

select * from orders
select * from restaurants
select * from customers


--Business Problem

--Q.1 Find total orders, gross revenue & net revenue.

select * from orders

select 
count(*) as total_orders,
sum(order_value) as gross_revenue,
sum(order_value-discount_amount) as net_revenue
from orders;

--Q.2 Monthly revenue trend

select * from orders

select extract(month from order_datetime) as month,
sum(order_value-discount_amount) as net_revenue,
count(*) as total_orders
from orders
group by month
order by month asc;


--Q.3 Top 10 cities by revenue.

select * from orders
select * from restaurants

select r.city,sum(o.order_value-o.discount_amount) as city_revenue
from orders o
join restaurants r using (restaurant_id)
group by r.city
order by city_revenue desc
limit 10;

--Q.4 Calculate contribution margin for each order

select * from orders
select order_id,
(order_value-discount_amount) as net_revenue,
(order_value-discount_amount) * commission_pct as commission_fee,
delivery_fee,
operational_cost,
(order_value-discount_amount)-((order_value-discount_amount) * commission_pct+delivery_fee+operational_cost) as avg_contribution
from orders;

--Q.5 Average contribution margin across all orders

select 
avg(order_value-discount_amount)-((order_value-discount_amount) * commission_pct+delivery_fee+operational_cost)
as avg_contribution
from orders
group by order_value,discount_amount,commission_pct,operational;


--Q.6 Top 10 restaurants by profit (contribution).



SELECT  o.restaurant_id, SUM(
(order_value - discount_amount) - ((order_value - discount_amount) * commission_pct + delivery_fee + operational_cost) ) AS total_contribution
FROM orders o
GROUP BY o.restaurant_id
ORDER BY total_contribution DESC
LIMIT 10;

--Q.7 Identify loss-making restaurants (negative contribution)

select restaurant_id,
sum(order_value-discount_amount)-((order_value-discount_amount)*commission_pct+delivery_fee+operational_cost)
as contribution
from orders
group by restaurant_id,order_value,discount_amount,commission_pct,delivery_fee,operational_cost
having
sum(
(order_value-discount_amount)-((order_value-discount_amount)*commission_pct+delivery_fee+operational_cost)
) <0;


--Q.8 Customer lifetime value (LTV).

select customer_id,
sum(order_value-discount_amount) as lifetime_value,
count(*) as total_orders
from orders
group by customer_id
order by lifetime_value desc
limit 20;

--Q.9 Average order value (AOV) by city.

select r.city,
round(avg(o.order_value),2) as avg_order_value
from orders o
join restaurants r using(restaurant_id)
group by r.city
order by avg_order_value desc;

--Q.10 Distribution of discounts (how many orders get discount)

select 
case 
when discount_amount=0 then 'no discount'
when discount_amount<50 then '<50'
when discount_amount between 50 and 150 then '50-150'
else '>150'
end as discount_range,
count(*) as total_orders
from orders 
group by discount_range
order by total_orders desc;

--Q.11 Distance vs Delivery Fee Buckets

select * from orders
select * from customers
select * from restaurants
SELECT 
width_bucket(distance_km, 0, 20, 5) AS distance_group,
AVG(delivery_fee) AS avg_delivery_fee,
COUNT(*) AS orders
FROM orders
GROUP BY distance_group
ORDER BY distance_group;


--Q.12 Top cuisines by total revenue

select 
r.cuisine,
sum(o.order_value-o.discount_amount) as revenue
from orders o
join restaurants r using(restaurant_id)
group by r.cuisine
order by revenue desc;


