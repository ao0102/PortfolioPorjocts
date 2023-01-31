SELECT *
FROM ProjectCovid..CovidDeaths$
WHERE continent is not null
order by 3,4

--SELECT *
--FROM ProjectCovid..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectCovid..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
--Shows liklihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectCovid..CovidDeaths$
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got COVID

SELECT location, date, population, total_cases,(total_deaths/population)*100 as PercentofPopulationInfected
FROM ProjectCovid..CovidDeaths$
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM ProjectCovid..CovidDeaths$
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected desc

--Showing Countries with the highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectCovid..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount desc

--Let's Break Things Down By Continent
CREATE VIEW ContinentVIEW as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectCovid..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ProjectCovid..CovidDeaths$
-- WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths$ dea
JOIN ProjectCovid..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentageofPeopleVaccinated


--Temp Table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths$ dea
JOIN ProjectCovid..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PERCENTPOPULATIONVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths$ dea
JOIN ProjectCovid..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
