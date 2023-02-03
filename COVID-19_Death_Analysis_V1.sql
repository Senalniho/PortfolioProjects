Select *
From PortfolioProject..[Covid-deaths]
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..[Covid-Vaccinations]
--order by 3,4

---Selection of data required for analysis

Select location,date,total_cases,new_cases, total_deaths,population
From PortfolioProject..[Covid-deaths]
order by 1,2

---Total cases vs Total deaths
---This show the percentage likelihood should someone be infected in Ghana
Select location,date,total_cases, total_deaths, (total_deaths/total_cases*100) as death_rate
From PortfolioProject..[Covid-deaths]
where location like '%Ghana%'
order by 1,2

--- Counties with the highest infection rate compared to population 
Select location, population, max(total_cases) as Highest_Infection_Count,  max((total_cases)/population*100) as infection_rate
From PortfolioProject..[Covid-deaths]
---where location like '%Ghana%'
group by location, population
order by 4 desc


--- Counties with the highest death counts  
Select location, max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..[Covid-deaths]
---where location like '%Ghana%'
where continent is not null
group by location
order by Total_Death_Count desc

---Analysis based on continent with highest death count
Select continent, max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..[Covid-deaths]
---where location like '%Ghana%'
where continent is not null
group by continent
order by Total_Death_Count desc

---Global numbers 

Select date, sum(new_cases)  as new_cases, sum(cast(new_deaths as int)) as new_deaths
From PortfolioProject..[Covid-deaths]
---where location like '%Ghana%'
where continent is not null
Group by date
order by 1,2


Select date, sum(new_cases)  as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_rate
From PortfolioProject..[Covid-deaths]
---where location like '%Ghana%'
where continent is not null
Group by date
order by 1,2


---Joining two tables
---Looking at Total population vs Vaccinations
---use CTE(Common Table Expression)

with PopvsVac ( continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations , sum(convert(bigint,vacc.new_vaccinations ))
	OVER (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid-deaths] as death
join PortfolioProject..[Covid-Vaccinations] as vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
---order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



---Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar (255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations , sum(convert(bigint,vacc.new_vaccinations ))
	OVER (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid-deaths] as death
join PortfolioProject..[Covid-Vaccinations] as vacc
	on death.location = vacc.location
	and death.date = vacc.date
---where death.continent is not null
---order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


create view PopulationVaccinated  as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations , sum(convert(bigint,vacc.new_vaccinations ))
	OVER (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid-deaths] as death
join PortfolioProject..[Covid-Vaccinations] as vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
---order by 2,3

select *
from PopulationVaccinated