
Select *
from Project01..CovidDeaths
where continent is not null
order by 3,4


--Select *
--from Project01..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from Project01..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you have covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project01..CovidDeaths
--Where location like 'India'
where continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from Project01..CovidDeaths
--Where location like 'India'
where continent is not null
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population)*100 as PercentagePopulationInfected
from Project01..CovidDeaths
--Where location like 'India'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project01..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing Contintents with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project01..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- Global Numbers by date

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100as DeathPercentage
from Project01..CovidDeaths
--Where location like 'India'
where continent is not null
group by date
order by 1,2


-- Global Numbers

Select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from Project01..CovidDeaths
--Where location like 'India'
where continent is not null
order by 1,2



-- Looking at total Population vs Vaccications

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project01..CovidDeaths dea
join Project01..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and new_vaccinations is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, location ,date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project01..CovidDeaths dea
join Project01..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and new_vaccinations is not null
--order by 2,3 
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- creating a temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project01..CovidDeaths dea
join Project01..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--and new_vaccinations is not null
--order by 2,3 

Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for visulizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project01..CovidDeaths dea
join Project01..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated
