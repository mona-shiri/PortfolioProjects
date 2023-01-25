-- Selecting Data that I'm going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total cases vs Total Deaths (in Germany)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location like '%Germany%'
order by 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
Group by location, population
order by InfectionPercentage DESC


-- Showing Contries with highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location
order by TotalDeathCount DESC


-- Showing continents Deatch Count
SELECT continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount DESC


-- Global Numbers
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2



-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.DATE) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2, 3


-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
GO
CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
