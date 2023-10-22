 select *
from PortfolioProject..CovidDeaths
where location is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows the likelihood of dying fron contracting covid in Nigeria

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location = 'nigeria'
order by 1,2

-- looking at total cases vs population
-- shows what population of the country contracted covid

select location, date, total_cases, population, (total_cases/population)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location = 'nigeria'
order by 1,2


-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'nigeria
group by location, population 
order by PercentagePopulationInfected desc



-- showing countries with highest death count per population

select location, population, max(total_deaths) as HighestDeathCount, max(total_deaths/population)*100 as PercentagePopulationDeath
from PortfolioProject..CovidDeaths
--where location = 'nigeria
group by location, population 
order by PercentagePopulationDeath desc


select location, max(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location = 'nigeria
where location is not null
group by location 
order by TotalDeathCount desc


--let's go by continent

select continent, max(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location = 'nigeria
where continent is not null
group by continent 
order by TotalDeathCount desc


-- Global numbers
--per date

select date, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--In the whole world
select  sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2



--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rollingsum_newvac,
--(rollingsum_newvac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location like 'nigeria' 
order by 2,3






--use CTE

with popvsvac(continent, loaction, date, population, new_vaccinations, rollingsum_newvac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rollingsum_newvac
--(rollingsum_newvac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location like 'nigeria' 
--order by 2,3
)
select *, (rollingsum_newvac/population)*100
from popvsvac


-- use temp table

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric,
rollingsum_newvac numeric
)
insert into 
#percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rollingsum_newvac
--(rollingsum_newvac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--where dea.location like 'nigeria' 
order by 2,3

select *, (rollingsum_newvac/population)*100
from #percentagepopulationvaccinated


--creating view to store for later visualization

create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rollingsum_newvac
--(rollingsum_newvac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location like 'nigeria' 


create view rollingsum_newvac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rollingsum_newvac
--(rollingsum_newvac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


create view PercentagePopulationDeath as
select location, population, max(total_deaths) as HighestDeathCount, max(total_deaths/population)*100 as PercentagePopulationDeath
from PortfolioProject..CovidDeaths
--where location = 'nigeria
group by location, population 
--order by PercentagePopulationDeath desc

create view PercentagePopulationInfected as
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'nigeria
group by location, population 
--order by PercentagePopulationInfected desc

create view Deathpercentage as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location = 'nigeria'
--order by 1,2