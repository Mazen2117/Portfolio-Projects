SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations


--Select Data That We are going to use

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2


--Looking At TotalCases VS TotalDeaths

--Shows likelihood of dying if you contract covid in your country

SELECT  Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentege
FROM PortfolioProject..CovidDeaths
Where location like '%Egypt%'
ORDER BY 1,2

--Looking at Total Cases VS Population

--Shows What Percentage Of Population got Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentPopulation
FROM PortfolioProject..CovidDeaths
Where location like '%Egypt%'
ORDER BY 1,2

--Looking At Countries With Highest Infection Rate Compared To Population

SELECT location,population,Max(total_cases) HighestInfectionCount ,Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected Desc 

--Showing Countries With Highest Death Count Per Population

SELECT location,Max(cast(total_deaths as int)) AS HighestDeathsCount 
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY HighestDeathsCount  Desc 

--Showing Continent With Highest Death Count Per Population 


SELECT location,Max(cast(total_deaths as int)) AS HighestDeathsCount 
FROM PortfolioProject..CovidDeaths
Where continent is  null
GROUP BY location
ORDER BY HighestDeathsCount  Desc 


--Global Numbers


SELECT  Date, SUM(new_cases) AS TotalCases ,SUM(cast(new_deaths as int)) As TotalDeaths ,SUM(cast(new_deaths as int)) /SUM(new_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2


--دي حاجة كدة على جنب يعني شبه تقرير وزارة الصحة اليومي
--(لو فاكرينه)

SELECT  date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentege
FROM PortfolioProject..CovidDeaths
Where location like '%Egypt%'
ORDER BY 1,2


--Looking At Total Population VS Total Vaccinations
--Using CTE

with VacVSPop (Continent,location,date,population,new_vaccinations,RollingPeopleVacinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition By dea.location ORDER BY dea.location , dea.date) As RollingPeopleVacinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location AND dea.Date=vac.Date
	Where dea.continent is not null
	
	)
	Select *,(RollingPeopleVacinated/population)*100
	FROM VacVSPop


--Temp Table

DROP Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(

continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric

)


Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition By dea.location ORDER BY dea.location , dea.date) As RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location AND dea.Date=vac.Date
	
Select *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition By dea.location ORDER BY dea.location , dea.date) As RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location AND dea.Date=vac.Date
	Where dea.continent is not null
	

	SELECT *
	FROM PercentPopulationVaccinated