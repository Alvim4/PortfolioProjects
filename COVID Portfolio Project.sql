
Select *
From ProjectPortfolio..CovidDeaths
Where continent is not NULL
ORDER BY 3, 4

--Select *
--From ProjectPortfolio..CovidVaccinations
--ORDER BY 3, 4

--Probabilidade de morrer se contrair Covid (Neste caso em Portugal)
Select location, date, total_deaths, total_cases, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS death_percentage
From ProjectPortfolio..CovidDeaths
Where location like '%Portugal%' and total_cases Is Not NULL and total_deaths Is Not NULL
Order By 1, 2

--Percentagem da população que teve Covid (Neste caso em Portugal)
Select location, date, total_cases, population,(CAST(total_cases AS float)/CAST(population AS float))*100 AS cases_percentage
From ProjectPortfolio..CovidDeaths
Where location like '%Portugal%' and total_cases Is Not NULL and population Is Not NULL
Order By 1, 2

--Paises com a maior taxa de infeção comparando com a População
Select location, population, MAX(total_cases) AS HighestInfectionCount,
MAX((CAST(total_cases AS float)/CAST(population AS float))*100) AS percentPopulationInfected
From ProjectPortfolio..CovidDeaths
Where continent is not NULL
Group By location, population
Order By percentPopulationInfected DESC

--Total de Casos de Covid por Pais
Select location, MAX(CAST(total_cases AS float)) AS casesPerCountry
From ProjectPortfolio..CovidDeaths
Where continent is not NULL
Group By location
Order By location ASC

--Total de Mortes por Pais
Select location, MAX(CAST(total_deaths AS float)) AS deathsPerCountry
From ProjectPortfolio..CovidDeaths
Where continent is not NULL
Group By location
Order By location ASC

--Paises com maior numero de mortes por Covid
Select location, MAX(CAST(total_deaths As float)) AS deathsPerCountry
From ProjectPortfolio..CovidDeaths
Where continent is not NULL
Group By location
Order By deathsPerCountry DESC

--Paises com maior população
Select location, MAX(CAST(population As float)) AS populationPerCountry
From ProjectPortfolio..CovidDeaths
Where continent is not NULL
Group By location
Order By populationPerCountry DESC


--Dados por Continente

--Continentes com maior número de Mortes por Covid
Select location, MAX(CAST(total_deaths AS float)) AS totalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is NULL
Group By location
Order By totalDeathCount DESC


--Global Numbers

--Percentagem de mortes por casos de Covid
Select SUM(CAST(new_cases AS float)) AS total_cases, Sum(CAST(new_deaths AS float)) AS total_deaths,
(Sum(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 AS deathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not Null
Order By 1, 2

--Percentagem de pessoas vacinadas em Portugal
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated,
(CAST(vac.people_vaccinated AS float)/CAST(dea.population AS float))*100 AS vaccinatidedPeoplePercentage
From ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.date = vac.date
AND dea.location = vac.location
Where dea.location like '%Portugal%'

--Percentagem de pessoas vacinadas em cada Pais a medida que o tempo vai passando
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CAST(vac.new_vaccinations As float)) Over (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.date = vac.date
And dea.location = vac.location
Where dea.continent is not NULL
And vac.new_vaccinations is not NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Igual mas usando uma Temp Table em vez de um CTE
Drop Table if Exists #temp_RollingPeopleVaccinated
Create Table #temp_RollingPeopleVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccination float,
RollingPeopleVaccinated float,
)
Insert into #temp_RollingPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CAST(vac.new_vaccinations As float)) Over (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.date = vac.date
And dea.location = vac.location
Where dea.continent is not NULL
And vac.new_vaccinations is not NULL

Select *, (RollingPeopleVaccinated/Population)*100
From #temp_RollingPeopleVaccinated


--Creating View to store data for later vizualizations

Create View PercentPopulationVaccinated_2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CAST(vac.new_vaccinations As float)) Over (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.date = vac.date
And dea.location = vac.location
Where dea.continent is not NULL
And vac.new_vaccinations is not NULL

Select *
From PercentPopulationVaccinated_2