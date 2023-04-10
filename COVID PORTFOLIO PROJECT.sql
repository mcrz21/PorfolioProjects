select *
from new_schema.CovidDeaths
WHERE continent is not NULL 
order by 3,4;

select *
from new_schema.CovidVaccinations
order by 3,4;

/* select data that we will be using */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM new_schema.CovidDeaths
ORDER BY 1,2;

/* Looking at total cases vs total deaths */
/* Shows likelihood of dying if you contract covid in your country*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM new_schema.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

/* Looking at total cases vs population */
/* Shows the percentage that contarcted covid */

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS infected_population_percentage
FROM new_schema.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

/* Looking at countries with highest infection rate compared to population */

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population) * 100) AS infected_population_percentage
FROM new_schema.CovidDeaths
GROUP BY location, population 
ORDER BY infected_population_percentage DESC;

/* Looking at countries with highest death count in relation to population */

SELECT location, MAX(total_deaths) AS total_death_count
FROM new_schema.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;

/* Breaking down death counts by continent */

SELECT location, MAX(total_deaths) AS total_death_count
FROM new_schema.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC;

/* Showing continents with the highest death count per population */

SELECT continent, MAX(total_deaths) AS total_death_count
FROM new_schema.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;

/* Global numbers */

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM new_schema.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;

/* Global number grouped by date */

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM new_schema.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2;

/* Looking at total population vs vaccinations (rolling) */

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
FROM new_schema.CovidDeaths cd
JOIN new_schema.CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3;


/* Rolling Vaccinations by percentage (Using CTE) */

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinations) 
AS (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
FROM new_schema.CovidDeaths cd
JOIN new_schema.CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3
)

SELECT *, (rolling_vaccinations/population) * 100 AS rolling_vac_percentage
FROM pop_vs_vac


/* Rolling Vaccinations by percentage (Using Temp Table) */


CREATE TEMPORARY TABLE new_schema.PercentPopulationVaccinated

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
FROM new_schema.CovidDeaths cd
JOIN new_schema.CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date;

SELECT *, (rolling_vaccinations/population) * 100 AS rolling_vac_percentage
FROM new_schema.PercentPopulationVaccinated;


/* CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS */

CREATE VIEW new_schema.PercentPopulationVaccinated AS

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
FROM new_schema.CovidDeaths cd
JOIN new_schema.CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3;

SELECT *
FROM new_schema.PercentPopulationVaccinated





