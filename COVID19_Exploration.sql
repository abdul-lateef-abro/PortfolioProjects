Select * from PortfolioProject..CovidDeaths order by 3,4
--Select * from PortfolioProject..CovidVaccinations Order by 3,4

-- Select data that we are goung to be using
Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths 
order by 1,2

-- Looking at Total Cases ve Total Deaths
-- shows likelihood of dying if you contract COVID
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths in Pakistan

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like 'Pakistan'
order by 1,2

-- Lookiong at Total Cases vs Population

Select location, date, total_cases, population,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2


-- Looking at Countries with Highest Infections rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Looking at countries with the highest death count by population
Select location, MAX(cast (total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths 
where continent is not null
group by location
order by TotalDeaths desc

-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing continents with highest death count per population
Select location, MAX(cast (total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths 
where continent is null 
and location not like '%international%' and location not like 'World' and location not like '%Union' and location not like '% income'
group by location
order by TotalDeaths desc


--GLOBAL NUMBERS
-- new cases vs new deaths Globally per day
Select  date, SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, (SUM(cast (new_deaths as int))/SUM(New_Cases))*100 as Percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2


-- Total Cases vs Deaths Wordwide
Select   SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, (SUM(cast (new_deaths as int))/SUM(New_Cases))*100 as Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2



-- Looking at total population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null
order by 2,3 



-- USE CTE
With PopvsVac (continent, Location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null


)
select * ,(rollingpeoplevaccinated/population)*100 as percentageVaccinated 
from PopvsVac
order by 2,3 



--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null

select * ,(RollingPeopleVaccinated/population)*100 as percentageVaccinated 
from #PercentPopulationVaccinated
order by 2,3 



-- Looking at total Vaccination Percentage  in Pakistan

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null and dea.location like 'Pakistan'
order by 2,3 

With PopvsVacPakistan (continent, Location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null  and dea.location like 'Pakistan'


)
select * ,(rollingpeoplevaccinated/population)*100 as percentageVaccinated 
from PopvsVacPakistan
order by 2,3 



--TEMP TABLE
Drop table if exists #PercentVaccinatedPakistan
Create table #PercentVaccinatedpaksitan
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentVaccinatedpaksitan
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null  and dea.location like 'Pakistan'

select * ,(RollingPeopleVaccinated/population)*100 as percentageVaccinated 
from #PercentPopulationVaccinated
order by 2,3 



-- Creating View to store Data for later visualisations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null

 Create View PercentPakistanVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null and dea.location like 'Pakistan'


 Create View DeathLikelihoodByCountry as
 Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 

Create View PakistanCovidDeathPercentage as
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like 'Pakistan'



Create View TotalCasesVDeaths as
Select   SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, (SUM(cast (new_deaths as int))/SUM(New_Cases))*100 as Percentage
from PortfolioProject..CovidDeaths
where continent is not null
