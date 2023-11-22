## Data prefartion

<img title="" src="https://camo.githubusercontent.com/344697ea1f7c893b7967edca36cab41b1b78f48bad62d86d12cbcf516815eeba/68747470733a2f2f387765656b73716c6368616c6c656e67652e636f6d2f696d616765732f636173652d73747564792d64657369676e732f322e706e67" alt="" width="265" data-align="center">

## Table Of Contents

1. [Data Prefration](##Data Prefration)

2. [Business Task} (### Business Task)

## Business Task

<a> id name="Business Task"</a>

## Danny requires assistance to clean the data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

Danny has provided an entity relationship diagram of his database as below:

<img src="https://user-images.githubusercontent.com/148400128/282578601-cb6e6cd5-9f2f-4e8d-91b2-4ebf85d1ac94.png" title="" alt="image" data-align="center">

## Data Prefration

Before you start writing your SQL queries however - you might want to investigate the data, you may want to do something with some of those `null` values and data types in the `customer_orders` and `runner_orders` tables!

<code>create temporary table dasda  
(  
SELECT order_id,runner_id,  
case when pickup_time like "%null%" then null else pickup_time end as pickup_time,  
case when distance like "%null%" then null else distance end as distance,  
case when duration like "%null%" then null else duration end as duration,  
case when cancellation like "%null%" then null else cancellation end as cancellation  
from pizza_runner.runner_orders  
)select * from dasda</code>

</head>
