
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Cases Vs Total Deaths
Create view DeathPercentPerDay as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percenatage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Average Death Percentage for each Country
Create view AverageDeathPercentagePerCountry as
SELECT Location, AVG((total_deaths/total_cases)*100) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Location

--Looking at Total Cases Vs Population
Create view CountriesWithHighestConfirnmedRate as
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Confirmed_Population_Percent
FROM PortfolioProject..CovidDeaths
WHERE location like 'Jamaica'
ORDER BY 1,2

--Countries with the highest infection rates
Create view CountriesWithHighestInfectionRate as
SELECT Location, population,  MAX(total_cases) AS Total_cases, MAX((total_cases/population))*100 AS Confirmed_Population_Percent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
--ORDER BY Confirmed_Population_Percent DESC

--Countries with the Highest Death Count Per Population
Create view CountriesWithHighDeathRate as
SELECT Location, MAX(CAST(total_deaths AS INT)) AS Total_death 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Total_death DESC


--Continent with the Highest Death Count Per Population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS Total_death 
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY Total_death DESC


--Global Numbers
Create view GlobalCovidDeaths as
SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percenatage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2


--New Cases
SELECT Location, AVG(new_cases) AS New_Cases
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Location

Create view NewCasesFromUnaffectedPopulation as
SELECT Location, AVG(new_cases) AS New_Cases, (AVG(new_cases)/(AVG(population)-AVG(total_cases)))*100 AS New_Cases_Percent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
--ORDER BY Location



--Vaccinations Table

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS INT)) 
		OVER (
			PARTITION BY D.location
			ORDER BY D.date
			ROWS UNBOUNDED PRECEDING
		) AS Culminated_New_Vaccinations
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
	ON D.location = V.location AND D.date = V.date
WHERE D.continent is not null
ORDER BY 2,3


WITH PopVac AS 
(
	SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS INT)) 
		OVER (
			PARTITION BY D.location
			ORDER BY D.date
			ROWS UNBOUNDED PRECEDING
		) AS Culminated_New_Vaccinations
	FROM PortfolioProject..CovidDeaths AS D
	JOIN PortfolioProject..CovidVaccinations AS V
		ON D.location = V.location AND D.date = V.date
	WHERE D.continent is not null
)
SELECT *, (Culminated_New_Vaccinations/population)*100 AS Percent_of_Vaccinated_Pop
FROM PopVac
ORDER BY 2,3


WITH PopVac AS 
(
	SELECT D.continent, D.location, D.population,
		SUM(CAST(V.new_vaccinations AS INT)) AS Culminated_New_Vaccinations
	FROM PortfolioProject..CovidDeaths AS D
	JOIN PortfolioProject..CovidVaccinations AS V
		ON D.location = V.location AND D.date = V.date
	WHERE D.continent is not null
	GROUP BY D.continent, D.location, D.population
)
SELECT *, (Culminated_New_Vaccinations/population)*100 AS Percent_of_Vaccinated_Pop
FROM PopVac
ORDER BY Percent_of_Vaccinated_Pop DESC


Create view PercentofPeopleVaccinated as
WITH PopVac AS 
(
	SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS INT)) 
		OVER (
			PARTITION BY D.location
			ORDER BY D.date
			ROWS UNBOUNDED PRECEDING
		) AS Culminated_New_Vaccinations
	FROM PortfolioProject..CovidDeaths AS D
	JOIN PortfolioProject..CovidVaccinations AS V
		ON D.location = V.location AND D.date = V.date
	WHERE D.continent is not null
)
SELECT *, (Culminated_New_Vaccinations/population)*100 AS Percent_of_Vaccinated_Pop
FROM PopVac
