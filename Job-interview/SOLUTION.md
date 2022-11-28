## Solution

View the complete syntax [here]().

***
Write a query that returns the following results including all registered agents with over 30 conversations and includes answers for sections a-g for each one of them (one query for all sections). 

- a.	Agent id
- b.	Number of conversations
- c.	Number of conversations with technique_efficiency > 70% 
- (technique_efficiency = total suggestion_clicked in the conversation/ total suggestion_viewed in the conversation)
- d.	Most frequent last sentiment score
- e.	Average conversation_usage
  (usage = messages with at least one suggestion clicked in the conversation / total number of messages in a conversation)
- f.	Number of unique event_name used
- g.	Last chat date

***

###  a.	Agent id
###  b.	Number of conversations

````sql
WITH 
-- a and b
NumOfCon as
(
select c.agent_id,[num of con]=count(c.conversation_id)
from Conversations as c 
group by c.agent_id
),

````
#### Steps:
- **Group by** and **count** to find out ```[num of con]``` by each agent.

#### Answer:
| agent_id | num of con |
| -------- | ----------- |
|677|2|
|679|7|
|685|4|
|701|2|
|719|3|
***

### C.Number of conversations with technique_efficiency > 70% 

#### PLAN: 
- 1.Add Calculated fields to table converstion with num of ```SUGGESTION_CLICKED``` and ```SUGGESTION_VIEWED``` (table)
- 2.Add Calculated fields ```EFFICNY```= S```UGGESTION_CLICKED```/```SUGGESTION_VIEWED```(table)
- 3.Filttering efficny adove 70% (table)

````sql
SUGGESTION as
(
select c1.agent_id,c1.conversation_id,
clicked= (
          select count(*)
	        from Conversations as c2 join Events as e on e.conversation_id=c2.conversation_id
	        where (c2.agent_id = c1.agent_id) and e.event_type = 'SUGGESTION_CLICKED' and c2.conversation_id=c1.conversation_id
           ),
viwed= (
         select count(*)
	       from Conversations as c2 join Events as e on e.conversation_id=c2.conversation_id
	       where (c2.agent_id = c1.agent_id) and e.event_type = 'SUGGESTION_VIEWED' and c2.conversation_id=c1.conversation_id
           ) 
from Conversations as c1 
group by c1.agent_id,c1.conversation_id
),
````
#### Steps:
- Passing Parmter for each agent and converstion count how many events with SUGGESTION_CLICKED/SUGGESTION_VIEWED
- 
#### Answer:
|agent_id|conversation_id|viwed	|clicked|
| ----------- | ----------- |----------- |----------- |
|685|	17030585|0|0|
|677|	17031898|5|2|
|685|	17032522|4|6|
|677|	17032548|0|0|


````sql
EFFINCY as
(
	select * , 
	eff= case
	     when s.clicked = 0 then 0
		 else CAST(s.clicked as decimal (5,2))/ CAST(s.viwed as decimal)
		 end
	from SUGGESTION  as s
)
````
#### Steps:
- USING CAST(s.clicked as decimal) to dived 2 int

#### Answer:
|agent_id	|conversation_id	|clicked	|viwed	|eff|
| ------- | ------- | -------  | ------- | ------- |
|685|	17030585|	0|	0	|0.000|
|677|	17031898|	2|	5	|0.400|
|685|17032522|	6|	4	|1.500|
|677|	17032548|	0|	0|	0.00|

````sql
EFFINCYBYAGENT as
(
	select e.agent_id,[eff con]=count(*)
	from EFFINCY as e 
	where e.eff >0.7
	group by e.agent_id
),
````
#### Steps:
- count converstion adove 0.7 **(when)** for each **(group)** agent

#### Answer:
|agent_|eff con |
| ------- | ------- |
|685|1|

***
###  D.Most frequent last sentiment score

#### Steps:
-**Rank** the rate of the score that evrey agent got using WINDOWS FUNCTION

````sql
FREQRANK as
(
    select c.agent_id,c.The_sentiment_of_the_last_message_score, [rank]= dense_rank()over(partition by c.agent_id order by count(c.The_sentiment_of_the_last_message_score) desc)
	from Conversations  as c
	group by c.agent_id,c.The_sentiment_of_the_last_message_score
)
````

#### Answer:
|agent_id	|The_sentiment_of_the_last_message_score|	rank|
| ------- | ------- | ------- |
|677|	-1|	1|
|677	|2|	1|
|679|	2|	1|
|679	|0	|1|
|679	|1	|1|
|679	|-2|	|2|

-TO Retrive the most freq 
````sql
TOPFREQRANK as
(
  select *
  from FREQRANK
  where rank=1
),
````
***



