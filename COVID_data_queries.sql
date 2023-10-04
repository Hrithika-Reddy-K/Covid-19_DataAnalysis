--COVID 19 Data Exploration
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Coverting Data Types 


Select * 
FROM Covid_Deaths
where continent is not ''
Order By 3,4

--Date Formatting for both tables

/*DROP Table Covid_Deaths*/

Update Covid_deaths
Set date = CASE
WHEN length(date)=8
THEN substr(date, 5) || "/" || substr(date, 1, 1) || "/" || substr(date, 3, 1)
WHEN length(date)=10
THEN substr(date, 7) || "/" || substr(date, 1, 2) || "/" || substr(date, 4, 2)
ELSE date
END

Update Covid_deaths
Set date = CASE
WHEN length(date)=9 and substr(date,2,1)='/'
THEN substr(date, 6) || "/" || substr(date, 1, 1) || "/" || substr(date, 3, 2)
WHEN length(date)=9 and substr(date,3,1)='/'
THEN substr(date,6) || "/" || substr(date,1,2) || "/" || substr(date,4,1)
ELSE date
END

Update Covid_deaths
Set date = CASE
WHEN substr(date,7,1) = '/'
THEN substr(date,1,4) || "/0" || substr(date,6,1) || "/" || substr(date,8,2)
ELSE date
END

Update Covid_deaths
Set date = CASE
WHEN substr(date,10,1) = ''
THEN substr(date,1,4) || "/" || substr(date,6,2) || "/0" || substr(date,9,2)
ELSE date
END

Select * 
FROM Covid_Vaccinations 
Order By 3,4

/*DROP Table Covid_Vaccinations*/

Update Covid_Vaccinations
Set date = CASE
WHEN length(date)=8
THEN substr(date, 5) || "/" || substr(date, 1, 1) || "/" || substr(date, 3, 1)
WHEN length(date)=10
THEN substr(date, 7) || "/" || substr(date, 1, 2) || "/" || substr(date, 4, 2)
ELSE date
END

Update Covid_Vaccinations
Set date = CASE
WHEN length(date)=9 and substr(date,2,1)='/'
THEN substr(date, 6) || "/" || substr(date, 1, 1) || "/" || substr(date, 3, 2)
WHEN length(date)=9 and substr(date,3,1)='/'
THEN substr(date,6) || "/" || substr(date,1,2) || "/" || substr(date,4,1)
ELSE date
END

Update Covid_Vaccinations
Set date = CASE
WHEN substr(date,7,1) = '/'
THEN substr(date,1,4) || "/0" || substr(date,6,1) || "/" || substr(date,8,2)
ELSE date
END

Update Covid_Vaccinations
Set date = CASE
WHEN substr(date,10,1) = ''
THEN substr(date,1,4) || "/" || substr(date,6,2) || "/0" || substr(date,9,2)
ELSE date
END

--End of date formatting for both tables

Select location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
where continent is not ''
Order By 1

--Looking at Total Cases Vs Total Deaths 
--Shows the likelihood of death when contracted with COVID

/*Select typeof(total_deaths) FROM Covid_Deaths*/

Select location, date, total_cases, total_deaths, (CAST(total_deaths as REAL)/total_cases)*100 as Death_Percentage
FROM Covid_Deaths
where continent is not ''
Order By 1


--Looking at Total Cases Vs Total Deaths in United States
--Shows the likelihood of death when contracted with COVID

Select location, date, total_cases, total_deaths, (CAST(total_deaths as REAL)/total_cases)*100 as Death_Percentage
FROM Covid_Deaths
where continent is not '' and location like '%states'
Order By 1

--Looking at Total Cases Vs Population in United States
--Shows what percentage of population was infected with COVID

Select location, date, total_cases, population, (CAST(total_cases as REAL)/population)*100 as Infected_Percentage
FROM Covid_Deaths
where continent is not '' and location like '%states'
Order By 1,2

--Looking at Highest Infected Rate of each country in descending order

Select location, MAX(total_cases) as Highest_Infection_Count, population, (MAX(CAST(total_cases as REAL))/population)*100 as Infected_Percentage
FROM Covid_Deaths
where continent is not ''
Group by location, Population
Order By Infected_Percentage desc

--Looking at Highest Death Rate of each country

Select location, MAX(CAST(total_deaths as REAL)) as Total_Death_Count
FROM Covid_Deaths
where continent is not ''
Group By location
Order By Total_Death_Count desc

--Breaking things down by continent
--Showing continents with highest death count per population

Select continent, MAX(CAST(total_deaths as REAL)) as Total_Death_Count
FROM Covid_Deaths
where continent is not ''
Group By continent
Order By Total_Death_Count desc



--Global Deaths per day

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_Deaths
where continent is not ''
Group by date
Order By 1

--Global Deaths

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_Deaths
where continent is not ''
Order By 1

--Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as REAL)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not ''
Order by 2,3


--Using CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as REAL)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not ''
Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac


--Temp Table

Drop table if exists PercentPopulationVaccinated;
Create table PercentPopulationVaccinated
(
Continent text,
Location text,
Date datetime,
population real,
new_vaccinations real,
RollingPeopleVaccinated real
);
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as REAL)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not ''
Order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

--Creating view for later visualizations

/*Drop View if exists Percent_PopulationVaccinated*/
Create View Percent_PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as REAL)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_Deaths dea
Join Covid_Vaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not '' 

Select * 
FROM Percent_PopulationVaccinated