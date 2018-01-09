# Project4


Project member:
Shang Wang 81083355
Jingyi Ding 69364001

Has a list to store all tweets.
Has a Map to store all tweets for all users. Actually the same tweets but store in different data structure because of some time out problem.


How to use:
The first argument is the number of clients. Like 500 1000 or ..
The second argument is the query type. The same query will perform every 5 secs. You can type: querymention, queryhashtag, queryretweet, querysubscribe
The third argument is the target query object. Like client1, client2 will be a valid object for querymention.
Z will be a valid object for queryhashtag. Every character will be fine for queryretweet because it will return
all retweets in the system. client11@gmail.com will be a valid input for querysubscribe.

The input range for each command:
querymention: client1 to clientn    n is the number of the max client number. If you input 1000 users the range will be client1 to client1000       You dont need to enter @.       
Ex. project4 1000 querymention client1000
queryhashtag: 0~9 A~Z a~z. You dont need to enter #.
Ex. project4 1000 querymention Z
queryretweet: 
Ex. project4 1000 queryretweet 0
querysubscribe: You need to type the email address. The email address format is from client1@gmail.com to clientn@gmail.com
Ex.project4 1000 querysubscribe client10@gmail.com


Test case
10% users are randomly connect and disconnect in every milisecond.
1 query every 5 sec.
tweet and retweet send every 1 milisecond.

project4 500 querymention client10
Performance:
"80 tweets found in total 47412 tweets"
"Time spent 101s"
Max tweets allowed: Can run at least 320 thousand tweets. Didnt test more.
"659 tweets found in total 320405 tweets"   

project4 2000 querymention client10
2000 users.
Performance:
"Time spent 100s"
"25 tweets found in total 31986 tweets"
Max tweets allowed: (at least)
"145 tweets found in total 315979 tweets"

project4 5000 querymention client10
5000 users
Performance:
"Time spent 100s"
"3 tweets found in total 19280 tweets"

project 7000 querymention client10
time out :D

project4 10000 querymention client10
Time out XD
