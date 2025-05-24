/* EXPLORATORY DATA ANALYSIS - VIRAT KOHLI IPL CAREER ANALYSIS */

-- LET US SEE THE DATA IN THE TABLE
SELECT * FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data

----checking the unique values for the columns and updating it if require any changes

select DISTINCT(season) FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
----Looking at the values we can there are few ranges in the season so we want to update it to a single year for the season

UPDATE IPLAnalysis.dbo.ipl_match_ball_by_ball_data
SET season = CASE WHEN season = '2007/08' then 2008
                  WHEN season = '2009/10' then 2010
				  WHEN season = '2020/21' then 2020
				  else season
				  end

-------- OVERALL STATISTCS -
-----Total runs scored by Virat Kohli and total balls faced

SELECT striker, SUM(runs_off_bat) as Total_runs, (COUNT(match_id)) as Total_balls_faced
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli' and runs_off_bat = 4
group by striker

-----total number of fours
SELECT striker, count(runs_off_bat) as number_of_fours
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli' and runs_off_bat = 4
group by striker


-------Total number of sixes
SELECT striker, count(runs_off_bat) as number_of_sixes
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli' and runs_off_bat = 6
group by striker;

-------Total number of fifties
---Creating CTE to find the number of fifties

WITH FIFTIES(Striker, Match_Id, RunsperMatch)
AS
(
SELECT striker, match_id, sum(runs_off_bat) as RunsperMatch
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
group by striker, match_id
)

select Striker, Count(RunsperMatch) AS Number_of_fifties
FROM FIFTIES
where Striker = 'V Kohli' AND RunsperMatch BETWEEN 50 AND 99
group by Striker;


------Number of Hundreds -----USING CTE to calculate the same
WITH HUNDREDS(Striker, Match_Id, RunsperMatch)
AS
(
SELECT striker, match_id, sum(runs_off_bat) as RunsperMatch
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
group by striker, match_id
)

select Striker, Count(RunsperMatch) AS Number_of_Hundreds
FROM HUNDREDS
where Striker = 'V Kohli' AND RunsperMatch >=100
group by Striker;

-----overall strike rate of virat kohli

WITH StrikeRate(Striker, Total_Runs, Total_balls_faced)
AS
(
SELECT striker, SUM(runs_off_bat) as Total_runs, (COUNT(match_id)) as Total_balls_faced
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli'
group by striker

)

SELECT *, ROUND((CONVERT(FLOAT,Total_Runs)/Total_balls_faced),2) AS Strike_Rate
FROM StrikeRate

-------Bowlers who have troubled Kohli the most

SELECT bowler, Count(match_id) as Count_of_Dismissal, wicket_type
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli' and player_dismissed = 'V Kohli'
GROUP BY bowler, wicket_type
order by Count_of_Dismissal desc

------Kohli's way of getting out in Ipl

SELECT wicket_type, count(match_id) as Count_of_getting_out
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli' and player_dismissed = 'V Kohli'
GROUP BY wicket_type
order by Count_of_getting_out desc

------Kohli's Performance by innings

------Runs scored in each innings

SELECT striker, SUM(runs_off_bat) as Total_runs, (COUNT(match_id)) as Total_balls_faced, innings
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli'
group by striker, innings;

-----Strike rate in each innings

WITH STRIKE_RATE(Striker, Total_runs, Total_balls_faced, innings)
AS
(
SELECT striker, SUM(runs_off_bat) as Total_runs, (COUNT(match_id)) as Total_balls_faced, innings
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli'
group by striker, innings
)

SELECT *, ROUND((CONVERT(FLOAT,Total_runs)/Total_balls_faced),2) AS Strike_Rate
FROM STRIKE_RATE;

-----Average of each innings

WITH AvgPerInnings(Innings, Total_Runs, Total_Dismissal)
AS
(
SELECT innings, Sum(runs_off_bat) AS Total_Runs, Count(player_dismissed) as Total_dismissal
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli' or player_dismissed = 'V Kohli'
group by innings
)
SELECT *, ROUND((CONVERT(FLOAT,Total_Runs)/Total_Dismissal),2) AS Average
FROM AvgPerInnings
WHERE Total_Dismissal != 0


---Runs scored during different stages of innings

---UPDATE IPLAnalysis.dbo.ipl_match_ball_by_ball_data with a new column stages of innings
SELECT ball,
CASE WHEN ball < 6 THEN 'Power-Play'
     WHEN ball BETWEEN 6 AND 15 THEN 'Middle'
	 WHEN ball >=15 then 'Death'
	 else 'NA'
	END AS stages_of_innings
from IPLAnalysis.dbo.ipl_match_ball_by_ball_data 

ALTER TABLE IPLAnalysis.dbo.ipl_match_ball_by_ball_data
ADD stages_of_innings nvarchar(500)

UPDATE IPLAnalysis.dbo.ipl_match_ball_by_ball_data 
SET stages_of_innings = CASE WHEN ball <= 6.9 THEN 'Power-Play'
     WHEN ball BETWEEN 7 AND 15 THEN 'Middle'
	 WHEN ball >=15.1 then 'Death'
	 else 'NA'
	END
--check if it is updated successfully

select * from IPLAnalysis.dbo.ipl_match_ball_by_ball_data
----calculating the total runs scored during different stages of innings

select Count(runs_off_bat) AS Total_runs, stages_of_innings
from IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli'
group by stages_of_innings

-----dot ball vs boundries percentage

ALTER TABLE IPLAnalysis.dbo.ipl_match_ball_by_ball_data
ADD type_of_balls nvarchar(500)

UPDATE IPLAnalysis.dbo.ipl_match_ball_by_ball_data
SET type_of_balls = CASE WHEN runs_off_bat = 0 then 'Dot_ball'
       WHEN runs_off_bat = 4 OR runs_off_bat = 6 THEN 'Boundry'
	   else 'other_scoring_ball'
	   END
-------CREATE TEMP TABLE TO CALCULATE DOT VS BOUNDRIES BALL FOR VIRAT KOHLI

CREATE TABLE #dotvsboundries
(
Types_of_balls nvarchar(500),
Count_of_balls int
)

INSERT INTO #dotvsboundries
SELECT  type_of_balls,count(type_of_balls) AS COUNT_OF_TYPE_OF_BALLS
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
where striker = 'V Kohli'
GROUP BY type_of_balls

SELECT * FROM #dotvsboundries

ALTER TABLE #dotvsboundries
ADD Total_balls int

UPDATE #dotvsboundries
SET Total_balls = (SELECT sum(Count_of_balls) as total_balls
from #dotvsboundries)

SELECT *,  round((CONVERT(FLOAT,Count_of_balls) / Total_balls) *100, 2) AS Percentage_of_balls_type
from #dotvsboundries
ORDER BY Percentage_of_balls_type DESC
-----Top 10 batsman with most runs in IPL

SELECT striker, SUM(runs_off_bat) as Total_runs, (COUNT(match_id)) as Total_balls_faced
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
group by striker

WITH TOP_Batsman(Striker, Total_runs, Total_balls_faced)
as
(
SELECT striker, SUM(runs_off_bat) as Total_runs, (COUNT(match_id)) as Total_balls_faced
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data
group by striker
)

select Top 10 striker, Total_runs
from TOP_Batsman
ORDER BY Total_runs DESC

-------Joining both the tables to get other insites

-----before joining we need to clean the second table data as the previous one.

----THERE WERE GLITCHES IN THE SESON COLUMN HENCE CHANGED THE FORMATING ON FEW ROWS BY UPDATING THEM

select * from IPLAnalysis.dbo.ipl_match_info_data

select DISTINCT(season)from IPLAnalysis.dbo.ipl_match_info_data

UPDATE IPLAnalysis.dbo.ipl_match_info_data
SET season = CASE WHEN season = '2007/08' then 2008
                  WHEN season = '2009/10' then 2010
				  WHEN season = '2020/21' then 2020
				  else season
				  end
-------How many matches were there where Virat Kohli was Man of the match

SELECT B.match_id, B.season, M.venue, M.player_of_match
FROM IPLAnalysis.dbo.ipl_match_ball_by_ball_data B
LEFT JOIN IPLAnalysis.dbo.ipl_match_info_data M
     ON B.match_id = M.match_id
WHERE  M.player_of_match = 'V Kohli'
GROUP BY B.match_id, B.season, M.venue, M.player_of_match
ORDER BY B.season ASC

----by above analysis we got that there are 14 matches where Virat Kohli won the man of the match and M Chinnaswamy stadium is the ground where he won the most of his matches

----winning against other teams

SELECT match_id, team1
FROM IPLAnalysis.dbo.ipl_match_info_data
where player_of_match = 'V Kohli' and team1  != 'Royal Challengers Bangalore' 
UNION
SELECT match_id, team2
FROM IPLAnalysis.dbo.ipl_match_info_data
where player_of_match = 'V Kohli' and team2  != 'Royal Challengers Bangalore' 

------creating temp table to calculate the winning percentage against various teams
DROP TABLE IF EXISTS #winningpercentage
CREATE TABLE #winningpercentage
(match_id int, 
 team nvarchar(1000)
 );

 select * from #winningpercentage
 INSERT INTO #winningpercentage
 SELECT match_id, team1 as team
   FROM IPLAnalysis.dbo.ipl_match_info_data
   where player_of_match = 'V Kohli' and team1  != 'Royal Challengers Bangalore' 
   UNION
   SELECT match_id, team2 as team
   FROM IPLAnalysis.dbo.ipl_match_info_data
   where player_of_match = 'V Kohli' and team2  != 'Royal Challengers Bangalore' 

 ALTER TABLE #winningpercentage
 ADD Total_match int

 update #winningpercentage
 set Total_match = (SELECT COUNT(match_id) from #winningpercentage)


 Select Distinct(team), Count(match_id) as Total_win_match, Round((CONVERT(float,Count(match_id))/Total_match)*100, 2) AS Winning_percentage
 from #winningpercentage
 group by team, Total_match
 order by Winning_percentage desc