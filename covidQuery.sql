-- ORIGINAL QUERIES FOR DATA EXPLOREATION
SELECT *
FROM covidDataProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT * 
FROM covidDataProject..covidVaccinations
ORDER BY 3, 4


-- SELECT DATA 
SELECT continent, date, total_cases, new_cases, total_deaths, population
FROM covidDataProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--TOTAL CASES TO TOTAL DEATHS IN THE STATE
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covidDataProject..covidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2

-- TOTAL CASE TO POPULATION LIKELIHOOD
SELECT continent, date, population, total_cases, (total_cases/population) * 100 AS cases_percenatge
FROM covidDataProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- COUNTRIES HIGHEST CASE RATE VS POPULATION
SELECT continent, population, MAX(total_cases) AS cases_count, MAX((total_cases/population))*100 AS highest_case_rate
FROM covidDataProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY highest_case_rate DESC


-- BREAKING DOWN BY CONTINENT
-- SHOWING COUNTRIES HIGHTEST DEATH COUNT
SELECT continent, MAX(cast(total_deaths AS int)) AS total_death_count
FROM covidDataProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC 


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases) * 100 as death_percentage
FROM covidDataProject..covidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 



-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- USE CTE

WITH pop_vs_vac (Continent, location, Date, population, new_vaccinations, rolling_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	--showing convert metod
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location
	, 
	dea.Date) AS rolling_vaccinations
	--, (rolling_vaccinations/pop)*100
FROM covidDataProject..covidDeaths dea
Join covidDataProject..covidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_vaccinations/population) * 100 
FROM pop_vs_vac

-- TEMP TABLE
-- Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentagePopulationVaccinated(
	Continent NVARCHAR(255),
	location NVARCHAR(255),
	Date DATETIME,
	population NUMERIC,
	New_vaccinations NUMERIC,
	rolling_vaccinations NUMERIC
)


Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	--showing convert metod
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location
	, 
	dea.Date) as rolling_vaccinations
	--, (rolling_vaccinations/pop)*100
FROM covidDataProject..covidDeaths dea
Join covidDataProject..covidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (rolling_vaccinations/population) * 100 as percentage_rolling
FROM #PercentagePopulationVaccinated


-- CREATING VIEW 
Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	--showing convert metod
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location
	, 
	dea.Date) as rolling_vaccinations
FROM covidDataProject..covidDeaths dea
Join covidDataProject..covidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * 
FROM PercentagePopulationVaccinated


/* 

Queries used for Tableau Project

*/

-- Query 1 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percentage
FROM covidDataProject..covidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2 

-- double check based off data provided
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percentage 
FROM covidDataProject..covidDeaths
WHERE location = 'World'
ORDER BY 1,2


-- Query 2 

-- EUROPEAN UNION
SELECT location, SUM(cast(new_deaths as int)) as total_death_count
FROM covidDataProject..covidDeaths
WHERE continent is null
and location not in ('World','European Union','International')
GROUP BY location
ORDER BY total_death_count DESC

-- Query 3

SELECT location, population, MAX(total_cases) as highest_case_count, MAX((total_cases/population)) * 100 as population_case_percentage
FROM covidDataProject..covidDeaths
GROUP BY location, population
ORDER BY population_case_percentage DESC

-- Query 4 

SELECT location, population, date, MAX(total_cases) as highest_case_count, MAX((total_cases/population)) * 100 as population_case_percentage
FROM covidDataProject..covidDeaths
GROUP BY location, population, date 
ORDER BY population_case_percentage DESC




	



