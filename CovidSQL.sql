select *
from CovidDeaths
where continent is not null
order  by 3,4

select *
from CovidVac
order  by 3,4

/*select data that we will be usisng for the analysis*/
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--looking at total cases vs total deaths 
--shows the likelihood of dying if you contract covid in a country 
select location, date, total_cases, total_deaths, 
		round((total_deaths/total_cases)*100, 2) as deathpercentage
from CovidDeaths
where location like '%germany%' and 
		continent is not null
order by 1,2


--looking at total cases vs population 
--showing the percentage of the population that contracted covid 
select location, date, population, total_cases,
		round((total_cases/population)*100 , 2) as InfectedPercentage
from CovidDeaths
--where location like '%germany%' and continent is not null
order by 1,2


--looking at countries with the highest infection rate compared to population 
select location,population, max(total_cases) as highestinfectioncount, 
		max(total_cases/population)*100 as percentpopulationinfected
from CovidDeaths
--where location like '%germany%' and continent is not null
group by location, population
order by percentpopulationinfected desc 


--showing countries with the highest death count per population 
select location, max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not null
group by location
order by Totaldeathcount desc 


--  calculating the total death count by continent
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not  null
group by continent 
order by Totaldeathcount desc 


--globaldeath percentage total 
select sum(new_cases) as totalcases, 
		sum(cast(new_deaths as int)) as totaldeaths,
	    (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
from coviddeaths
where continent is not null
order by 1,2

--global death percentage on a daily basis
select date, sum(new_cases) as totalcases, 
		sum(cast(new_deaths as int)) as totaldeaths,
	    (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
from coviddeaths
where continent is not null
group by date 
order by 1,2



--combining covid death and vaccinations tables
select *
from CovidDeaths as dea
join CovidVac as vac
	on dea.location = vac.location
	and dea.date = vac.date
 

 --looking at the total population vs total vaccination records
select dea.continent, dea.location, dea.date, dea.population, 
	   vac.new_vaccinations, 
	   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
			dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVac as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
 
 --using CTE
 with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
 as 
 (select dea.continent, dea.location, dea.date, dea.population, 
	   vac.new_vaccinations, 
	   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
			dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVac as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, round((rollingpeoplevaccinated/population)*100, 2) as population_vaccinated_percent
from popvsvac


--TEMP TABLE 
--drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(235),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

Insert into  #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, 
	   vac.new_vaccinations, 
	   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
			dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVac as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later 
create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, 
	   vac.new_vaccinations, 
	   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
			dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVac as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated