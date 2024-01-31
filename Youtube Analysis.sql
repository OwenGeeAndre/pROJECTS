--DROP VIEW IF EXISTS Youtube_data

--CREATE VIEW Youtube_data AS	--Creating a view to save data that will be used for the analysis

--SELECT YC.Youtuber, YC.channel_type, YC.category, YC.Country, YC.subscribers, YC.[video views], hye, lye, 
--		lastmonthviews,lastmonthsubs, YC.created_date, YC.created_month, YC.created_year
--FROM YouTube_Content YC
--INNER JOIN YouTube_Earnings YE
--ON YC.rank = YE.rank


--------------------------------------TREND OF PAGES CREATED PER MONTH THROUGH THE YEARS--------------------------------------
SELECT CAST(Date AS date) Date, COUNT(Date) Amount
FROM(
SELECT CONCAT(created_month,' ',created_year) Date
FROM Youtube_data
) AS subq
WHERE Date <> 'NAN'
GROUP BY Date
ORDER BY 1



--------------------------------------NUMBER OF PAGES CREATED PER YEAR--------------------------------------

select created_year, COUNT(created_year) Amount
from Youtube_data
WHERE created_year is not null
GROUP BY created_year
ORDER BY 1

--------------------------------------AVERAGE SUBSCRIBERS, VIDEOVIEWS BASED ON AGE OF PAGE--------------------------------------
SELECT PageAgeRange, ROUND(AVG(subscribers), 2) AvgSubscribers, ROUND(AVG([video views]), 2) AvgVideoViews
FROM(
SELECT subscribers, [video views], YEAR(GETDATE()) - created_year PageAge,
CASE
			WHEN YEAR(GETDATE()) - created_year > 15 THEN 'above 15'
			WHEN YEAR(GETDATE()) - created_year > 10 THEN 'above 10'
			WHEN YEAR(GETDATE()) - created_year > 5 THEN 'above 5'
			ELSE 'below 5'
		END PageAgeRange
FROM Youtube_data
WHERE created_year IS NOT NULL AND created_year <> 1970
) AS subq2
GROUP BY PageAgeRange
ORDER BY 1

--------------------------------------AVG SUBSCRIBERS, AVG VIDEOVIEWS, AVG HYE, AVG LYE AND COUNT PER CATEGORY--------------------------------------

SELECT category, ROUND(AVG(subscribers), 2) AvgSubscribers, ROUND(AVG([video views]), 2) AvgVideoViews
FROM Youtube_data
WHERE category <> 'nan'
GROUP BY category

SELECT category, ROUND(AVG(hye), 2) AvgHighestYearlyIncome, ROUND(AVG(lye), 2) AvgLowestYearlyIncome, ROUND(AVG(hye), 2) - ROUND(AVG(lye), 2) Range
FROM Youtube_data
WHERE category <> 'nan'
GROUP BY category
ORDER BY 4 DESC

--------------------------------------%NEW SUBSCRIBERS, %NEW VIDEOVIEWS, AVG RANGE OF YEARLY_EARNINGS PER COUNTRY--------------------------------------


SELECT Country, ROUND(AVG(PercentNewVIews), 2) TotalPercentNewVIews, ROUND(AVG(PercentNewSubs), 2) TotalPercentNewSubs, COUNT(Country) Count
FROM(
SELECT Country, lastmonthviews/[video views]*100 AS PercentNewViews, lastmonthsubs/subscribers*100 AS PercentNewSubs
FROM Youtube_data
WHERE Country IS NOT NULL AND [video views] IS NOT NULL AND subscribers IS NOT NULL AND lastmonthviews IS NOT NULL AND lastmonthsubs IS NOT NULL
) AS subq3
GROUP BY Country

SELECT Country, AVG(YearlyEarningRange) AvgYearlyEarningRange
FROM (
SELECT country, hye, lye, hye - lye YearlyEarningRange
FROM Youtube_data
) AS subq4
GROUP BY Country
