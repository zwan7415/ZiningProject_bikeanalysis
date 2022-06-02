
-- Aim: Find the diffrent between casual user and members for a bike renting comapny in Chicago USA, increase members sale
--Data Preparation1: fully join all montyly tables into one large yearly table


insert into ZiningProject..[202103-202203-tripdata]
SELECT *
FROM ZiningProject..[202103-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202104-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202105-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202106-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202107-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202108-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202109-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202110-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202111-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202112-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202201-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202202-tripdata]
UNION ALL
SELECT *
FROM ZiningProject..[202203-tripdata]

--Data Preparation2: initially check and found how many null values in each columns:

select SUM (CASE WHEN ride_id is null then 1 else 0 end) as null_col1,
		SUM (CASE WHEN rideable_type is null then 1 else 0 end) as null_col2,
		SUM (CASE WHEN started_at is null then 1 else 0 end) as null_col3,
		SUM (CASE WHEN ended_at is null then 1 else 0 end) as null_col4,
		SUM (CASE WHEN start_station_name is null then 1 else 0 end) as null_col5,
		SUM (CASE WHEN start_station_id is null then 1 else 0 end) as null_col6,
		SUM (CASE WHEN end_station_name is null then 1 else 0 end) as null_col7,
		SUM (CASE WHEN end_station_id is null then 1 else 0 end) as null_col8,
		SUM (CASE WHEN start_lat is null then 1 else 0 end) as null_col9,
		SUM (CASE WHEN start_lng is null then 1 else 0 end) as null_col10,
		SUM (CASE WHEN end_lat is null then 1 else 0 end) as null_col11,
		SUM (CASE WHEN end_lng is null then 1 else 0 end) as null_col12,
		SUM (CASE WHEN member_casual is null then 1 else 0 end) as null_col13

from ZiningProject..[202103-202203-tripdata]

--Data prepration3: checking any unaccept parameter in rideable_type column

SELECT rideable_type
FROM ZiningProject..[202103-202203-tripdata]
group by rideable_type

--Data prepration4: checking any unaccept parameter in member_casual column
SELECT member_casual
FROM ZiningProject..[202103-202203-tripdata]
group by member_casual

--Data prepration5: checking any dublicate parameter in columns with a CTE
WITH CTE(ride_id, 
    started_at, 
    ended_at, 
    dupcount)
AS (SELECT ride_id, 
           started_at, 
           ended_at, 
           ROW_NUMBER() OVER(PARTITION BY ride_id, 
           started_at, 
           ended_at 
		   ORDER BY started_at) AS dupcount
	 FROM ZiningProject..[202103-202203-tripdata])

SELECT *
FROM CTE
where dupcount >1

--Data prepration6: calulate ride time each trips into hrs, rename time related columns, update table for data analysis stpes.
alter table ZiningProject..[202103-202203-tripdata]
			add started_date as CONVERT(date,started_at),
			ended_date as CONVERT(date,ended_at),
			ride_time as CONVERT(time(0),(ended_at - started_at)),
			week_day as datename(dw,started_at),
			use_date as CONCAT(YEAR(started_at), '-', RIGHT(CONCAT('00', MONTH(started_at)), 2)),
			ride_hrs as convert(float,(ended_at - started_at))*24


--Data cleaning1: check any ride time longer than 24hrs. 
select started_date, ended_date,ride_time,week_day, member_casual
from ZiningProject..[202103-202203-tripdata] 
where 
started_date != ended_date
order by 3 desc

--Data cleaning2: if end_station, end_lat, and end_lng are null, this might mean ride trip not completed (Bikes not retuen / bikes losted) 
--check and delete rows: end_station, end_lat, and end_lng are null, were #429 rows deleted
select *
from ZiningProject..[202103-202203-tripdata]
WHERE end_lat is null
	and end_station_name is null

--delect missing data rows:
delete from ZiningProject..[202103-202203-tripdata]
WHERE end_lat is null
	and end_station_name is null

--Data cleaning3: delete trips "rid_time" less 1 min 
select ride_time
from ZiningProject..[202103-202203-tripdata]
WHERE ride_time < '00:01:00'

delete from ZiningProject..[202103-202203-tripdata]
WHERE ride_time < '00:01:00'

--Data cleaning3: drop no used columns from table
alter table ZiningProject..[202103-202203-tripdata]
Drop column started_date,ended_date,start_station_id, end_station_id,


--Final check and found how many null values in each columns after clean:
--The tablet ready for connect and visualzation with Power BI
select SUM (CASE WHEN ride_id is null then 1 else 0 end) as null_col1,
		SUM (CASE WHEN rideable_type is null then 1 else 0 end) as null_col2,
		SUM (CASE WHEN started_at is null then 1 else 0 end) as null_col3,
		SUM (CASE WHEN ended_at is null then 1 else 0 end) as null_col4,
		SUM (CASE WHEN start_station_name is null then 1 else 0 end) as null_col5,
		SUM (CASE WHEN end_station_name is null then 1 else 0 end) as null_col6,
		SUM (CASE WHEN member_casual is null then 1 else 0 end) as null_col7

from ZiningProject..[202103-202203-tripdata]


--If visualzation not required, or visualzation with Tableau,need anlysis with SQL, corrct me if I am wrong :) 
-- Aim: Find the diffrent between casual user and members for a bike renting comapny in Chicago USA, increase members sale

--SQL analysis Question1: what day of week is the most pupular day during whole year?
-- Answer: Saturday & Sunday
SELECT Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time)), week_day
  FROM ZiningProject..[202103-202203-tripdata]
 GROUP BY week_day
--order by 1
--let order result from Sunday Monday ... Saturday
 order by 
		CASE
          WHEN week_day = 'Sunday' THEN 1
          WHEN week_day = 'Monday' THEN 2
          WHEN week_day = 'Tuesday' THEN 3
          WHEN week_day = 'Wednesday' THEN 4
          WHEN week_day = 'Thursday' THEN 5
          WHEN week_day = 'Friday' THEN 6
          WHEN week_day = 'Saturday' THEN 7
     END ASC

--SQL analysis Question2: what month of year is the most pupular month during whole year?
--Answer: busy month: 2021 - 05,06,07,08 warm months, quite month: 2021 2022 - 11,12,01,02 cold months.
SELECT Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time)), use_date
FROM ZiningProject..[202103-202203-tripdata]
GROUP BY use_date
order by 1

-- try other quary for this question, calcaulte ride hrs separately.
--Answer: busy month is warm months, quite month is cold months for all type members.
select use_date, 
		SUM(case when member_casual = 'member' then datediff(HH,'0:00:00',ride_time)end) as member_ridehr,
		SUM(case when member_casual = 'casual' then datediff(HH,'0:00:00',ride_time)end) as casual_ridehr
from ZiningProject..[202103-202203-tripdata]
group by use_date
order by 3


--SQL analysis Question3:how many users are membership user / casual users?
--SQL analysis Question4: the total ride time (in hrs) yr, for each typy of users.
--Answer: the number of member more than casual users, ride time less than casual user
--need collect more data find out the purpose of casual users, like user feedback in words
select member_casual as membership, SUM (CASE WHEN member_casual = 'member' then 1 else 0 end) as num_member,
	   SUM (CASE WHEN member_casual = 'casual' then 1 else 0 end) as num_casual_user,
	   Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time))
from ZiningProject..[202103-202203-tripdata]
GROUP BY member_casual

--SQL analysis Question4: the total ride time (in hrs) of weekday, for each typy of users / bike type
--Order by week days 
--Answers:  Saturday & Sunday busy day, people like classic bike than electric bike...some people use bike for health purpose? 
SELECT  User_type = 'Causeal user', rideable_type, 
		SUM(case when week_day = 'monday' then datediff(HH,'0:00:00',ride_time) end) as Monday,
		SUM(case when week_day = 'tuesday' then datediff(HH,'0:00:00',ride_time) end) as Tuesday,
		SUM(case when week_day = 'wednesday' then datediff(HH,'0:00:00',ride_time) end) as Wednesday,
		SUM(case when week_day = 'thursday' then datediff(HH,'0:00:00',ride_time) end) as Thursday,
		SUM(case when week_day = 'friday' then datediff(HH,'0:00:00',ride_time) end) as Friday,
		SUM(case when week_day = 'saturday' then datediff(HH,'0:00:00',ride_time) end) as Saturday,
		SUM(case when week_day = 'sunday' then datediff(HH,'0:00:00',ride_time) end) as Sunday,
		Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time))
FROM ZiningProject..[202103-202203-tripdata]
where member_casual = 'casual'	
GROUP BY rideable_type

union all

SELECT  'Total_hours_casual', '',
		SUM(case when week_day = 'monday' then datediff(HH,'0:00:00',ride_time) end) as Monday,
		SUM(case when week_day = 'tuesday' then datediff(HH,'0:00:00',ride_time) end) as Tuesday,
		SUM(case when week_day = 'wednesday' then datediff(HH,'0:00:00',ride_time) end) as Wednesday,
		SUM(case when week_day = 'thursday' then datediff(HH,'0:00:00',ride_time) end) as Thursday,
		SUM(case when week_day = 'friday' then datediff(HH,'0:00:00',ride_time) end) as Friday,
		SUM(case when week_day = 'saturday' then datediff(HH,'0:00:00',ride_time) end) as Saturday,
		SUM(case when week_day = 'sunday' then datediff(HH,'0:00:00',ride_time) end) as Sunday,
		Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time))
FROM ZiningProject..[202103-202203-tripdata]
where member_casual = 'casual'

union all 

SELECT  User_type = 'Member', rideable_type,
		SUM(case when week_day = 'monday' then datediff(HH,'0:00:00',ride_time) end) as Monday,
		SUM(case when week_day = 'tuesday' then datediff(HH,'0:00:00',ride_time) end) as Tuesday,
		SUM(case when week_day = 'wednesday' then datediff(HH,'0:00:00',ride_time) end) as Wednesday,
		SUM(case when week_day = 'thursday' then datediff(HH,'0:00:00',ride_time) end) as Thursday,
		SUM(case when week_day = 'friday' then datediff(HH,'0:00:00',ride_time) end) as Friday,
		SUM(case when week_day = 'saturday' then datediff(HH,'0:00:00',ride_time) end) as Saturday,
		SUM(case when week_day = 'sunday' then datediff(HH,'0:00:00',ride_time) end) as Sunday,
		Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time))
FROM ZiningProject..[202103-202203-tripdata]
where member_casual = 'member'	
GROUP BY rideable_type

UNION ALL
SELECT  'Total_hours_member', '',
		SUM(case when week_day = 'monday' then datediff(HH,'0:00:00',ride_time) end) as Monday,
		SUM(case when week_day = 'tuesday' then datediff(HH,'0:00:00',ride_time) end) as Tuesday,
		SUM(case when week_day = 'wednesday' then datediff(HH,'0:00:00',ride_time) end) as Wednesday,
		SUM(case when week_day = 'thursday' then datediff(HH,'0:00:00',ride_time) end) as Thursday,
		SUM(case when week_day = 'friday' then datediff(HH,'0:00:00',ride_time) end) as Friday,
		SUM(case when week_day = 'saturday' then datediff(HH,'0:00:00',ride_time) end) as Saturday,
		SUM(case when week_day = 'sunday' then datediff(HH,'0:00:00',ride_time) end) as Sunday,
		Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time))
FROM ZiningProject..[202103-202203-tripdata]
where member_casual = 'member'

union all

SELECT 'Total_hours', '',
		SUM(case when week_day = 'monday' then datediff(HH,'0:00:00',ride_time) end),
		SUM(case when week_day = 'tuesday' then datediff(HH,'0:00:00',ride_time) end),
		SUM(case when week_day = 'wednesday' then datediff(HH,'0:00:00',ride_time) end),
		SUM(case when week_day = 'thursday' then datediff(HH,'0:00:00',ride_time) end),
		SUM(case when week_day = 'friday' then datediff(HH,'0:00:00',ride_time) end),
		SUM(case when week_day = 'saturday' then datediff(HH,'0:00:00',ride_time) end),
		SUM(case when week_day = 'sunday' then datediff(HH,'0:00:00',ride_time) end),
		Total_ride_hrs = SUM(datediff(HH,'0:00:00',ride_time))
FROM ZiningProject..[202103-202203-tripdata]


--SQL analysis Question4: find the most pupular ride route of year for member and casual, for each typy of users.
--Answers:  we could find pupular ride routes depends on lat and lng values, but Powder BI map function better.

-- concat lat and lng as a series number
alter table ZiningProject..[202103-202203-tripdata]
			add ride_routes as concat( STR(start_lat,8,5),'-',STR(start_lng,8,5), '-', STR(end_lat,8,5),'-', STR(end_lng,8,5))
			

select  top (11) ride_routes, COUNT (ride_routes) as num_trips,
		User_type = 'Causeal user', start_station_name , end_station_name
from ZiningProject..[202103-202203-tripdata]
where member_casual = 'casual'
group by ride_routes, start_station_name, end_station_name
order by num_trips desc

select  top (11) ride_routes, COUNT (ride_routes) as num_trips,
		User_type = 'member', start_station_name , end_station_name
from ZiningProject..[202103-202203-tripdata]
where member_casual = 'member'
group by ride_routes, start_station_name, end_station_name
order by num_trips desc


--Briefly conclusion: 
--1, peolple prefer user bike at weekend in warm seasons.
--2, people prefer classic bike, maybe coz health purpose
--therefore company could promtion at warm seasons, increse classic bikes,  highlight "health" theme
--3, Further data need to collect, for example user purpose analysis: such like collect user feed back. 
--4, use Power BI can find out the bussiest bike station by longitude and latitude, can add advertising near busy station.  



--practice section:

-- 1, fill missed name and ID in data, cannt fill all, need location data sheet 

select atable.start_station_name, atable.start_station_id, btable.end_station_name, btable.end_station_id,
		ISNULL (atable.start_station_id,btable.end_station_id)
from ZiningProject..[202103-tripdata] atable
join ZiningProject..[202103-tripdata] btable
	on atable.start_station_name = btable.end_station_name
	and atable.ride_id <> btable.ride_id
where atable.start_station_id is null


update atable
set start_station_id = ISNULL (atable.start_station_id,btable.end_station_id)
from ZiningProject..[202103-tripdata] atable
join ZiningProject..[202103-tripdata] btable
	on atable.start_station_name = btable.end_station_name
	and atable.ride_id <> btable.ride_id
where atable.start_station_id is null

--change data types.
alter table ZiningProject..[202103-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202103-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202104-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202104-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202105-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202105-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202106-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202106-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202107-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202107-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202108-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202108-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202109-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202109-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202110-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202110-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202111-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202111-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202112-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202112-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202201-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202201-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202202-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202202-tripdata]
alter column end_station_id nvarchar(100)

alter table ZiningProject..[202203-tripdata]
alter column start_station_id nvarchar(100)
alter table ZiningProject..[202203-tripdata]
alter column end_station_id nvarchar(100)-----------------------------------------------------------------------------------------------------------------------------------------