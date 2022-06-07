select location , date , total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_death
from CovidDeaths 
where location like '%states%'
and continent is not null
order by  1,2
-- shows likely hood of dying in countries

-- Showing Total Cases vs the population
select location, date, total_cases, population, (total_cases/population)*100 as percent_afected
from CovidDeaths
where location in ('United States')
order by 1,2

select location, population, max(total_cases) as HihInfRte, max((total_cases/population))*100 as highest_percent_afected
from CovidDeaths
group by population , location
having location = 'United States'
order by highest_percent_afected desc




-- Shows the total death in location
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location 
 order by TotalDeathCount desc 

 select * from CovidDeaths
 where continent is not null and location = 'United States'
 order by date 

 select  continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by  continent
 order by TotalDeathCount desc

select sum(new_cases) as nnwcasewrld, sum(cast (new_deaths as int)) as totdeathwrld, sum(cast (new_deaths as int))/sum(new_cases)*100 as death_percentagewrld
from CovidDeaths 

where continent is not null
--group by  date
order by  1,2



--Joining two tables on date and location
select * 
from CovidDeaths CD inner join
CovidVaccination CV 
on
cd.date = cv.date 
and 
cd.location = cv.location

--Showing population vs vaccination over the world
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations, cv.people_fully_vaccinated, cast(cv.total_vaccinations as float)
from CovidDeaths CD inner join
CovidVaccination CV 
on
cd.date = cv.date 
and 
cd.location = cv.location
where cd.continent is not null and cast(cv.total_vaccinations as float) > 200000
order by 2,3




--used "over partition" to find out eaach day new vaccination added
-- used CTE to define a new row in the table as" Rollinf..." and found out POPULATION vs VACCINA
with POPvsVAC (continent, location, date, population, new_vaccinations, RPV)
as (
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
,sum (convert(float, cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RPV
from CovidDeaths CD inner join
CovidVaccination CV 
on
cd.date = cv.date 
and 
cd.location = cv.location
where cd.continent is not null 
)
select *,location,(RPV/population)*100 as percpopvaxed
from POPvsVAC
where location = 'Albania'
--order by 2,3

select location, max (total_vaccinations)
from CovidVaccination where continent is not null
group by location
order by 1

--Temperory Table
drop table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
( continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RPV numeric,)


insert into #PercentPopulationVaccinated
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
,sum (convert(float, cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RPV
from CovidDeaths CD inner join
CovidVaccination CV 
on
cd.date = cv.date 
and 
cd.location = cv.location
where cd.continent is not null

select *,location,(RPV/population)*100 as percpopvaxed
from #PercentPopulationVaccinated

--Creating views for visualizations later
create view PercentPopulationVaccinated as
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
,sum (convert(float, cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RPV
from CovidDeaths CD inner join
CovidVaccination CV 
on
cd.date = cv.date 
and 
cd.location = cv.location
where cd.continent is not null

select * from PercentPopulationVaccinated

--creating view of cases vs population in united states
create view USPopvsCase as
select location, date, total_cases, population, (total_cases/population)*100 as percent_afected
from CovidDeaths
where location in ('United States')

