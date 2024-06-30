--Overall covid death table
SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4


-- Total cases vs total deaths
SELECT
	location,
	date,
	total_deaths, 
	total_cases, 
	ROUND((total_deaths/NULLIF(total_cases,0))*100,2) AS death_ratio
FROM dbo.CovidDeaths
WHERE location LIKE 'Indonesia'
ORDER BY 2,3;

-- Percentage of population got covid
SELECT
	location,
	date,
	total_cases,
	population,
	ROUND((total_cases/NULLIF(population,0))*100,2) AS PopulationInfectedRatio
FROM dbo.CovidDeaths
WHERE location LIKE 'Indonesia'
ORDER BY 2,3;

-- Looking at countries with highest infection ratio
SELECT
	location,
	MAX(total_deaths) AS TotalDeaths,
	MAX(population) AS Population,
	MAX(total_cases) AS HighInfectionCount,
	MAX(ROUND((total_cases/NULLIF(population,0))*100,2)) AS PopulationInfectedRatio
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- LET'S BREAK IT DOWN TO CONTINENT
-- Showing the continents with highest counts per population
SELECT
	location,
	MAX(total_deaths) AS TotalDeaths,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(ROUND((total_cases/NULLIF(population,0))*100,2)) AS PopulationInfectedRatio
FROM dbo.CovidDeaths
WHERE
	continent IS NULL AND location NOT LIKE ('%income')
GROUP BY location
ORDER BY 2 DESC;

--GLOBAL NUMBER
SELECT
	date,
	SUM(new_deaths) AS total_deaths,
	SUM(new_cases) AS total_cases,
	ROUND((SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100),2) AS deaths_ratio
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1 DESC

SELECT dea.location, dea.date
FROM PortfolioProject..CovidDeaths dea LEFT JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 1,2

-- join table and see vaccinations
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
		AS RollingPeaopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location LIKE 'Albania'
ORDER BY 2, 3

-- Use CTE
WITH PopsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	AS (
-- join table and see vaccinations
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
		AS RollingPeaopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location LIKE 'Albania'
	)
SELECT *, ROUND((RollingPeopleVaccinated/population)*100,2) AS population_vaccinated_ratio
FROM PopsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PerecentagePopulationVaccinated
CREATE TABLE #PerecentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PerecentagePopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
		AS RollingPeaopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location LIKE 'Albania'

-- Creating View for later visualization
DROP VIEW PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	CONVERT(DATE, dea.date) AS date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
		AS RollingPeaopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
	
SELECT * FROM PercentPopulationVaccinated