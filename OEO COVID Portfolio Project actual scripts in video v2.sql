
SELECT *
FROM PortfoilioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfoilioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfoilioProject..CovidDeaths
Where continent is not null
ORDER BY 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfoilioProject..CovidDeaths
Where location like '%nigeria%'
and continent is not null
ORDER BY 1,2



-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfoilioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population


SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfoilioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
ORDER BY PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfoilioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
ORDER BY TotalDeathCount desc



SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfoilioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfoilioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc



-- Showing the Continents wit the highest death count per population


SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfoilioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc




-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfoilioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
ORDER BY 1,2


-- Looking at Total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On DEA.LOCATION = VAC.LOCATION
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On DEA.LOCATION = VAC.LOCATION
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Temp Table

DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On DEA.LOCATION = VAC.LOCATION
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #percentPopulationVaccinated


-- Creating View to store data for later visualizations


Create View percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On DEA.LOCATION = VAC.LOCATION
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From percentPopulationVaccinated