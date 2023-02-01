#Q1.1 and Q1.2
#The total number of trips for the year of 2016 and 2017
#By the definition of trip date as general I choose the start date as the date for the trips because that's when the service starts and also 
#that's the time that customer decides to use the service.

SELECT  year(start_date) as Year, count(start_date) as Number_of_trips
from trips
group by Year;
#--------------------------------------------------------------------------------------
#1.3: The total number of trips for the year of 2016 broken down by month
#I used MONTHNAME function to have the name of the month instead of the number 
#and have a better result and vizualization
#I count all the trips done in 2016 by counting start date as I explained before
#and the result will be shown in the gouping of month
SELECT MONTHNAME(STR_TO_DATE(Month(start_date), '%m')) as month,
count(start_date) as Number_of_trips
from trips
where year(start_date) like 2016
group by month;

#----------------------------------------------------------------------------------------- 
#1.4: The total number of trips for the year of 2017 broken down by month
#the same as previous query but for the year 2017
SELECT MONTHNAME(STR_TO_DATE(Month(start_date), '%m')) as month,
count(start_date) as Number_of_trips
from trips
where year(start_date) like 2017
group by month;

#--------------------------------------------------------------------------------------------------------------------
#1.5:The average number of trips a day for each year-month combination in the dataset
#In order to not getting a full group by error,I have to use subquery here
#In the t1 table I calculated the numer of trips by counting start dates and for the total I selected
#just the days that bixi was in service not the whole month days so the I used count distinct method
#finally in the main query I calculated the average which was already grouped by Monthyear
#for the monthyear I used the ectract year_month function
#I also rounded the average number to 
select MonthYear, t1.Number_of_trips,round((Number_of_trips)/total) as ave_tripsperday
from  (SELECT extract(year_month from start_date) as MonthYear ,
count(start_date) as Number_of_trips, count(distinct(start_date)) as total
from trips
group by MonthYear) as t1;


#-------------------------------------------------------------------------------------------------------------------
#1.6:Save your query results from the previous question (Q1.5) by creating a table called working_table1
Drop table  if exists working_table1;
CREATE TABLE working_table1 as SELECT MonthYear, t1.Number_of_trips,round((Number_of_trips)/total) as ave_tripsperday
from  (SELECT extract(year_month from start_date) as MonthYear ,
count(start_date) as Number_of_trips, count(distinct(start_date)) as total
from trips
group by MonthYear) as t1;

#--------------------------------------------------------------------------------------------------------------------
#Q2
#2.1: The total number of trips in the year 2017 broken down by membership status (member/non-member).
#1 is for members and 0 is for non members
#let's count and then group by membership
SELECT  count(start_date) as numbertrips, is_member
from trips
where year(start_date)=2017
group by is_member;

#2.2 The percentage of total trips by members for the year 2017 broken down by month.
#total is the total trips done in the month
#I use the count and if for counting the trip done by members
#I also use subquery to prevent the error of full group by mode
SELECT total, month, (number/total)*100 as percent 
from
(select COUNT(IF(is_member = 1, 1, NULL)) as number,count(start_date) as total,
 MONTHNAME(STR_TO_DATE(Month(start_date), '%m')) as mont
from trips
where year(start_date)=2017
group by mont)
as t1
group by mont;




#Q4
#4.1 What are the names of the 5 most popular starting stations?
#to get the stations name I joined the two tables 
SELECT stations.name, count(id) as totaltrips
from trips
inner join stations on trips.start_station_code=stations.code
group by name 
order by totaltrips DESC Limit 5;

#4.2 Solve the same question as Q4.1, but now use a subquery. 
#Is there a difference in query run time between 4.1 and 4.2? Why or why not?
#this code runs faster because first it selects and then join the desired data 

select stations.name, table1.totaltrips
from
(SELECT trips.start_station_code, count(id) as totaltrips
from trips
group by start_station_code 
order by totaltrips DESC Limit 5) as table1
Join stations on stations.code=table1.start_station_code;

#Q5
#5.1 How is the number of starts and ends distributed for the station Mackay / de Maisonneuve throughout the day?
#I used join for the counting the station and also use a subquery inside a subquer to avoid getting group by error
#and then I join this whole table to a table like itself which is for endtime of day
select startnumber,endnumber,stime_of_day,etime_of_day
from (select count(if(m.code=trips.start_station_code,1,NULL)) as Startnumber,
case 
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS "stime_of_day"
from 
(select *
from stations
where name like 'Mackay / de Maisonneuve') as m
 join trips on 
 m.code=trips.start_station_code
 group by stime_of_day) as n
join  (select count(if(l.code=trips.end_station_code,1,NULL)) as Endnumber,
case
       WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS "etime_of_day"
from 
(select *
from stations
where name like 'Mackay / de Maisonneuve') as l
 join trips on 
 l.code=trips.end_station_code
 group by etime_of_day) as o
 on n.stime_of_day=o.etime_of_day;
 
 #Q6
 #6.1:  write a query that counts the number of starting trips per station.
 #whith use of count id and group by I count the trips of each station then join with
 #station table to find out each station's name
 SELECT count(id) as alltrips , stations.name
 from trips
 join stations on 
 stations.code=trips.start_station_code
 group by stations.name;
 
 
#6.2 write a query that counts, for each station, the number of round trips
#round trips means the start station code is the same as end station code 
#so we add this condition with counting if the codes are the same
#at first I used the where after join but it takes a ling time to run
SELECT COUNT(if(trips.start_station_code=trips.end_station_code, 1 , NULL)) as roundtrips , stations.name
 from trips
 join stations on 
 stations.code=trips.start_station_code
 group by stations.name; 
 
 #6.3 Combine the above queries and calculate the fraction of round trips
 #to the total number of starting trips for each station.
  SELECT stations.name as station, 
  COUNT(if(trips.start_station_code=trips.end_station_code, 1 , NULL)) as roundtrips,
  COUNT(trips.id) as alltrips,
  (100*(count(if(start_station_code=end_station_code, 1 , NULL))))/(count(trips.id)) as percent
  from trips 
  join stations on 
  stations.code=trips.start_station_code
  group by stations.name
  order by percent DESC
  limit 5;
  
  #6.4:Filter down to stations with at least 500 trips originating from them and having at least 10% of their trips as round trips.
  #It's the same as above just add a condition with having to filter after group by
    SELECT stations.name as station, 
  COUNT(if(trips.start_station_code=trips.end_station_code, 1 , NULL)) as roundtrips,
  COUNT(trips.id) as alltrips,
  (100*(count(if(start_station_code=end_station_code, 1 , NULL))))/(count(trips.id)) as percent
  from trips 
  join stations on 
  stations.code=trips.start_station_code
  group by stations.name
  having alltrips >=500 and percent>= 10
  order by percent DESC;
  
  
  
