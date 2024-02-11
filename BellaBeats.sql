---------------------WHICH 10 USER COVERED MOST DISTANCES
WITH Top10Users AS 
(
SELECT Id, AVG(TotalSteps) TOTALSTEPS, COUNT(Id) [Days_Used], ROUND(AVG(TrackerDistance), 2)  TRACKERDISTANCE, ROUND(AVG(VeryActiveDistance), 2) VERYACTIVEDISTANCE, 
        ROUND(AVG(ModeratelyActiveDistance), 2) MODERATELYACTIVEDISTANCE, ROUND(AVG(LightActiveDistance), 2) LIGHTACTIVEDISTANCE, 
        ROUND(AVG(SedentaryActiveDistance), 2) SedentaryActiveDistance, ROW_NUMBER() OVER (ORDER BY AVG(TrackerDistance) DESC) Usage_Rank
FROM dailyActivity_merged
GROUP BY Id
)
SELECT totalsteps, days_used, trackerdistance, veryactivedistance, lightactivedistance
FROM Top10Users
WHERE Usage_Rank <= 10

-------------------SUMMARY OF DISTANCE AND USAGE OF EACH USER--------------------
SELECT Id, AVG(TotalSteps) TOTALSTEPS, COUNT(Id) [Days_Used], ROUND(AVG(TrackerDistance), 2)  TRACKERDISTANCE, ROUND(AVG(VeryActiveDistance), 2) VERYACTIVEDISTANCE, 
        ROUND(AVG(ModeratelyActiveDistance), 2) MODERATELYACTIVEDISTANCE, ROUND(AVG(LightActiveDistance), 2) LIGHTACTIVEDISTANCE, 
        ROUND(AVG(SedentaryActiveDistance), 2) SedentaryActiveDistance
FROM dailyActivity_merged
GROUP BY Id

---------------------USER ACTIVITY ON EVERY DAY OF THE WEEK
SELECT Weekday, AVG(ACTIVEUSERS) [Average Active Users], SUM(ACTIVEUSERS) [Total Active Users],
					SUM(INACTIVEUSERS) [Total Inactive Users]
FROM
(SELECT ActivityDate, DATENAME(DW, ActivityDate) Weekday,  
		COUNT(CASE WHEN TOTALSTEPS <> 0 THEN 1 END) ActiveUsers,
		COUNT(CASE WHEN TOTALSTEPS = 0 THEN 1 END) InactiveUsers,  COUNT(ActivityDate) TotalUsers
FROM dailyActivity_merged
GROUP BY ActivityDate) AS subq1
GROUP BY Weekday

--------------------AVERAGE STEPS STACTISTICS OF USERS THAT USED ON ALL RECORDED DAYS

SELECT Id, SUM(TOTALSTEPS) [Total Steps], AVG_TOTALSTEPS [Average Steps], 
			COUNT(CASE WHEN TOTALSTEPS > AVG_TOTALSTEPS THEN 1 END) AS [Days Walked Above Average],
			COUNT(CASE WHEN TOTALSTEPS < AVG_TOTALSTEPS THEN 1 END) AS [Days Walked Below Average],
			RANK () OVER (ORDER BY SUM(TOTALSTEPS) DESC) [Rank by Total Steps],
			RANK () OVER (ORDER BY AVG_TOTALSTEPS DESC) [Rank by Average Steps]
FROM (
    SELECT Id, TOTALSTEPS, AVG(TOTALSTEPS) OVER (PARTITION BY Id) AS AVG_TOTALSTEPS
    FROM dailyActivity_merged
	WHERE TotalSteps <> 0 
) AS subquery
GROUP BY Id, AVG_TOTALSTEPS
HAVING  COUNT(ID) = 31


--------------------AVERAGE STEPS STACTISTICS OF USERS THAT DID NOT USE ON ALL RECORDED DAYS

SELECT Id, SUM(TOTALSTEPS) [Total Steps], AVG_TOTALSTEPS [Average Steps], 
			COUNT(CASE WHEN TOTALSTEPS > AVG_TOTALSTEPS THEN 1 END) AS [Days Walked Above Average],
			COUNT(CASE WHEN TOTALSTEPS < AVG_TOTALSTEPS THEN 1 END) AS [Days Walked Below Average],  COUNT(Id) [Days Used],
			RANK () OVER (ORDER BY SUM(TOTALSTEPS) DESC) [Rank by Total Steps],
			RANK () OVER (ORDER BY AVG_TOTALSTEPS DESC) [Rank by Average Steps]
FROM (
    SELECT Id, TOTALSTEPS, AVG(TOTALSTEPS) OVER (PARTITION BY Id) AS AVG_TOTALSTEPS
    FROM dailyActivity_merged
	WHERE TotalSteps <> 0 
) AS subquery
GROUP BY Id, AVG_TOTALSTEPS
HAVING  COUNT(Id) < 31

-------------------PEOPLE THAT USED FOR THE WHOLE MONTH VS THOSE THAT USED LESS
SELECT
  COUNT(CASE WHEN amount = 31 THEN 1 END) AS Full_Month_Usage,
  COUNT(CASE WHEN amount <= 30 and amount > 25 THEN 1 END) AS [26-30 days],
  COUNT(CASE WHEN amount <= 25 and amount > 20 THEN 1 END) AS [21-25 days],
  COUNT(CASE WHEN amount <= 20 and amount > 15 THEN 1 END) AS [16-20 days],
  COUNT(CASE WHEN amount <= 15 THEN 1 END) AS [below_15_days]
FROM (
  SELECT Id, COUNT(Id) AS amount
  FROM dailyActivity_merged
  GROUP BY Id
) subq



----------------AVERAGE DISTANCE COVERED AND CALORIES BURNT ON DAYS OF THE WEEK
SELECT *
INTO #FullUsers   ---creating temp table for average distance and calories burnt for full month users
FROM(
SELECT Day, ROUND(AVG(TotalDistance), 2) AvgTotalDistance, AVG(Calories) AvgCal
FROM
(SELECT *, DATENAME(dw, ActivityDate) Day FROM dailyActivity_merged
WHERE Id IN (SELECT Id FROM dailyActivity_merged GROUP BY Id  HAVING COUNT(Id) = 31)) AS subq2   ---filter for only those that used for the whole month
GROUP BY Day) AS Temp

SELECT *
INTO #PartUsers    ---creating temp table for average distance and calories burnt for part month users
FROM(
SELECT Day, ROUND(AVG(TotalDistance), 2) AvgTotalDistance, AVG(Calories) AvgCal
FROM
(SELECT *, DATENAME(dw, ActivityDate) Day FROM dailyActivity_merged
WHERE Id IN (SELECT Id FROM dailyActivity_merged GROUP BY Id  HAVING COUNT(Id) < 31)) AS subq2   ---filter for only those that used for the part of the month
GROUP BY Day) AS Temp

SELECT #FullUsers.Day, #FullUsers.AvgTotalDistance [Average Distance Full], #FullUsers.AvgCal [Average Calories Burnt Full],
		#PartUsers.AvgTotalDistance [Average Distance Partial], #PartUsers.AvgCal [Average Calories Burnt Partial]		
FROM #FullUsers
INNER JOIN #PartUsers
ON #FullUsers.Day = #PartUsers.Day

SELECT *
FROM dailyActivity_merged