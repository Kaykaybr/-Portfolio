Create view CovidCasesandDeaths2020 as
SELECT MONTH(date) AS Month, SUM(CAST(new_cases AS INT)) AS Total_case, SUM(CAST(new_deaths AS INT)) AS Total_Death
FROM PortfolioProject..CovidDeaths
WHERE YEAR(date) = '2020' and continent is not null
GROUP BY MONTH(date)
ORDER BY Month

Create view CovidCasesandDeaths2021 as
SELECT MONTH(date) AS Month, SUM(CAST(new_cases AS INT)) AS Total_case, SUM(CAST(new_deaths AS INT)) AS Total_Death
FROM PortfolioProject..CovidDeaths
WHERE YEAR(date) = '2021' and continent is not null
GROUP BY MONTH(date)
ORDER BY Month


Create view Percent2020 as
SELECT MONTH(date) AS Month, 
	(SUM(CAST(new_cases AS INT))/SUM(DISTINCT population))*100 AS Percent_Confirmed_Case,
	(SUM(new_cases)/(SUM(DISTINCT population)-SUM(new_cases)))*100 AS New_Cases_Percent,
	AVG((total_deaths/total_cases)*100) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and YEAR(date) ='2020'
GROUP BY MONTH(date)
ORDER BY Month


Create view Percent2021 as
SELECT MONTH(date) AS Month, 
	(SUM(CAST(new_cases AS INT))/SUM(DISTINCT population))*100 AS Percent_Confirmed_Case,
	(SUM(new_cases)/(SUM(DISTINCT population)-SUM(new_cases)))*100 AS New_Cases_Percent,
	AVG((total_deaths/total_cases)*100) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and YEAR(date) ='2021'
GROUP BY MONTH(date)
ORDER BY Month


Create view VaccinationRatePerMonth2021 as
WITH PopVac AS 
(
	SELECT MONTH(D.date) AS Month, SUM(DISTINCT D.population) AS population,
		SUM(SUM(CAST(V.new_vaccinations AS INT)))
		OVER (
			PARTITION BY MONTH(D.date)
			ORDER BY MONTH(D.date)
			ROWS UNBOUNDED PRECEDING
		) AS Culminated_New_Vaccinations
	FROM PortfolioProject..CovidDeaths AS D
	JOIN PortfolioProject..CovidVaccinations AS V 
		ON D.location = V.location AND D.date = V.date
	WHERE D.continent is not null and YEAR(D.date) = '2021'
	GROUP BY MONTH(D.date)
)
SELECT Month, (Culminated_New_Vaccinations/population)*100 AS Percent_of_Vaccinated_Pop
FROM PopVac

