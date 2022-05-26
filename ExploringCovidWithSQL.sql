Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4 

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Global Covid Deaths vs Cases 
-- Shows the percentage of deaths from those who reported having Covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Global Covid Cases vs Population  
-- Shows the percentage of the population with reported COVID-19 cases

Select Location, date, total_cases, total_deaths, population, (total_cases/Population)*100 as PercentInfected 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- USA Covid Deaths vs Cases 
-- Shows the percentage of deaths from those who contracted Covid in the USA

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2

-- USA Covid Cases vs Population  
-- Shows the percentage of the population with reported COVID-19 cases in the USA

Select Location, date, total_cases, total_deaths, population, (total_cases/Population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/Population))*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Highest death count by country

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

-- Highest death count by continent

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
group by location
order by TotalDeathCount desc

-- Global cases, deaths and death as percentage of cases
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

-- Sum of global cases, deaths, and death as percentage of cases

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null

-- Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- with CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from PopvsVac

-- with Temp table 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from #PercentPopulationVaccinated

-- Creating view to store data for visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
Where dea.continent is not null