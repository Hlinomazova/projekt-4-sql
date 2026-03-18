-- 2. TVORBA SEKUNDÁRNÍ TABULKY
CREATE TABLE t_kristyna_hlinomazova_project_SQL_secondary_final AS
SELECT
	e.year,
	c.country,
	ROUND(e.population) AS population,
	ROUND(e.gdp::numeric, 0) AS gdp,
	ROUND(e.gini::numeric, 1) AS gini
FROM countries AS c
JOIN economies AS e
	ON c.country = e.country
WHERE c.continent = 'Europe'
	AND e.year BETWEEN 2006 AND 2018; 
