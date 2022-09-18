select * from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4 


--select * from [Portfolio Project]..CovidVaccination order by 3,4

-- select data that we re going to use

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs Total deaths.
-- shows the likelihood of deing if you contract covid in your country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid.
select location, date, population, total_cases,(total_cases/population)*100 as InfectedPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2


--looking at the countries with highest infection rate
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPercentage
from [Portfolio Project]..CovidDeaths
group by location, population
order by InfectedPercentage desc

--Showing the highest death count per population
select location, Max(cast(total_deaths as int)) as HighestDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc


--Showing continents with highest death count
select continent, Max(cast(total_deaths as int)) as HighestDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

-- Global Numbers
select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total global data
select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination data
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dae.location order by dae.location, dae.date) as rollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as dae
JOIN [Portfolio Project]..CovidVaccination as vac
  on dae.location = vac.location
  and dae.date = vac.date
where dae.continent is not null
order by 2,3

--Using CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dae.location order by dae.location, dae.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as dae
JOIN [Portfolio Project]..CovidVaccination as vac
  on dae.location = vac.location
  and dae.date = vac.date
where dae.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100  from PopVsVac order by 2,3


--CREATE table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dae.location order by dae.location, dae.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as dae
JOIN [Portfolio Project]..CovidVaccination as vac
  on dae.location = vac.location
  and dae.date = vac.date
where dae.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100  from #PercentPopulationVaccinated order by 2,3

--Creating view
Create View PercentPopulationVaccinated1 as
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dae.location order by dae.location, dae.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as dae
JOIN [Portfolio Project]..CovidVaccination as vac
  on dae.location = vac.location
  and dae.date = vac.date
where dae.continent is not null

Select * from PercentPopulationVaccinated1



