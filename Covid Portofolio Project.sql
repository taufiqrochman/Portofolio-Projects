--Query Tabel covid_deaths
--Select semua data di tabel [[covid_deaths]] yang berlokasi di Asia dan mengurutkan berdasarkan tanggal dari yang terdahulu
SELECT*FROM [dbo].[covid_deaths]
WHERE continent='Asia'
ORDER BY 3,4

--Select Data yang akan digunakan dan mengurutkan berdasarkan nama negara dan tanggal dari yang terdahulu
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[covid_deaths]
WHERE continent='Asia'
ORDER BY 1,2

--Select data Total cases vs total deaths dan melihat persentasenya
--menggunakan NULLIF untuk handle pembagian nilai 0
SELECT location, date, total_cases, total_deaths, (NULLIF(total_deaths, 0)/NULLIF(total_cases, 0))*100 AS death_percentage
FROM [dbo].[covid_deaths]
WHERE continent='Asia'
ORDER BY 1,2

--Select data Total cases vs population dan melihat persentasenya
SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
FROM [dbo].[covid_deaths]
WHERE continent='Asia'
ORDER BY 1,2

--Select Negara di Benua Asia dengan kasus covid tertinggi
SELECT location, MAX(total_cases) as case_count
FROM [dbo].[covid_deaths]
WHERE continent='Asia'
GROUP BY location, population
ORDER BY case_count DESC

--Select Negara di Benua Asia dengan persentase kasus covid tertinggi dibandingkan dengan populasi
SELECT location, MAX(total_cases) as case_count, population, (MAX(total_cases)/population)*100 AS percentage_covid_infected
FROM [dbo].[covid_deaths]
WHERE continent='Asia'
GROUP BY location, population
ORDER BY 4 DESC

--Select Negara di Benua Asia dengan jumlah kematian covid tertinggi
SELECT location, MAX(total_deaths) as deaths_count
FROM [dbo].[covid_deaths]
WHERE continent='Asia'
GROUP BY location, population
ORDER BY deaths_count DESC

--Select Negara di Benua Asia dengan persentase jumlah kematian covid tertinggi dibandingkan dengan populasi
SELECT location, MAX(total_deaths) as deaths_count, population, (MAX(total_deaths)/population)*100 AS deaths_percentage
FROM [dbo].[covid_deaths]
WHERE continent='Asia'
GROUP BY location, population
ORDER BY 4 DESC


--====================================================================================================================--
--Query Table covid_vaccinations
--Select semua data di tabel [covid_vaccinations] yang berlokasi di Asia dan mengurutkan berdasarkan nama negara dan tanggal dari yang terdahulu
SELECT*FROM [dbo].[covid_vaccinations]
WHERE continent='Asia'
ORDER BY 3,4

--====================================================================================================================--
--JOIN Table covid_deaths dan covid_vaccinations untuk melihat total population vs total vaccinations
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS cum_people_vaccinated
--(cum_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM covid_deaths a
JOIN covid_vaccinations b
ON a.location = b.location AND
a.date = b.date
WHERE a.continent='Asia'
ORDER BY 2,3

--====================================================================================================================--
--Menggunakan CTE
--Common Table Expression (CTE) adalah salah satu bentuk query SQL yang digunakan untuk menyederhanakan JOIN pada SQL kedalam subqueries dan mampu memberikan query yang bersifat hieararki.

with population_vs_vaccinated (continent, location, date, population, new_vaccinated, cum_people_vaccinated)
as
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS cum_people_vaccinated
--(cum_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM covid_deaths a
JOIN covid_vaccinations b
ON a.location = b.location AND
a.date = b.date
WHERE a.continent='Asia'
)
SELECT*,(cum_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM population_vs_vaccinated

--====================================================================================================================--
--CREATE VIEW untuk menyimpan QUERY dan DATA yang dapat dilihat nanti

CREATE VIEW percent_population_vaccinated AS
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS cum_people_vaccinated
--(cum_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM covid_deaths a
JOIN covid_vaccinations b
ON a.location = b.location AND
a.date = b.date
WHERE a.continent='Asia'

--Memanggil Views yang pernah dibuat
SELECT*FROM percent_population_vaccinated