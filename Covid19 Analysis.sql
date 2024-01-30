use Covid19

---- what we'll be using
--CREATE VIEW CovidData AS
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

---altering data type
alter table coviddeaths
--alter column total_cases float
alter column population float

--TOTAL CASES VS DEATHS

----most critical periods of covid to death conversion in Nigeria
--CREATE VIEW nigeriaCritDeathDays AS
SELECT top 10 location, CONCAT(FORMAT(DAY(date), '0#'), ' ', DATENAME(MONTH,date),' ', year(date)) date, total_cases, total_deaths, 
		FORMAT(ROUND((total_deaths/total_cases), 5)*100, '#0.###') Death_percent
FROM Covid19..CovidDeaths
WHERE total_deaths IS NOT NULL AND location = 'nigeria' AND continent IS NOT NULL
ORDER BY 5 DESC, 2


----TOTAL CASES VS POPULATION

----world population infection rate
--CREATE VIEW popInfPercent AS
SELECT location, CONCAT(FORMAT(DAY(date), '0#'), ' ', DATENAME(MONTH,date), ' ', year(date)) date, 
		total_cases, population, 
		FORMAT(ROUND((total_cases/population), 5)*100, '#0.###') total_case_percent
FROM Covid19..CovidDeaths
WHERE location NOT IN ('world','asia','africa') AND location NOT LIKE '%america%' AND location NOT LIKE '%europe%'
ORDER BY 1, coviddeaths.date


----global population highest infection values
--CREATE VIEW highestInfCountry AS
SELECT location, population, 
		MAX(total_cases) MAX_case, 
		ROUND(MAX(total_cases/population)*100, 4) total_case_percent
FROM Covid19..CovidDeaths	
WHERE location NOT IN ('world','asia','africa') AND location NOT LIKE '%america%' AND location NOT LIKE '%europe%'
GROUP BY location, population
ORDER BY 4 DESC

----countries WITH highest death count
--CREATE VIEW highestDeathCountCountry2 AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE location NOT IN ('world','asia','africa') AND location NOT LIKE '%america%' AND location NOT LIKE '%europe%'
GROUP BY location
ORDER BY 2 DESC

--CONTINENT ANALYSIS

----countries WITH highest death count
--CREATE VIEW highestDeathCountCountry AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

----countries WITH highest death count
--CREATE VIEW highestDeathCount AS
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


----continent's highest death count per populaton
--CREATE VIEW continentDeathperPop AS

SELECT continent,  SUM(total_deaths/population) DeathperPop
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--GLOBAL NUMBERS

----total global daily new cases and new deaths
--CREATE VIEW globalNewCaseandDeaths AS 
SELECT date, SUM(new_cases) Cases, SUM(new_deaths) Deaths
FROM CovidDeaths WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

----total global daily death percent
--CREATE VIEW globalDailyDeathPercent AS
SELECT date, SUM(new_cases) Cases, SUM(new_deaths) Deaths, SUM(cast(new_deaths AS float))*100/SUM(cast(new_cases AS int)) DeathPercent
FROM CovidDeaths WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

----total global cases, deaths and death percentage
--CREATE VIEW globalCaseDeathPercent AS
SELECT SUM(new_cases) totalCases, SUM(new_deaths) totalDeaths, SUM(cast(new_deaths AS float))*100/SUM(cast(new_cases AS int)) totalDeathPercent
FROM CovidDeaths WHERE continent IS NOT NULL
ORDER BY 1, 2



----Total daily Population new vaccinations
--CREATE VIEW dailyPopNewVacc as 
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations
FROM Covid19..CovidDeaths CD
JOIN Covid19..CovidVaccinations CV
	on CD.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1, 2, 3

----WITH COMMON TABLE EXPRESSIONS
--CREATE VIEW MaxPopVaccandDeaths AS 

WITH PopVacc (Continent, Location, date, population, new_populations, totalCummVacc)
AS(
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations,
		SUM(new_vaccinations) over (partition by cd.location ORDER BY cd.location, cd.date) totalCummVacc
FROM Covid19..CovidDeaths CD
JOIN Covid19..CovidVaccinations CV
	on CD.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT Continent, Location, MAX(population) Population, MAX((totalCummVacc/population)*100) percentVacc
FROM PopVacc	
GROUP BY Continent, Location
--ORDER BY 2

----WITH TEMP TABLE


DROP TABLE if exists #PopVaccc
Create Table #PopVaccc
(	continent nvarchar(255), location nvarchar(255), date date, 
	population numeric, new_vaccinations numeric, new_deaths numeric,
	totalCummVacc numeric, totalCummDeath numeric
)
insert into #PopVaccc
	SELECT cd.continent, cd.location, cd.date, population, new_vaccinations, new_deaths,
		SUM(new_vaccinations) over (partition by cd.location ORDER BY cd.location, cd.date) totalCummVacc,
		SUM(new_deaths) over (partition by cd.location ORDER BY cd.location, cd.date) totalCummDeath
	FROM Covid19..CovidDeaths CD
	JOIN Covid19..CovidVaccinations CV
		on CD.location = cv.location 
		AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL

	SELECT Continent, Location, MAX(population) Population, MAX((totalCummVacc/population)*100) percentVacc,
			SUM(new_deaths) Deaths, MAX((totalCummDeath/population)*100) percentDeath
	FROM #PopVaccc
	GROUP BY continent,location
	ORDER BY 1, 6 DESC

----Creating view to store data for later visuals

CREATE VIEW percentPopVacc AS 
	SELECT cd.continent, cd.location, cd.date, population, new_vaccinations
	FROM Covid19..CovidDeaths CD
	JOIN Covid19..CovidVaccinations CV
		on CD.location = cv.location 
		AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	--ORDER BY 1, 2, 3