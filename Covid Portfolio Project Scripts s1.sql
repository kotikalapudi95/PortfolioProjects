/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of Population got covid

Select Location, date,Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--where location like '%states%' and continent is not null  
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select Location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Shows the countries with the highest death count per population---

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' 
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THING DOWN BY CONTINENT

Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc 

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is null
Group by Location
order by TotalDeathCount desc



Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' -- change 'states' to whichever country you want to look at
Where continent is  null 
and Location <>'Upper middle income' and Location<>'Lower middle income' and Location<> 'High income'and Location<> 'Low income'
Group by Location
order by TotalDeathCount desc
-- This shows TotalDeathCount per continent correctly


--Showing continents with highest death count per population
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc 



---GLOBAL NUMBERS----

Select date, SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
order by 1,2



Select SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2





--Looking at Total Population vs Vaccinations----


Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date

	-- just to check if they joined correctly

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, 
dea.date ) 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinates/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3




---------USING CTE----- 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinates/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


----TEMP TABLE---

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinates/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




----Creating View to store data for later Data Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinates/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
