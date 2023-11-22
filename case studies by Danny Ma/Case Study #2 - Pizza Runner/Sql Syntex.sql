use pizza_runner

create temporary table dasda
(
SELECT order_id,runner_id,
case when pickup_time like "%null%" then null else pickup_time end as pickup_time,
case when distance like "%null%" then null else distance end as distance,
case when duration like "%null%" then null else duration end as duration,
case when cancellation like "%null%" then null else cancellation end as cancellation
from pizza_runner.runner_orders
)
select * from dasda

