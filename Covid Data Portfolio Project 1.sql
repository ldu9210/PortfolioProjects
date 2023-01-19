Select *
FROM PortfolioProject2..CovidDeaths
WHERE continent is not null
order by 3,4


--Select *
--FROM PortfolioProject2..CovidVaccinations
--order by 3,4


-- Select Data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject2..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in the UK

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
Where location = 'United Kingdom'
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what % of the population got Covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PrecentPopulationInfected
FROM PortfolioProject2..CovidDeaths
Where location = 'United Kingdom'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PrecentPopulationInfected
From PortfolioProject2..CovidDeaths
--Where location = 'United Kingdom'
Group by location, population
Order by PrecentPopulationInfected desc

--Over 70% of the population in Cyprus has been infected with Covid by Jan 2023, which makes it the country with the highest precentage of it's population infected in the World (from the countries who have made their records public)


-- Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount desc

-- Over 1m people have died from Covid in the US since the beginning of the pandemic, this the most amount of lives lost out of any country who have made thier records public. 


------ Let's break things down by continent

--Showing continents with the hihghest death count 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount desc


---  NOTE TO SELF!-----INSERT THE REST OF THE STUFF BY CONTINENT----



--Global Numbers 

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
--Where location = 'United Kingdom'
where continent is not null
group by date
order by 1,2



Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
--Where location = 'United Kingdom'
where continent is not null
--group by date
order by 1,2

--- Since the begining of the pandemic, there has been over 665 million cases of Covid and nearly 6.7 million deaths globally

--- Looking at Total Population vs Vaccinations i.e. Vaccination Percentage Globally

--USING CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(replace(vac.new_vaccinations,'.','') as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPercentageVaccinated
From PopvsVac

--USING TEMP TABLE 

DROP Table if exists #PercentPopulationVaccincated

Create Table #PercentPopulationVaccincated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccincated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(replace(vac.new_vaccinations,'.','') as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPercentageVaccinated
From #PercentPopulationVaccincated

