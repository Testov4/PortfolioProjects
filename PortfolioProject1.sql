--Select *
--FROM PortfolioProject.dbo.CovidDeaths$

--Select *
--FROM PortfolioProject.dbo.CovidVac

--Select Location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths

-- Total cases vs Total deaths and population vs total cases

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage, (total_cases/population) * 100 as percentage_of_population_got_covid
from PortfolioProject..CovidDeaths
Where continent is not null 
-- Where Location = 'Israel'

-- Highest infection rate compared to population, deaths to population and total death count for every country
Select Location, population, MAX(total_cases) as hihgest_infection_count, MAX((total_cases/population) * 100) as percentage_of_population_got_covid, MAX(total_deaths/population) * 100 as percentage_of_deaths_comp_to_population,
MAX(cast(total_deaths as int)) as deaths
from PortfolioProject..CovidDeaths
Where continent is not null -- to get rid of the rows that contains stats for the whole continents
Group by Location, population
Order by percentage_of_population_got_covid DESC

-- GLOBAL NUMBERS(across the world)
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_percentage
from PortfolioProject..CovidDeaths
Where continent is not null 
Group by date
Order by 1,2
-- to check total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_percentage
from PortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2

-- Total population vs Vaccinations
-- USE CTE
WITH PopvsVac(Continent, Location, Date, Population,new_vaccinations, total_vac)
AS(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (total_vac/Population)*100 as pop_vs_vac
From PopvsVac
--Using same CTE but gives total numbers for every country for the whole period of time
--Select Continent, Location, Population, MAX(total_vac) as total_vac, MAX((total_vac/Population)*100) as pop_vs_vac
--From PopvsVac
--Group by Continent, Location, Population


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vac numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null

Select *, (total_vac/Population)*100 as pop_vs_vac
From #PercentPopulationVaccinated

--VIEW for the visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null