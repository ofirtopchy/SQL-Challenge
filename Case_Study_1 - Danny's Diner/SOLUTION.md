# 🍜 Case Study #1: Danny's Diner

## Solution

View the complete syntax [here]().

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
select s.customer_id , spend=sum(me.price)
from   sales as s join menu as me on me.product_id= s.product_id
group by s.customer_id 
````

#### Steps:
- **join** ```sales``` and ```menu``` to get sales price.
- **Group by** and **SUM** to find out ```spend``` by each customer.

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***
### 2. How many days has each customer visited the restaurant?

````sql
select s.customer_id , visits = count (DISTINCT s.order_date)
from   sales as s
group by s.customer_id 
````

#### Steps:
- Using **DISTINCT** and **Count** to find out ```visit_count```
- I used distinct to avoided double counting: when a customer bought several products on the same day

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.
***

### 3.What was the first item from the menu purchased by each customer?

```sql
select  distinct(s1.customer_id), s1.order_date , m.product_name
from sales as s1 join menu as m on m.product_id= s1.product_id
where s1.order_date = (select 
                      [first buy] = min(s2.order_date)
                      from   sales as s2
					  where s1.customer_id = s2.customer_id
                      group by s2.customer_id
					  )
````

#### Steps:
- Use **Passing Parameters** method for each customr take only the product which them order date ```s1.order_date``` is ```min(s2.order_date)```


#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.


***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
select top 1 x.product_name , x.num
from ( select m.product_name ,num=COUNT(*)
       from sales as s join menu as m on s.product_id=m.product_id
	     group by m.product_name
	    ) as x 
order by x.num desc
````

#### Steps:
- Using **Nested Querie** output **table** to crete temporary table repsants each product and number of time has been purchased (```x```)
- Using **TOP** and **ORDER BY desc** to retrieve the first line. viz the item has beeen has been purchased mostly.
- Using **Group by** and **COUNT( )** to find out how many time each item has been purchased.


#### Answer:
| most_purchased | product_name | 
| ----------- | ----------- |
| 8       | ramen |

- Most purchased item is ramen - 8 times. 

***

### 5. Which item was the most popular for each customer?

````sql
select  x.customer_id,x.product_name 
from 
(
select  s.customer_id ,m.product_name,[rank]=dense_rank()over (partition by s.customer_id order by count(s.product_id) desc)
from menu as m right join sales as s on m.product_id=s.product_id
group by s.customer_id ,m.product_name
)
as x
where rank=1
````

#### Steps:
- Using **Nested Querie** output **table** to crete temporary table,For each customer, how many products did he/she purchase of each type (```x```)
- Using **WINDOWS FUNCTION** ```dense_rank()``` to find out the number of purchases 
- 
#### Answer:
| customer_id | product_name |
| ----------- | ---------- |
| A           | ramen        | 
| B           | sushi        | 
| B           | curry        |  
| B           | ramen        | 
| C           | ramen        | 


***


