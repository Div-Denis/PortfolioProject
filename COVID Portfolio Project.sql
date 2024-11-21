Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Case vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%china%'
and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%taiwan%'
and continent is not null
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
       PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount desc

-- Let's Break Things Down by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount desc


-- Showing contintents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount desc


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100  as DeathPercentage 
From PortfolioProject..CovidDeaths
-- Where location like '%china%'
Where continent is not null
Order by 1,2


Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
Order by 1,2

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT( int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RllingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
Order by 2, 3


-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RillingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT( int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RllingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
-- Order by 2, 3
)
Select *, (RillingPeopleVaccinated/population)* 100 as Vaccination_rates
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RllingPeopleVaccinated numeric
)

Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT( int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RllingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
-- where dea.continent is not null
-- Order by 2, 3

Select *, (RllingPeopleVaccinated/population)* 100 as Vaccination_rates
From #PercentpopulationVaccinated


-- Creating view to store data for later visualizations
Create View PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT( int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RllingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3

Select *
From PercentpopulationVaccinated