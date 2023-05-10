--1.Create a table named ‘matches’ with appropriate data types for columns
CREATE TABLE matches (
match_id int,
city varchar,
date date,
player_of_match varchar,
venue varchar,
neutral_venue int,
team1 varchar, 
team2 varchar, 
toss_winner varchar, 
toss_decision varchar, 
winner varchar,
result_mode varchar, 
result_margin int,
eliminator varchar,
method_dl varchar,
umpire1 varchar, 
umpire2 varchar
);


--2.Create a table named ‘deliveries’ with appropriate data types for columns

CREATE TABLE deliveries (
match_id int, 
inning int, 
over int, 
ball int, 
batsman varchar, 
non_striker varchar, 
bowler varchar, 
batsman_runs int,
extra_runs int, 
total_runs int,
wicket_ball int,
dismissal_kind varchar,
player_dismissed varchar,
fielder varchar,
extras_type varchar,
batting_team varchar, 
bowling_team varchar
);

---3.IMPORTED DATA FOT MATCHES FROM IMPORT / EXPORT WIZARD(RIGHT CLICK ON TABLES IN DATABASE AND SELECT IMPORT)
--4.IMPORTED DATA FOR DELIVERIES FROM IMPORT / EXPORT WIZARD(RIGHT CLICK ON TABLES IN DATABASE AND SELECT IMPORT)

--5.Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order.

SELECT * FROM DELIVERIES
LIMIT 20;

--6.Select the top 20 rows of the matches table.

SELECT * FROM MATCHES
LIMIT 20;

--7.Fetch data of all the matches played on 2nd May 2013 from the matches table.

select * from matches where date = '02-05-2013';


--8.Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs.

select * from matches where result_mode = 'runs' and result_margin > 100;

--9.Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.

select * from matches where result_mode ='tie' order by date desc;


--10.Get the count of cities that have hosted an IPL match.

select count (distinct city) from matches;


--11.Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an 
additional column ball_result containing values boundary, dot or 
other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)

create table deliveries_v02 as select *, 
 CASE WHEN total_runs >= 4 then 'boundary' 
 WHEN total_runs = 0 THEN 'dot'
else 'other'
 END as ball_result 
 FROM deliveries;


--12.Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.

SELECT BALL_RESULT,count(*)
FROM DELIVERIES_V02
group by ball_result;


---13.Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table
   and order it in descending order of the number of boundaries scored.


select batting_team,count(ball_result) as total_boundaries
from deliveries_v02
where ball_result='boundary'
group by batting_team
order  by total_boundaries desc;

---14.Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of
     the total number of dot balls bowled.
	 
select bowling_team, count(*) from deliveries_v02 
where ball_result = 'dot' 
group by bowling_team 
order by count desc;


--15.Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA
 
select dismissal_kind, count (*) from deliveries where dismissal_kind <> 'NA' group by dismissal_kind 
order by count desc;

--16.Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table

select distinct bowler,count(extra_runs) as max_extra_runs from deliveries
group by bowler
order by max_extra_runs desc
limit 5;


--17.Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table
     and two additional column (named venue and match_date) of venue and date from table matches


 create table deliveries_v03 AS SELECT a.*, b.venue, b.match_date from 
deliveries_v02 as a 
left join (select max(venue) as venue, max(date) as match_date, match_id from matches group by 
match_id) as b
on a.match_id = b.match_id;


--18.Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.

select venue, sum(total_runs) as runs from deliveries_v03 group by venue order by runs desc;


--19.Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.

select extract(year from match_date) as IPL_year, sum(total_runs) as runs from deliveries_v03 
where venue = 'Eden Gardens' group by IPL_year order by runs desc;


--20.Get unique team1 names from the matches table,
     you will notice that there are two entries for Rising Pune Supergiant 
     one with Rising Pune Supergiant and another one with Rising Pune Supergiants. 
     Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names
     with replacing Rising Pune Supergiants with Rising Pune Supergiant. 
     Now analyse these newly created columns.



select distinct team1 from matches;

create table matches_corrected as select *, replace(team1, 'Rising Pune Supergiants', 'Rising Pune 
Supergiant') as team1_corr
, replace(team2, 'Rising Pune Supergiants', 'Rising Pune Supergiant') as team2_corr from matches;

select distinct team1_corr from matches_corrected;


--21.Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning,
over and ball separated by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball)
and rest of the columns same as deliveries_v03)


create table deliveries_v04 as select concat(match_id,'-',inning,'-',over,'-',ball) as ball_id, * from 
deliveries_v03;
select * from deliveries_v04;


--22.Compare the total count of rows and total count of distinct ball_id in deliveries_v04;

select count(*) from deliveries_v04;
select count(distinct ball_id) from deliveries_v04;

--23.SQL Row_Number() function is used to sort and assign row numbers to data rows in the presence of multiple groups. 
   For example, to identify the top 10 rows which have the highest order amount in each region,
   we can use row_number to assign row numbers in each group (region) with any particular order (decreasing order of order amount) 
   and then we can use this new column to apply filters. Using this knowledge, 
   solve the following exercise. create an additional column of row number.
   Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. 

create table deliveries_v05 as select *, row_number() over (partition by ball_id) as row_num from 
deliveries_v04;

select * from deliveries_v05;

--24.Use the row_num created in deliveries_v05 to identify instances where ball_id is repeating.



select count(*) from deliveries_v05;
select sum(row_num) from deliveries_v05;
select * from deliveries_v05 order by row_num limit 20;
select * from deliveries_v05 WHERE row_num=2;


--25.Use subqueries to fetch data of all the ball_id which are repeating. 

SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE 
row_num=2);




























	 
	 
	 
	 
	 


















