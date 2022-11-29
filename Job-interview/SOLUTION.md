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
1. Add Calculated fields to table converstion with num of ```SUGGESTION_CLICKED``` and ```SUGGESTION_VIEWED``` (table)
2. Add Calculated fields ```EFFICNY```= ```SUGGESTION_CLICKED```/```SUGGESTION_VIEWED```(table)
3. Filttering efficny adove 70% (table)

#### 1: auxiliary calculations
#### Steps:
- **Passing Parmter** for each agent and converstion count how many events with SUGGESTION_CLICKED/SUGGESTION_VIEWED

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
#### Answer:
|agent_id|conversation_id|viwed	|clicked|
| ----------- | ----------- |----------- |----------- |
|685|	17030585|0|0|
|677|	17031898|5|2|
|685|	17032522|4|6|
|677|	17032548|0|0|

#### 2: eff calculations

#### Steps:
- USING **CAST**(s.clicked as decimal) to dived 2 int

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


#### Answer:
|agent_id	|conversation_id	|clicked	|viwed	|eff|
| ------- | ------- | -------  | ------- | ------- |
|685|	17030585|	0|	0	|0.000|
|677|	17031898|	2|	5	|0.400|
|685|17032522|	6|	4	|1.500|
|677|	17032548|	0|	0|	0.00|


#### 3:each one "real" efficny
#### Steps: 
- **count** converstion adove 0.7 **(when)** for each **(group)** agent

````sql
EFFINCYBYAGENT as
(
	select e.agent_id,[eff con]=count(*)
	from EFFINCY as e 
	where e.eff >0.7
	group by e.agent_id
),
````

#### Answer:
|agent_|eff con |
| ------- | ------- |
|685|1|

***

###  D.Most frequent last sentiment score

#### Steps:
-**Rank** the rate of the score that evrey agent got using **WINDOWS FUNCTION**

````sql
FREQRANK as
(
    select c.agent_id,c.The_sentiment_of_the_last_message_score, 
    [rank]= dense_rank()over(partition by c.agent_id order by count(c.The_sentiment_of_the_last_message_score) desc)
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

To retrive the most freq 

````sql
TOPFREQRANK as
(
  select *
  from FREQRANK
  where rank=1
),
````
#### Answer:
only with rank 1
***

###  E.	Average conversation_usage
(usage = messages with at least one suggestion clicked in the conversation / total number of messages in a conversation)

#### Steps:
- Using suggestion from chapter C to filter only converstion with 0>clicked
- **passing parmeter** for each con get the total number of messages in a conversation '''(max(e.message_number))'''

````sql
conversation_usage as
(
  select s.agent_id,s.conversation_id,s.clicked,
  usage =   CAST(s.clicked as decimal (5,2)) /CAST(
						( 
					     	select max(e.message_number)
					        from  Events as e
					        where e.conversation_id = s.conversation_id
						)
						s decimal (5,2))
  from SUGGESTION as s
  where s.clicked>0
),
````

#### Answer:
| agent_id|  conversation_id|  clicked|   usage| 
| ------- | ------- | ------- |------- |
| 677| 	17031898| 2|0.25000000| 
| 685| 	17032522| 6|0.75000000

To retrive avg 

````sql
AVGconversation_usage as
(
  select cs.agent_id, avg_usage = avg(cs.usage)
  from conversation_usage as cs
  group by cs.agent_id
)
````

#### Answer:
same

***

### F.	Number of unique event_name used

#### PLAN:
1. calculted field - each agent and events how many events have the same name with other agent
-  **Passing Parmter** for each agent and event name count how many events with same name and other agent
-  **having** after the agregation i am intersting only by the evnts name with uniqe

2. **count** how many uniqe name each agent have

#### 1: calculted field
````sql
unikename as
(
select c1.agent_id,e1.event_name,
x=               (
                 select count(*)
				 from  Conversations as c2 join Events as e2 on e2.conversation_id=c2.conversation_id
				 where c1.agent_id<>c2.agent_id and e1.event_name = e2.event_name 
				)
from Conversations as c1 join Events as e1 on e1.conversation_id=c1.conversation_id
where e1.event_name is not null
group by c1.agent_id,e1.event_name

having 0 =      (
                 select count(*)
				 from  Conversations as c2 join Events as e2 on e2.conversation_id=c2.conversation_id
				 where c1.agent_id<>c2.agent_id and e1.event_name = e2.event_name 
				)
),
````
|agent_id|	event_name|	x|
| ------- | ------- | ------- |
|677|	action	|0|
|677|	apology	|0|
|677|	closing	|0|
|685|	help	|0|
|677|	subscription|	0|
|685|	welcome	|0|

#### 2: count
````sql
numofunike as
(
  select unikename.agent_id,  num=count(unikename.x)
  from unikename 
  group by unikename.agent_id
),
````
#### Answer:
| agent_id| 	num| 
| ------- | ------- | 
| 677	| 4| 
| 685	| 2| 

***

###  G.Last chat date

#### Steps:
-**FIRST_VALUE** to get first date_time for each agent

````sql
lastchat as
(
	select distinct agent_id,con= FIRST_VALUE(c.date_time) OVER (PARTITION BY c.agent_id ORDER BY c.date_time desc)  
	from Conversations as c
)
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

***

###  SUMMRY

#### Steps:
- **left join** to keep all the agent 
- **isnull** avoiding null
- **stuff** to to stuff all the rows to one row


````sql
select 
	NumOfCon.agent_id,
	NumOfCon.[num of con],
	[EFFICANT CONV] =   ISNULL(EFFINCYBYAGENT.[eff con],0),
	stuff((SELECT '; ' + cast (The_sentiment_of_the_last_message_score as varchar)
           from TOPFREQRANK
		   where TOPFREQRANK.agent_id=NumOfCon.agent_id
           FOR XML PATH('')), 1, 1, '')[TOP FREQ GRADE],
	AVGconversation_usage.avg_usage,
	[num of unkie name] = ISNULL(numofunike.num,0),
	lastchat.con
from NumOfCon left join EFFINCYBYAGENT on NumOfCon.agent_id = EFFINCYBYAGENT.agent_id
                   join AVGconversation_usage on  NumOfCon.agent_id = AVGconversation_usage.agent_id 
		      left join numofunike ON numofunike.agent_id = NumOfCon.agent_id
			  left join lastchat on lastchat.agent_id = NumOfCon.agent_id
````
#### Answer:
agent_id	num of con	EFFICANT CONV	TOP FREQ GRADE	avg_usage	num of unkie name	con
677	2	0	 -1; 2	0.25000000	4	2021-09-02 23:45:00.0000000
679	7	0	 2; 0; 1	NULL	0	2021-09-02 23:04:00.0000000
685	4	1	 1	0.75000000	2	2021-09-02 23:44:00.0000000
701	2	0	 0; 2	NULL	0	2021-09-02 00:27:00.0000000
719	3	0	 2; -2; 1	NULL	0	2021-09-02 16:55:00.0000000
***





