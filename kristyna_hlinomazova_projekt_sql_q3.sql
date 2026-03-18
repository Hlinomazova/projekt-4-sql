-- Q3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
WITH price_tables AS (
	SELECT
		payroll_year, 
		food_category,
		AVG(avg_price_czk) AS avg_price_current_year,
		LAG(AVG(avg_price_czk)) OVER (PARTITION BY food_category ORDER BY payroll_year) AS avg_price_previous_year
	FROM t_kristyna_hlinomazova_project_sql_primary_final
	GROUP BY payroll_year, food_category
),
growth_calc AS (
	SELECT
		food_category,
		ROUND((avg_price_current_year / avg_price_previous_year - 1) * 100, 2) AS price_growth_percent
	FROM price_tables
)
SELECT
	food_category,
	ROUND(AVG(price_growth_percent), 2) AS avg_yearly_growth_pct
FROM growth_calc
WHERE price_growth_percent IS NOT NULL
GROUP BY food_category
ORDER BY avg_yearly_growth_pct ASC;
