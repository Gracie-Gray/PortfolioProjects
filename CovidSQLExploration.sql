
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs. Total Deaths
-- Likelihood of death if covid was contracted within the US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Total Cases vs. Population
-- Percent of population that contracted COVID in the US

Select Location, date, population, total_cases, (total_cases/population)*100 as COVIDPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as COVIDPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
order by COVIDPercentage desc


-- Countries with highest death count by population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Continents with highest death count by population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


-- Global
-- Death percentage by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2


-- Total cases, deaths, and death percentage globally

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2




-- Total Population vs Vaccinations
-- With rolling vaccination count

Select cDeath.continent, cDeath.location, cDeath.date, cDeath.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by cDeath.Location Order by cDeath.Location, cDeath.Date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths cDeath
Join PortfolioProject..CovidVaccinations vac
	On cDeath.location = vac.location
	and cDeath.date = vac.date
Where cDeath.continent is not null
order by 2,3

-- Using CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select cDeath.continent, cDeath.location, cDeath.date, cDeath.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by cDeath.Location Order by cDeath.Location, cDeath.Date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths cDeath
Join PortfolioProject..CovidVaccinations vac
	On cDeath.location = vac.location
	and cDeath.date = vac.date
Where cDeath.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac


-- Using TEMP TABLE

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

Insert into #PercentPopulationVaccinated
Select cDeath.continent, cDeath.location, cDeath.date, cDeath.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by cDeath.Location Order by cDeath.Location, cDeath.Date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths cDeath
Join PortfolioProject..CovidVaccinations vac
	On cDeath.location = vac.location
	and cDeath.date = vac.date
Where cDeath.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cDeath.continent, cDeath.location, cDeath.date, cDeath.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by cDeath.Location Order by cDeath.Location, cDeath.Date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths cDeath
Join PortfolioProject..CovidVaccinations vac
	On cDeath.location = vac.location
	and cDeath.date = vac.date
Where cDeath.continent is not null

