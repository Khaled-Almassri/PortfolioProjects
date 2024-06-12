-- Percentage of deaths to total cases in the UAE
SELECT location, date, total_cases, total_deaths, CAST((CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL)) * 100 AS DECIMAL(18,3)) AS death_percentage
FROM CovidDeaths
WHERE location = 'United Arab Emirates'
ORDER BY date


-- Percentage of total cases to population in the UAE
SELECT location, date, total_cases,population,(total_cases/population)* 100 AS case_to_population_percentage
FROM CovidDeaths
WHERE location = 'United Arab Emirates'
ORDER BY 2


-- Highest infection rate compared to population worldwide
SELECT location,population, MAX(CAST(total_cases AS INT)) AS highest_infection_count, MAX((CAST(total_cases AS INT)/population))*100 as total_cases_to_population
FROM CovidDeaths
GROUP BY location, population
ORDER BY total_cases_to_population DESC



-- Highest total cases worldwide
SELECT location,MAX(CAST(total_cases as int)) as highest_total_cases
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY highest_total_cases desc


-- Highest total deaths worldwide
SELECT location,MAX(CAST(total_deaths as int)) as highest_total_deaths
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY highest_total_deaths desc


--Highest death to case worldwide
SELECT location,MAX(CAST(total_cases as int)) as highest_total_cases, MAX(CAST(total_deaths as int)) as highest_total_deaths, (MAX(CAST(total_deaths as decimal)) / MAX(CAST(total_cases as decimal)))* 100 AS death_to_cases
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY death_to_cases desc


-- Highest death to population worldwide
SELECT location,population,MAX(CAST(total_deaths as int)) as highest_total_deaths, (MAX(CAST(total_deaths as int))/population) * 100 AS deaths_to_population 
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location,population
ORDER BY deaths_to_population  desc


-- Total worldwide cases
SELECT location,MAX(CAST(total_cases as decimal)) as max_total_cases_worldwide
FROM CovidDeaths
WHERE location = 'World'
GROUP BY location


-- Total worldwide deaths
SELECT location,MAX(CAST(total_deaths as decimal)) as max_total_deaths_worldwide
FROM CovidDeaths
WHERE location = 'World'
GROUP BY location;


-- Total worldwide death to case percentage ( CTE usage )
WITH world_CTE AS(
SELECT location,MAX(CAST(total_cases as decimal)) as max_total_cases_worldwide,MAX(CAST(total_deaths as decimal)) as max_total_deaths_worldwide
FROM CovidDeaths
WHERE location = 'World'
GROUP BY location
)
SELECT  (max_total_deaths_worldwide / max_total_cases_worldwide) * 100 as death_to_case
FROM world_CTE


-- Total deaths in each continent

SELECT location, MAX(CAST(total_deaths as int)) as total_deaths
FROM CovidDeaths
WHERE location IN ('Europe','Asia','Africa','North America','South America','Oceania')
GROUP BY location
ORDER BY 2 desc




-- THIS PART IS ABOUT VACCINATIONS


-- Rolling vaccination count
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS DEC)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_vaccination_count
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 ;


-- Total  population vs vaccine percentage USING CTE
WITH vaccination_CTE(continent,location,date,population,new_vaccinations,rolling_vaccination_count) AS(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS DEC)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_vaccination_count
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *,(rolling_vaccination_count / population) * 100 as percentage_of_population_vaccinated
FROM vaccination_CTE
ORDER BY 2,3


-- Vaccines doses (boosters included) recieved by each country
SELECT dea.location,dea.population,MAX(CONVERT(DEC,vac.total_vaccinations)) as total_vaccination_doses
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location,dea.population
ORDER BY 3 desc;


-- Vaccines doses (boosters included) recieved by each country to population percentage
SELECT dea.location,dea.population,MAX(CONVERT(DEC,vac.total_vaccinations)) as total_vaccination_doses, (MAX(CONVERT(DEC,vac.total_vaccinations)) / population)*100 as percentage
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location,dea.population
ORDER BY 3 desc;