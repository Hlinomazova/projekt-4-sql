-- Q4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
WITH growth_comparison AS (
	SELECT
		payroll_year,
		AVG(avg_price_czk) AS avg_price,
		LAG(AVG(avg_price_czk)) OVER (ORDER BY payroll_year) AS prev_price,
		AVG(avg_month_salary_czk) AS avg_salary,
		LAG(AVG(avg_month_salary_czk)) OVER (ORDER BY payroll_year) AS prev_salary
	FROM t_kristyna_hlinomazova_project_sql_primary_final
	GROUP BY payroll_year
)
SELECT
	payroll_year,
	ROUND((avg_price / prev_price - 1) * 100, 2) AS food_growth,
	ROUND((avg_salary / prev_salary - 1) * 100, 2) AS wage_growth,
	ROUND(((avg_price / prev_price - 1) * 100) - ((avg_salary / prev_salary - 1) * 100), 2) AS difference
FROM growth_comparison
WHERE prev_price IS NOT NULL 
ORDER BY difference DESC;
