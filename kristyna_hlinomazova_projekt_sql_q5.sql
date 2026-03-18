-- Q5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
WITH base_data AS (
	SELECT
		g.year,
		ROUND(((g.gdp / LAG(g.gdp) OVER (ORDER BY g.year)) - 1) * 100, 2) AS gdp_growth,
		ROUND(((w.avg_wage / LAG(w.avg_wage) OVER (ORDER BY g.year)) - 1) * 100, 2) AS wage_growth,
		ROUND(((f.avg_food / LAG(f.avg_food) OVER (ORDER BY g.year)) - 1) * 100, 2) AS food_growth
	FROM (
		SELECT year, gdp FROM t_kristyna_hlinomazova_project_sql_secondary_final WHERE country = 'Czech Republic'
   ) g
	JOIN (
		SELECT payroll_year, AVG(avg_month_salary_czk) AS avg_wage
		FROM t_kristyna_hlinomazova_project_sql_primary_final GROUP BY payroll_year
   ) w ON g.year = w.payroll_year
	JOIN (
		SELECT payroll_year, AVG(avg_price_czk) AS avg_food
		FROM t_kristyna_hlinomazova_project_sql_primary_final GROUP BY payroll_year
   ) f ON g.year = f.payroll_year
),
analysis AS (
	SELECT
		year,
		gdp_growth,
		wage_growth,
		food_growth,
		LEAD(wage_growth) OVER (ORDER BY year) AS wage_growth_next_year,
		LEAD(food_growth) OVER (ORDER BY year) AS food_growth_next_year
	FROM base_data
)
SELECT 
	*,
	CASE
		WHEN ABS(gdp_growth - wage_growth) <= 1 THEN 'Strong (same year)'
		WHEN ABS(gdp_growth - wage_growth_next_year) <= 1 THEN 'Strong (next year)'
		ELSE 'Weak / None'
	END AS wage_causality_check,
	CASE
		WHEN ABS(gdp_growth - food_growth) <= 1 THEN 'Strong (same year)'
		WHEN ABS(gdp_growth - food_growth_next_year) <= 1 THEN 'Strong (next year)'
		ELSE 'Weak / None'
	END AS food_causality_check
FROM analysis
WHERE gdp_growth IS NOT NULL
ORDER BY year;
