    ### 1. What is the total amount each customer spent at the restaurant?
    
  ```sql
  WITH GROUPS AS (
  SELECT user_id,
  login,
  login_date,
    ROW_NUMBER() OVER(PARTITION BY user_id order by login_date) - ROW_NUMBER() OVER(PARTITION BY user_id, LOGIN order by login_date asc) as grp
  FROM LOGINS
),  
login_ranks as (
  SELECT user_id,
    COUNT(*) AS most_consecutive_logins,
    ROW_NUMBER() OVER(partition by user_id ORDER BY count(*) desc) as rnk
  FROM GROUPS
  where login = 'success'
  GROUP BY user_id,
    GRP
  )
SELECT user_id,
  most_consecutive_logins
FROM LOGIN_RANKS
WHERE RNK = 1
```
