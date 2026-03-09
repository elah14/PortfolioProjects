 /* ============================================================
       EXPLORATION INITIALE DES DONNÉES
    ============================================================ */

-- Aperçu global de la table
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;



/* ============================================================
    CORRECTION DES TYPES DE DONNÉES
   Les données importées avaient des types incorrects.
   On les convertit vers des formats adaptés.
   ============================================================ */

-- Conversion du total de décès en entier
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths INT;

-- Conversion de la date au format DATE
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN date DATE;

-- Conversion du total des cas en FLOAT (car valeurs volumineuses)
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT;

-- Conversion de la population en BIGINT (valeurs très grandes)
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN population BIGINT;



/* ============================================================
     EXTRACTION DES DONNÉES PRINCIPALES POUR ANALYSE
   ============================================================ */

SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;



/* ============================================================
     ANALYSE : TAUX DE MORTALITÉ
   (Décès / Cas totaux) * 100
   Focus : Maroc & France
   ============================================================ */

-- 🇲🇦 Maroc
SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths / total_cases) * 100 AS taux_mortalite
FROM PortfolioProject..CovidDeaths
WHERE total_cases != 0
  AND location = 'Morocco'
ORDER BY location, date;

-- 🇫🇷 France
SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths / total_cases) * 100 AS taux_mortalite
FROM PortfolioProject..CovidDeaths
WHERE total_cases != 0
  AND location = 'France'
ORDER BY location, date;



/* ============================================================
    ANALYSE : TAUX DE POPULATION INFECTÉE
   (Cas totaux / Population) * 100
   ============================================================ */

-- 🇲🇦 Maroc
SELECT location,
       date,
       total_cases,
       population,
       (total_cases / population) * 100 AS taux_population_infectee
FROM PortfolioProject..CovidDeaths
WHERE total_cases != 0
  AND location = 'Morocco'
ORDER BY location, date;

-- 🇫🇷 France
SELECT location,
       date,
       total_cases,
       population,
       (total_cases / population) * 100 AS taux_population_infectee
FROM PortfolioProject..CovidDeaths
WHERE total_cases != 0
  AND location = 'France'
ORDER BY location, date;



/* ============================================================
     TOP 10 PAYS LES PLUS TOUCHÉS
   Basé sur le taux d’infection maximal observé
   ============================================================ */

SELECT location,
       population,
       MAX((total_cases / population) * 100) AS taux_population_infectee
FROM PortfolioProject..CovidDeaths
WHERE total_cases != 0
  AND population != 0
GROUP BY location, population
ORDER BY taux_population_infectee DESC;



/* ============================================================
     PAYS AVEC LE PLUS GRAND NOMBRE DE DÉCÈS
   ============================================================ */

SELECT location,
       MAX(total_deaths) AS nombre_total_de_deces
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY nombre_total_de_deces DESC;



/* ============================================================
     ANALYSE PAR CONTINENT
   ============================================================ */

SELECT continent,
       MAX(total_deaths) AS nombre_total_de_deces
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY nombre_total_de_deces DESC;



/* ============================================================
     STATISTIQUES MONDIALES GLOBALES
   ============================================================ */

SELECT SUM(CAST(new_cases AS FLOAT)) AS nombre_total_de_cas,
       SUM(CAST(new_deaths AS INT)) AS nombre_total_de_morts,
       (SUM(CAST(new_deaths AS INT)) /
        SUM(CAST(new_cases AS FLOAT))) * 100 AS taux_mortalite_mondial
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;



/* ============================================================
    STATISTIQUES MONDIALES JOUR PAR JOUR
   ============================================================ */

SELECT date,
       SUM(CAST(new_cases AS FLOAT)) AS nombre_de_cas,
       SUM(CAST(new_deaths AS INT)) AS nombre_de_morts,
       (SUM(CAST(new_deaths AS INT)) /
        SUM(CAST(new_cases AS FLOAT))) * 100 AS taux_mortalite
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;



/* ====================================================================================
     NETTOYAGE DES DONNÉES
   Remplacement des populations égales à 0 par NULL CAR pose problème pour les calculs
   ====================================================================================*/

UPDATE PortfolioProject..CovidDeaths
SET population = NULL
WHERE population = 0;



/* ============================================================
     ANALYSE DES VACCINATIONS (CTE)
   Calcul du cumul des vaccinations par pays
   ============================================================ */

WITH VaccinationData AS
(
    SELECT mort.continent,
           mort.location,
           mort.date,
           mort.population,
           vacc.new_vaccinations,

           -- Calcul cumulatif des vaccinations
           SUM(CAST(vacc.new_vaccinations AS FLOAT))
           OVER (PARTITION BY mort.location
                 ORDER BY mort.location, mort.date)
           AS total_vaccinations_a_ce_jour

    FROM PortfolioProject..CovidDeaths mort
    JOIN PortfolioProject..CovidVaccinations vacc
         ON mort.location = vacc.location
        AND mort.date = vacc.date

    WHERE mort.continent IS NOT NULL
)

-- Calcul du pourcentage de population vaccinée
SELECT *,
       (total_vaccinations_a_ce_jour / population) * 100
       AS proportion_population_vaccinee
FROM VaccinationData;



/* ============================================================
     CRÉATION D’UNE VUE POUR VISUALISATION BI
   ============================================================ */

CREATE VIEW VaccinationDataView AS
SELECT mort.continent,
       mort.location,
       mort.date,
       mort.population,
       vacc.new_vaccinations,
       SUM(CAST(vacc.new_vaccinations AS FLOAT))
       OVER (PARTITION BY mort.location
             ORDER BY mort.location, mort.date)
       AS total_vaccinations_a_ce_jour
FROM PortfolioProject..CovidDeaths mort
JOIN PortfolioProject..CovidVaccinations vacc
     ON mort.location = vacc.location
    AND mort.date = vacc.date
WHERE mort.continent IS NOT NULL;



/* ============================================================
   1️⃣4️⃣ REQUÊTES POUR VISUALISATION (TABLEAU / POWER BI)
   ============================================================ */

-- Vue globale
SELECT SUM(CAST(new_cases AS FLOAT)) AS nombre_de_cas,
       SUM(CAST(new_deaths AS INT)) AS nombre_de_morts,
       (SUM(CAST(new_deaths AS INT)) /
        SUM(CAST(new_cases AS FLOAT))) * 100 AS taux_mortalite
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Décès par continent
SELECT continent,
       SUM(CAST(new_deaths AS INT)) AS nombre_de_morts
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY nombre_de_morts DESC;

-- Proportion population infectée
SELECT location,
       population,
       SUM(CAST(new_cases AS FLOAT)) AS nombre_de_cas,
       (SUM(CAST(new_cases AS FLOAT)) / population) * 100
       AS proportion_population_infectee
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY proportion_population_infectee DESC;





--- Proportion population infectée par jour et par pays


SELECT location ,
       population ,
       date ,
       total_cases , 
       (total_cases/population) * 100 as taux_infection
FROM PortfolioProject..CovidDeaths 
ORDER BY location asc, taux_infection desc

