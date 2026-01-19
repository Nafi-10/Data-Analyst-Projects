SELECT * 
FROM PortfolioProject..CovidDeaths
Order By 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

-- Select Data that we are going to be using

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
Order By 1,2

--Looking at Total Case vs Total Deaths
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Bangladesh%'
Order By 1,2

--Looking at Countries with Hight Infection Rate Compared to Population

SELECT location,Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like'%Bangladesh%'
Group By location,population
Order By PercentagePopulationInfected desc

-- Showig Countries with Highest Death Count per Population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By location
Order By TotalDeathCount DESC

--Let's break things down by continent

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group By location
Order By TotalDeathCount DESC

--Global Numbers

SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*1100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By date
Order By 1,2 desc

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*1100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group By date
Order By 1,2 desc

--Joining two table 

SELECT * 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date

--Looking at total population vs vaccination with CTE

With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated) 
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--Looking at total population vs vaccination with Temp_Table

DROP Table if exists #PercentPopulationaccinated
CREATE TABLE #PercentPopulationaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationaccinated 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100 as PersentageofRollingPeopleVaccinated
From #PercentPopulationaccinated 

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
where dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated