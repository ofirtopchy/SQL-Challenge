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
| ----------- | ----------- |
|677|2|
|679|7|
|685|4|
|701|2|
|719|3|


***

