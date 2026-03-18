-- 1. TVORBA PRIMÁRNÍ TABULKY
CREATE TABLE t_kristyna_hlinomazova_project_SQL_primary_final AS
WITH payroll_data AS (
	-- První CTE: mzdy podle odvětví a roků
	SELECT
		payroll_year,
    	cpib.name AS industry_name,
    	ROUND(AVG(cp.value)) AS avg_month_salary_czk
	FROM czechia_payroll AS cp
	JOIN czechia_payroll_industry_branch AS cpib
		ON cp.industry_branch_code = cpib.code
	WHERE cp.value_type_code = 5958
		AND cp.calculation_code = 200
	GROUP BY payroll_year, industry_name
),
price_data AS (
	-- Druhé CTE: průměrné ceny potravin podle roků
	SELECT
		EXTRACT(YEAR FROM date_from) AS price_year,
		cpc.name AS food_category,
		ROUND(AVG(value)::numeric,2) AS avg_price_czk,
		cpc.price_value,
		cpc.price_unit
	FROM czechia_price AS cpr
	JOIN czechia_price_category AS cpc
		ON cpr.category_code = cpc.code
	WHERE region_code IS NULL
	GROUP BY EXTRACT(YEAR FROM date_from), food_category, cpc.price_value, cpc.price_unit
)
-- Finální spojení pro kontrolu dat
SELECT
	payroll_data.payroll_year,
	payroll_data.industry_name,
	payroll_data.avg_month_salary_czk,
	price_data.food_category,
	price_data.avg_price_czk,
	price_data.price_value,
	price_data.price_unit
FROM payroll_data
JOIN price_data
	ON payroll_data.payroll_year = price_data.price_year
ORDER BY payroll_data.payroll_year, payroll_data.industry_name;
