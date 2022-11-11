----------------------------------------------------------------------------------------------------------------------------------------------------------------
--SQL script for Case study - Week_1
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--DataSet Create 

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
 
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
---------------------------------------------------------------------
--(1)What is the total amount each customer spent at the restaurant?
---------------------------------------------------------------------
select s.customer_id , spend=sum(me.price)
from   sales as s join menu as me on me.product_id= s.product_id
group by s.customer_id 
---------------------------------------------------------------------
--(2)How many days has each customer visited the restaurant?
---------------------------------------------------------------------
select s.customer_id , visits = count (DISTINCT s.order_date)
from   sales as s
group by s.customer_id 
---------------------------------------------------------------------
--(3)What was the first item from the menu purchased by each customer?
---------------------------------------------------------------------

select  distinct(s1.customer_id), s1.order_date , m.product_name
from sales as s1 join menu as m on m.product_id= s1.product_id
where s1.order_date = (select 
                      [first buy] = min(s2.order_date)
                      from   sales as s2
					  where s1.customer_id = s2.customer_id
                      group by s2.customer_id
					  )

--------------------------------------------------------------------------------
--(4) What is the most purchased item on the menu and how many times was it purchased by all customers?
--------------------------------------------------------------------------------
select top 1 x.product_name , x.num
from ( select m.product_name ,num=COUNT(*)
       from sales as s join menu as m on s.product_id=m.product_id
	   group by m.product_name
	 ) as x 
order by x.num desc
--------------------------------------------------------------------------------
--(5)Which item was the most popular for each customer?
--------------------------------------------------------------------------------
select  x.customer_id,x.product_name 
from 
(
select  s.customer_id ,m.product_name,[rank]=dense_rank()over (partition by s.customer_id order by count(s.product_id) desc)
from menu as m right join sales as s on m.product_id=s.product_id
group by s.customer_id ,m.product_name
)
as x
where rank=1
-------------------------------------------------------------------------------
--(6)Which item was purchased first by the customer after they became a member?
--------------------------------------------------------------------------------
select  x.customer_id,x.product_name
from 
(
	   select  s.customer_id ,me.product_name,s.order_date,
       [rank]= DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date)
		from members as m join sales as s on m.customer_id=s.customer_id 
	    join menu as me on me.product_id =s.product_id
		where m.join_date<=s.order_date
)
as x
where rank=1
--------------------------------------------------------------------------------
--(7)Which item was purchased just before the customer became a member?
--------------------------------------------------------------------------------
select  m1.customer_id,s1.order_date,me1.product_name
from    members as m1 join sales as s1 on m1.customer_id=s1.customer_id 
				     join menu as me1 on me1.product_id =s1.product_id
where s1.order_date in 
	(
	  select top 1 s2.order_date
	  from members as m2 join sales as s2 on m2.customer_id=s2.customer_id 
	  join menu as me2 on me2.product_id =s2.product_id
	  where (m1.customer_id=m2.customer_id) and (m1.join_date>s2.order_date)
	  order by s2.order_date desc 
	 )
order by 1 , 2
--------------------------------------------------------------------------------
--(8)What is the total items and amount spent for each member before they became a member?
--------------------------------------------------------------------------------
select  m1.customer_id, [num]=count(distinct me1.product_id),[Total price]= sum(me1.price) 
from    members as m1 join sales as s1 on m1.customer_id=s1.customer_id 
				     join menu as me1 on me1.product_id =s1.product_id
where s1.order_date in 
	(
	  select s2.order_date
	  from members as m2 join sales as s2 on m2.customer_id=s2.customer_id 
	  join menu as me2 on me2.product_id =s2.product_id
	  where (m1.customer_id=m2.customer_id) and (m1.join_date>s2.order_date)
	 )
group by  m1.customer_id 
order by 1 , 2

--------------------------------------------------------------------------------
--(9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
--------------------------------------------------------------------------------
WITH menupoints AS
(
   SELECT *,
   [points]= CASE
				 WHEN product_id = 1 THEN price * 20
				 ELSE price * 10
             END 
   FROM menu
)
select customer_id,sum(menupoints.points)
from sales as s join menupoints on s.product_id = menupoints.product_id
group by s.customer_id

--------------------------------------------------------------------------------
--(10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?
--------------------------------------------------------------------------------
WITH 
DateRange AS
(
   SELECT *, spical= DATEADD(DAY,6,members.join_date)   
   FROM members
),
menupoints AS
(
   SELECT [customer_id]=DateRange.customer_id,
   [points]= CASE
				 WHEN (sales.order_date between DateRange.join_date and DateRange.spical) or menu.product_id = 1
				 THEN price * 20
				 ELSE price * 10
             END 
   FROM menu join sales on sales.product_id=menu.product_id join DateRange on sales.customer_id=DateRange.customer_id
   where month(sales.order_date) = '01' 
)
select menupoints.customer_id,sum(menupoints.points)
from menupoints
group by menupoints.customer_id
