# 🍜 Case Study #1: Danny's Diner

<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## 📚 Table of Contents

- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)

***

## Business Task

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

## Case Study Questions

<details>
<summary>
Click here to expand!
</summary>

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    
    # 
    
    View the complete syntax here.
    
    ---
    
    ### 1. What is the total amount each customer spent at the restaurant?
    
    ```sql
    select s.customer_id , spend=sum(me.price)
    from   sales as s join menu as me on me.product_id= s.product_id
    group by s.customer_id 
    ```
    
    #### Steps:
    - **join** `sales` and `menu` to get sales price.
    - **Group by** and **SUM** to find out `spend` by each customer.
    
    #### Answer:
    
    | customer_id | total_sales |
    | ----------- | ----------- |
    | A           | 76          |
    | B           | 74          |
    | C           | 36          |
    
    - Customer A spent $76.
    - Customer B spent $74.
    - Customer C spent $36.
    
    ---
    
    ### 2. How many days has each customer visited the restaurant?
    
    ```sql
    select s.customer_id , visits = count (DISTINCT s.order_date)
    from   sales as s
    group by s.customer_id 
    ```
    
    #### Steps:
    
    - Using **DISTINCT** and **Count** to find out `visit_count`
    - I used distinct to avoided double counting: when a customer bought several products on the same day
    
    #### Answer:
    
    | customer_id | visit_count |
    | ----------- | ----------- |
    | A           | 4           |
    | B           | 6           |
    | C           | 2           |
    
    - Customer A visited 4 times.
    - Customer B visited 6 times.
    - Customer C visited 2 times.
    
    ---
    
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
    ```
    
    #### Steps:
    
    - Use **Passing Parameters** method for each customr take only the product which them order date `s1.order_date` is `min(s2.order_date)`
    
    #### Answer:
    
    | customer_id | product_name |
    | ----------- | ------------ |
    | A           | curry        |
    | A           | sushi        |
    | B           | curry        |
    | C           | ramen        |
    
    - Customer A's first orders are curry and sushi.
    - Customer B's first order is curry.
    - Customer C's first order is ramen.
    
    ---
    
    ### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
    
    ```sql
    select top 1 x.product_name , x.num
    from ( select m.product_name ,num=COUNT(*)
           from sales as s join menu as m on s.product_id=m.product_id
             group by m.product_name
            ) as x 
    order by x.num desc
    ```
    
    #### Steps:
    
    - Using **Nested Querie** output **table** to crete temporary table repsants each product and number of time has been purchased (`x`)
    - Using **TOP** and **ORDER BY desc** to retrieve the first line. viz the item has beeen has been purchased mostly.
    - Using **Group by** and **COUNT( )** to find out how many time each item has been purchased.
    
    #### Answer:
    
    | most_purchased | product_name |
    | -------------- | ------------ |
    | 8              | ramen        |
    
    - Most purchased item is ramen - 8 times.
    
    ---
    
    ### 5. Which item was the most popular for each customer?
    
    ```sql
    select  x.customer_id,x.product_name 
    from 
    (
    select  s.customer_id ,m.product_name,[rank]=dense_rank()over (partition by s.customer_id order by count(s.product_id) desc)
    from menu as m right join sales as s on m.product_id=s.product_id
    group by s.customer_id ,m.product_name
    )
    as x
    where rank=1
    ```
    
    #### Steps:
    
    - Using **Nested Querie** output **table** to crete temporary table,For each customer, how many products did he/she purchase of each type (`x`)
    
    - Using **WINDOWS FUNCTION** `dense_rank()` to find out the number of purchases
    
    - #### Answer:
      
      | customer_id | product_name |
      | ----------- | ------------ |
      | A           | ramen        |
      | B           | sushi        |
      | B           | curry        |
      | B           | ramen        |
      | C           | ramen        |
    
    ---
    
    ### 6. Which item was purchased first by the customer after they became a member?
    
    ```sql
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
    ```
    
    #### Steps:
    
    - Using FROM **Nested Querie** output **table** to crete temporary table,For each customer rate the product has been purchased by (`x`)
    - Using **WINDOWS FUNCTION** `dense_rank()` to rank
    - Using Where to retrive the first iten
    
    #### Answer:
    
    | customer_id | product_name |
    | ----------- | ------------ |
    | A           | curry        |
    | B           | sushi        |
    
    - Customer A's first order as member is curry.
    - Customer B's first order as member is sushi.
    
    ---
    
    ### 7. Which item was purchased just before the customer became a member?
    
    ```sql
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
    ```
    
    #### Steps:
    
    - Using WHERE **Nested Querie** output **LIST** , in order to choose from the desired values
    - Use **Passing Parameters** method for each customr take only the orders which them order date is latter then join date `where (m1.customer_id=m2.customer_id) and (m1.join_date>s2.order_date)`
    - Using `Top 1` to retrive the first product.
    - NOTE: I could use the same method as i used at section 6
    
    #### Answer:
    
    | customer_id | order_date | product_name |
    | ----------- | ---------- | ------------ |
    | A           | 2021-01-01 | sushi        |
    | A           | 2021-01-01 | curry        |
    | B           | 2021-01-04 | sushi        |
    
    - Customer A’s last order before becoming a member is sushi and curry.
    - Whereas for Customer B, it's sushi. That must have been a real good sushi!
    
    ---
    
    ### 8. What is the total items and amount spent for each member before they became a member?
    
    ```sql
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
    ```
    
    #### Steps:
    
    | customer_id | num | Total_sales |
    | ----------- | --- | ----------- |
    | A           | 2   | 25          |
    | B           | 2   | 40          |
    
    Before becoming members,
    
    - Customer A spent $ 25 on 2 items.
    - Customer B spent $40 on 2 items.
    
    ---
    
    ### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
    
    ```sql
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
    ```
    
    #### Steps:
    
    #### Answer:
    
    | customer_id | points |
    | ----------- | ------ |
    | A           | 860    |
    | B           | 940    |
    | C           | 360    |
    
    - Total points for Customer A is 860.
    - Total points for Customer B is 940.
    - Total points for Customer C is 360.
    
    ---
    
    ### 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
    
    ### not just sushi - how many points do customer A and B have at the end of January?
    
    ```sql
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
    ```
    
    #### Steps:
    
    #### Answer:
    
    | customer_id | total_points |
    | ----------- | ------------ |
    | A           | 1370         |
    | B           | 820          |
    
    - Total points for Customer A is 1,370.
    - Total points for Customer B is 820.
    
    ***a
    
    </details>

***
