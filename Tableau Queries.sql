-- Queries for Tableau Project--

--1. Global Numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_Deaths
where continent is not ''
Order By 1,2

--2. Total Death Count per Continent

Select location, SUM(CAST(new_deaths as INT)) as TotalDeathCount
FROM Covid_Deaths
where continent is ''
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
Order by TotalDeathCount DESC

--3. Deaths classified by income

Select location, SUM(CAST(new_deaths as INT)) as TotalDeathCount
FROM Covid_Deaths
where continent is ''
and location in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
Order by TotalDeathCount DESC

--4. Highest Death Rate of Each Country

Select location, MAX(CAST(total_deaths as REAL)) as Total_Death_Count
FROM Covid_Deaths
where continent is not ''
Group By location
Order By Total_Death_Count desc

--5.  Infected Percentage of Population per Country

Select location,  population, MAX(total_cases) as Highest_Infection_Count, (MAX(CAST(total_cases as REAL))/population)*100 as Infected_Percentage
FROM Covid_Deaths
where continent is not ''
Group by location, Population
Order By Infected_Percentage desc

--6. Infection Percentage per year

Select Location, Population,date, MAX(CAST(total_cases as REAL)) as HighestInfectionCount,  (MAX(CAST(total_cases as REAL)/Population))*100 as PercentPopulationInfected
From Covid_Deaths
Group by Location, Population, date
order by 1,2,3
