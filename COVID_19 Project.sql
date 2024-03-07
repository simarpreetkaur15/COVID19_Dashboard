SELECT * 
FROM COVID19_Project.dbo.CovidDeaths

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM COVID19_Project.dbo.CovidDeaths
ORDER BY 1,2

-- TOTAL CASES V/S TOTAL DEATHS FOR INDIA (Shows the percentage of peopl dyding that got covid)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM COVID19_Project.dbo.CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

-- TOTAL CASES V/S POPULATION (shows percentage of population that got covid)
SELECT Location, date, total_cases, population, (total_deaths/population)*100 AS PopulationPercentage
FROM COVID19_Project.dbo.CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

-- COUNTRIES WITH HIGHEST INFECTION RATES COMPARED TO POPUATION
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationPercentage
FROM COVID19_Project.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PopulationPercentage DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast (total_deaths AS int)) AS TotalDeathCounts
FROM COVID19_Project.dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeathCounts DESC

--CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(cast (total_deaths AS int)) AS TotalDeathCounts
FROM COVID19_Project.dbo.CovidDeaths
WHERE continent IS  NOT NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths AS int)) AS total_deaths,
SUM(CAST(new_deaths AS int))/ SUM(new_cases)*100 AS DeathPercentage
FROM COVID19_Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-----------------------------

SELECT * 
FROM COVID19_Project.dbo.CovidVaccinations

SELECT * 
FROM COVID19_Project.dbo.CovidDeaths AS dea
JOIN COVID19_Project.dbo.CovidVaccinations AS vac
ON dea.location = Vac.location
AND dea.date = Vac.date

-- TOTAL POPULATION V/S VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.total_vaccinations,
vac.total_vaccinations/dea.population*100 AS TotalVaccinationPercent
FROM COVID19_Project.dbo.CovidDeaths AS dea
JOIN COVID19_Project.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.location LIKE '%India%'
ORDER BY 2,3

-- SUM OF VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST (vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumOfVaccinations
FROM COVID19_Project.dbo.CovidDeaths AS dea
JOIN COVID19_Project.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.location LIKE '%India%'
ORDER BY 2,3

With PopvsVac (Continent, Locarion, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM COVID19_Project.dbo.CovidDeaths AS dea
JOIN COVID19_Project.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT * FROM PopvsVac

-- TEMP TABLE 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM COVID19_Project.dbo.CovidDeaths AS dea
JOIN COVID19_Project.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated