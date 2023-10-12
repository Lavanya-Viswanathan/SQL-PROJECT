USE [portfolio projects]

SELECT * FROM CovidDeaths
where continent is not null
ORDER BY 3,4
--TOTAL CASES VS TOTAL DEATHS IN INDIA

SELECT location,DATE, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PERCENTAGE_DEATH
FROM CovidDeaths
WHERE LOCATION='INDIA'
ORDER BY 1,2

--TOTAL CASES VS PERCENTAGE

SELECT location,DATE, total_cases,population ,(total_cases/POPULATION)*100 AS PERCENTAG_AFFECTED
FROM CovidDeaths
--WHERE LOCATION='INDIA'
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO ITS POPULATION


SELECT location,MAX(total_cases) AS MAXIMUM_CASES_COUNT,population ,MAX((total_cases/POPULATION))*100 AS MAXIMUM_INFECTED_PERCENTAGE
FROM CovidDeaths
GROUP BY location,population
ORDER BY MAXIMUM_INFECTED_PERCENTAGE DESC

--showing countries with highest death count on population

SELECT location,MAX(total_deaths ) AS MAXIMUM_death_COUNT 
FROM CovidDeaths
where continent is not null
GROUP BY location
ORDER BY MAXIMUM_death_count DESC

select total_deaths 
from CovidDeaths
where TRY_CONVERT(int,total_deaths) is not null

--LETS BREAK THINGS BY MEANS OF CONTINENT
SELECT location,MAX(total_deaths ) AS MAXIMUM_death_COUNT 
FROM CovidDeaths
where continent is null
GROUP BY location
ORDER BY MAXIMUM_death_count DESC

--now we bring out continentn wise death count per population
SELECT continent,MAX(total_deaths) AS MAXIMUM_death_COUNT 
FROM CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY MAXIMUM_death_count DESC

--sum of new cases on each date
SELECT date,sum(new_cases) as total_new_cases,sum(new_deaths) as Total_new_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as new_death_percentage
FROM CovidDeaths
where continent is not null
and new_cases is not null
and new_deaths is not null
GROUP BY date
order by 1

-- total death percentage across the world
SELECT sum(new_cases) as total_cases,sum(new_deaths) as Total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as total_death_percentage
FROM CovidDeaths
where continent is not null
and new_cases is not null
and new_deaths is not null
order by 1


--NOW LETS LOOK INTO COVID VACCINATION DETAILS
use [portfolio projects]
select * from CovidDeaths d
join covidvaccine v
on d.location=v.location
and d.date=v.date

--looking for total population vs vaccine
select d.continent,d.location,d.date,d.population, v.new_vaccinations  from CovidDeaths d
join covidvaccine v
on d.location=v.location
and d.date=v.date
order by 2,3
--new vaccination based on location on each date.
select d.continent,d.location,d.date,d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated  from CovidDeaths d
join covidvaccine v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3


--PERCENTAGE PEOPLE VACCINATED IN BASED ON LOCATION
--CTE

with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select d.continent,d.location,d.date,d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated  from CovidDeaths d
join covidvaccine v
on d.location=v.location
and d.date=v.date
where d.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 from popvsvac

--TEMP TABLE
drop table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeoplevaccinated numeric
)
insert into #Percentpopulationvaccinated
select d.continent,d.location,d.date,d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated  from CovidDeaths d
join covidvaccine v
on d.location=v.location
and d.date=v.date
--where d.continent is not null
select *,(RollingPeopleVaccinated/population)*100 as populationvcaccinatedpercentage from #Percentpopulationvaccinated

--creating view to use later visuvalzation
create view Percentpopulationvaccinated as
select d.continent,d.location,d.date,d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated  from CovidDeaths d
join covidvaccine v
on d.location=v.location
and d.date=v.date
where d.continent is not null

select * from Percentpopulationvaccinated
















