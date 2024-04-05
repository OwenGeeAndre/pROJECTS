/*--------------CREATING TABLE CALLED DailyMerged_Xtrzd FROM JOINING HOURLYINTENSITY, HOURLYCALORY AND HOURLYSTEPS TABLES
------------------------------------------------WHICH SHOWS 
------------------------------------THE DAY OF THE WEEK AND THE TIME OF THE DAY*/

DROP TABLE IF EXISTS DailyMerged_Xtrzd

SELECT *
INTO DailyMerged_Xtrzd
FROM(
SELECT Id, DATE, DATENAME(DW, DATE) Day_of_Week,
CASE WHEN TIME >= '00:00:00' AND TIME < '04:00:00' THEN 'Before_Dawn'
     WHEN TIME >= '04:00:00' AND TIME < '06:00:00' THEN 'Dawn'
     WHEN TIME >= '06:00:00' AND TIME < '12:00:00' THEN 'Morning'
     WHEN TIME >= '12:00:00' AND TIME < '16:00:00' THEN 'Afternoon'
     WHEN TIME >= '16:00:00' AND TIME < '20:00:00' THEN 'Evening'
    ELSE 'Night'
END [Time_of_Day],
TotalIntensity, AverageIntensity, Calories, StepTotal
FROM(
SELECT hourlyIntensities_merged.Id, CONVERT(DATE, hourlyIntensities_merged.ActivityHour) Date, 
        CONVERT(time, hourlyIntensities_merged.ActivityHour) Time,
        TotalIntensity, AverageIntensity, Calories, StepTotal
FROM hourlyIntensities_merged
INNER JOIN hourlyCalories_merged
ON hourlyIntensities_merged.Id = hourlyCalories_merged.Id AND hourlyIntensities_merged.ActivityHour = hourlyCalories_merged.ActivityHour
INNER JOIN hourlySteps_merged
ON hourlyIntensities_merged.Id = hourlySteps_merged.Id AND hourlyIntensities_merged.ActivityHour = hourlySteps_merged.ActivityHour
) AS SUBQ
) AS TEMP


-------------------PERCENTAGE OF ZERO ACTIVITY vs ACTIVITY PERIODS FOR EACH TIME OF THE DAY AND DAY OF THE WEEK
SELECT Time_of_Day,
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity = 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Idle Periods%],
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity <> 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Active Periods%]
FROM DailyMerged_Xtrzd
GROUP BY Time_of_Day


SELECT Day_of_Week, 
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity = 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Idle Periods%],
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity <> 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Active Periods%]
FROM DailyMerged_Xtrzd
GROUP BY Day_of_Week


----------------TIME OF THE DAY AND DAYS OF THE WEEK WITH THE MOST USER PERCENTAGE INTENSITIES
SELECT Day_of_Week, 
        ROUND(CAST(Very_Intense AS FLOAT)/(Very_Intense+Moderately_Intense+NOT_Intense)*100, 3) [Very Intense %],
        ROUND(CAST(Moderately_Intense AS FLOAT)/(Very_Intense+Moderately_Intense+NOT_Intense)*100, 3) [Moderate Intense%],
        ROUND(CAST(NOT_Intense AS FLOAT)/(Very_Intense+Moderately_Intense+NOT_Intense)*100, 3) [Not Intense%],
        Very_Intense+Moderately_Intense+NOT_Intense [Total Intensity]
FROM(
SELECT Day_of_Week, COUNT(CASE WHEN AverageIntensity > 2.0 AND AverageIntensity <= 3.0 THEN 1 END) Very_Intense,
                    COUNT(CASE WHEN AverageIntensity > 1.0 AND AverageIntensity <= 2.0 THEN 1 END) Moderately_Intense,
                    COUNT(CASE WHEN AverageIntensity <= 1.0 THEN 1 END) NOT_Intense
FROM DailyMerged_Xtrzd
WHERE TotalIntensity <> 0
GROUP BY Day_of_Week) AS SUBQ


SELECT Time_of_Day, 
        ROUND(CAST(Very_Intense AS FLOAT)/(Very_Intense+Moderately_Intense+NOT_Intense)*100, 3) [Very Intense%],
        ROUND(CAST(Moderately_Intense AS FLOAT)/(Very_Intense+Moderately_Intense+NOT_Intense)*100, 3) [Moderate Intense%],
        ROUND(CAST(NOT_Intense AS FLOAT)/(Very_Intense+Moderately_Intense+NOT_Intense)*100, 3) [Not Intense%],
        Very_Intense+Moderately_Intense+NOT_Intense [Total Intensity]
FROM(
SELECT Time_of_Day, COUNT(CASE WHEN AverageIntensity > 2.0 AND AverageIntensity <= 3.0 THEN 1 END) Very_Intense,
                    COUNT(CASE WHEN AverageIntensity > 1.0 AND AverageIntensity <= 2.0 THEN 1 END) Moderately_Intense,
                    COUNT(CASE WHEN AverageIntensity <= 1.0 THEN 1 END) NOT_Intense
FROM DailyMerged_Xtrzd
WHERE TotalIntensity <> 0
GROUP BY Time_of_Day) AS subq


------------------------TIME OF THE DAY AND DAYS OF THE WEEK WITH USERS ACTIVE AND IDLE
SELECT Time_of_Day,
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity = 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Idle Periods%],
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity <> 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Active Periods%]
FROM DailyMerged_Xtrzd
GROUP BY Time_of_Day

SELECT Day_of_Week,
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity = 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Idle Periods%],
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity <> 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Active Periods%]
FROM DailyMerged_Xtrzd
GROUP BY Day_of_Week

SELECT Day_of_Week, Time_of_Day,
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity = 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Idle Periods%],
    FORMAT((1.0*COUNT(CASE WHEN TotalIntensity <> 0 THEN 1 END)/COUNT(TotalIntensity)*100), '##.##') [Active Periods%]
FROM DailyMerged_Xtrzd
GROUP BY Day_of_Week, Time_of_Day
ORDER BY Day_of_Week


------------------------TIME OF THE DAY AND DAYS OF THE WEEK WITH USERS PERCENTAGE INTENSITY
SELECT Day_of_Week, Time_of_Day, 
    SUM(TotalIntensity) AS Period_Intensity,
    SUM(SUM(TotalIntensity)) OVER (PARTITION BY Day_of_Week) AS Day_Intensity,
    FORMAT(1.0 * SUM(TotalIntensity) / SUM(SUM(TotalIntensity)) OVER (PARTITION BY Day_of_Week) * 100, '##.##') AS [Intensity%]
FROM DailyMerged_Xtrzd
WHERE TotalIntensity <> 0
GROUP BY Day_of_Week, Time_of_Day
ORDER BY Day_of_Week, Time_of_Day
