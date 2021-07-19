/* 

Queries used for Tableau Project

*/

-- Query 1 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percentage
From covidDataProject..covidDeaths
Where continent is not null 
Order by 1,2 

-- double check based off data provided
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percentage 
From covidDataProject..covidDeaths
Where Location = 'World'
Order By 1,2


-- Query 2 

-- EUROPEAN UNION
Select location, SUM(cast(new_deaths as int)) as total_death_count
From covidDataProject..covidDeaths
Where continent is null
and Location not in ('World','European Union','International')
Group by Location
Order by total_death_count desc

-- Query 3

Select Location, Population, MAX(total_cases) as highest_case_count, MAX((total_cases/population)) * 100 as population_case_percentage
From covidDataProject..covidDeaths
Group by Location, Population
order by population_case_percentage desc

-- Query 4 

Select Location, Population, date, MAX(total_cases) as highest_case_count, MAX((total_cases/population)) * 100 as population_case_percentage
From covidDataProject..covidDeaths
Group by Location, Population, date 
Order by population_case_percentage desc




-- ORIGINAL QUERIES FOR DATA EXPLOREATION


Select *
From covidDataProject..covidDeaths
Where continent is not null
order by 3, 4

Select * 
From covidDataProject..covidVaccinations
order by 3, 4



-- SELECT DATA 
Select continent, date, total_cases, new_cases, total_deaths, population
From covidDataProject..covidDeaths
Where continent is not null
order by 1, 2

--TOTAL CASES TO TOTAL DEATHS IN THE STATE
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From covidDataProject..covidDeaths
Where location like '%states%'
order by 1, 2

-- TOTAL CASE TO POPULATION LIKELIHOOD
Select continent, date, Population, total_cases, (total_cases/population) * 100 as cases_percenatge
From covidDataProject..covidDeaths
Where continent is not null
order by 1, 2

-- COUNTRIES HIGHEST CASE RATE VS POPULATION
Select continent, Population, MAX(total_cases) as cases_count, MAX((total_cases/population))*100 as highest_case_rate
From covidDataProject..covidDeaths
Where continent is not null
Group by continent, Population
order by highest_case_rate desc


-- BREAKING DOWN BY CONTINENT
-- SHOWING COUNTRIES HIGHTEST DEATH COUNT
Select continent, MAX(cast(total_deaths as int)) as total_death_count
from covidDataProject..covidDeaths
Where continent is not null
Group by continent
order by total_death_count desc 


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percentage
From covidDataProject..covidDeaths
where continent is not null
--Group By date
order by 1,2 



-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- USE CTE

With pop_vs_vac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	--showing convert metod
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location
	, 
	dea.Date) as rolling_vaccinations
	--, (rolling_vaccinations/pop)*100
From covidDataProject..covidDeaths dea
Join covidDataProject..covidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_vaccinations/Population) * 100 
From pop_vs_vac

-- TEMP TABLE
-- Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vaccinations numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	--showing convert metod
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location
	, 
	dea.Date) as rolling_vaccinations
	--, (rolling_vaccinations/pop)*100
From covidDataProject..covidDeaths dea
Join covidDataProject..covidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
Select *, (rolling_vaccinations/Population) * 100 as percentage_rolling
From #PercentagePopulationVaccinated


-- CREATING VIEW 
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	--showing convert metod
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location
	, 
	dea.Date) as rolling_vaccinations
From covidDataProject..covidDeaths dea
Join covidDataProject..covidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null


Select * 
From PercentagePopulationVaccinated




	



