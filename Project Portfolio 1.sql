
SELECT *
FROM CovidDeaths$


SELECT *
FROM CovidVaccinations$

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2
   

SELECT location, MAX(population), MAX(total_deaths) maxdeath, MAX(total_deaths/population)*100 as DeathToPopulation
FROM CovidDeaths$
GROUP By location
ORDER By 1 DESC

SELECT location, MAX(cast(total_deaths as int)) as maxdeaths
FROM CovidDeaths$
WHERE continent is NULL
GROUP BY location
ORDER BY 2 DESC


-- showing continents with highest death count

--Global numbers

SELECT location, SUM(total_cases) totalcases, SUM(cast(total_deaths as int)) totaldeaths, (SUM(cast(total_deaths as int))/SUM(total_cases))*100 as PercentageDeaths
FROM CovidDeaths$
where continent is NOT NULL
GROUP BY location
ORDER BY 4 DESC

-- Covid vaccinations

SELECT *
FROM CovidVaccinations$

Create view PercentPopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingpeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as RollingpeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location) as RollingpeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3
