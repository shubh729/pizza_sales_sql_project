-- Retrieve the total number of orders placed.

SELECT count(order_id) as total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales.

select sum((od.quantity * p.price)) as total_revenue from order_details od 
join pizzas p on p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.

select pt.name, p.price from pizzas p join pizza_types pt on p.pizza_type_id=pt.pizza_type_id 
order by price desc limit 1;

-- Identify the most common pizza size ordered.

select p.size, count(od.order_details_id) as order_count from pizzas p join order_details od on p.pizza_id= od.pizza_id 
group by p.size order by order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.

select pt.name, sum(od.quantity) as order_quantity from pizzas p join order_details od on p.pizza_id=od.pizza_id join pizza_types pt on
pt.pizza_type_id=p.pizza_type_id group by pt.name  order by order_quantity desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,
sum(order_details.quantity) as quantity from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details. pizza_id = pizzas. pizza_id
group by pizza_types. category order by quantity desc;

-- Determine the distribution of orders by hour of the day.

SELECT HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0) from (select orders.order_date, sum(order_details. quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id group by orders.order_date) as order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types. category,
round(sum(order_details.quantity * pizzas.price) / (SELECT
ROUND(SUM(order_details.quantity * pizzas.price),
2) AS total_sales
FROM
order_details
JOIN
pizzas ON pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types. category order by revenue desc;


-- Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue from (select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category, pizza_types.name, sum((order_details.quantity) * pizzas.price) as revenue from pizza_types join pizzas on pizza_types.pizza_type_id =pizzas.pizza_type_id join order_details
on order_details. pizza_id = pizzas.pizza_id
group by pizza_types. category, pizza_types.name) as a) as b
where rn<=3;
