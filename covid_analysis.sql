select * from "CovidDeaths"
order by 3,5;
select * from "CovidVaccination"
order by 3,4;
-- select the columns we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from "CovidDeaths"
order by 1,2;

-- Finding the death percentage in USA 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from "CovidDeaths"
where location like '%States%'
order by 1,2;

-- Finding what percentage of the population got covid in USA

select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
from "CovidDeaths"
where location like '%States%'
order by 1,2;

-- Finding countries having highest infection rate compared to therir population
select location,
       population,
       max(total_cases) as HighestCountOfInfection,
       max((total_cases / population)) * 100 as PercentPopulationInfected
from "CovidDeaths"
where total_cases is not null and
population is not null
group by location, population
order by (max((total_cases / population)) * 100) desc;

--Coutries with highest deaths per population

select continent,location,
       max(total_deaths) as HighestDeath    
from "CovidDeaths"
where total_deaths is not null and
continent is not null
group by continent,location
order by (max(total_deaths)) desc;

--Continent with highest death rate per population

select continent,population,
       max((total_deaths/population)) as HighestDeathPerPopulation    
from "CovidDeaths"
where total_deaths is not null and
continent is not null
group by continent,population
order by (max((total_deaths/population))) desc;

-- Finding what percentage of the population of each country is fully vaccinated.

SELECT 
    d.location,
    d.population,
    (SUM(v.total_vaccinations) / d.population) * 100 AS vaccination_percentage
FROM 
    "CovidDeaths" d
JOIN 
    "CovidVaccination" v
ON 
    d.location = v.location
WHERE 
    v.total_vaccinations IS NOT NULL AND d.population IS NOT NULL
GROUP BY 
    d.location, d.population
ORDER BY 
    vaccination_percentage DESC;
	
-- Finding smoker death percentage of the population of each country. 

SELECT 
    d.location,
    d.population,
    ((SUM(v.female_smokers)+ SUM(v.male_smokers))/ d.population) * 100 AS smoker_death_percentage
FROM 
    "CovidDeaths" d
JOIN 
    "CovidVaccination" v
ON 
    d.location = v.location
WHERE v.female_smokers IS NOT NULL AND v.male_smokers IS NOT NULL AND d.population IS NOT NULL
GROUP BY d.location,d.population
ORDER BY smoker_death_percentage DESC;

-- Total poulation Vs Vaccination

with cov as (SELECT 
    d.location,
    d.population,
	d.continent,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER(PARTITION BY d.location) as Rolling_sum
FROM 
    "CovidDeaths" d
JOIN 
    "CovidVaccination" v
ON 
    d.location = v.location 
	
WHERE d.continent IS NOT NULL and v.new_vaccinations is not null and d.continent is not null
group by d.location,d.population,v.new_vaccinations,d.continent
ORDER BY 1,2)

select continent,location,population,(Rolling_sum/population)*100 as vaccine_percent 
from cov
group by location,population,continent,Rolling_sum,population
order by vaccine_percent desc;

-- Backup the result to a new table new_vac_percent

insert into new_vac_percent
with cov as (SELECT 
    d.location,
    d.population,
	d.continent,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER(PARTITION BY d.location) as Rolling_sum
FROM 
    "CovidDeaths" d
JOIN 
    "CovidVaccination" v
ON 
    d.location = v.location 
	
WHERE d.continent IS NOT NULL and v.new_vaccinations is not null and d.continent is not null
group by d.location,d.population,v.new_vaccinations,d.continent
ORDER BY 1,2)

select continent,location,population,(Rolling_sum/population)*100 as vaccine_percent 
from cov
group by location,population,continent,Rolling_sum,population
order by vaccine_percent desc;







