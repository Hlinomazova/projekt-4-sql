-- Q2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
-- Rozpis podle jednotlivých odvětví
SELECT *,
	ROUND(tkhpspf.avg_month_salary_czk /tkhpspf.avg_price_czk) AS purchasing_power
FROM t_kristyna_hlinomazova_project_sql_primary_final AS tkhpspf
WHERE tkhpspf.food_category IN ('Mléko polotučné pasterované','Chléb konzumní kmínový')
AND tkhpspf.payroll_year IN (
	(SELECT MIN(payroll_year) FROM t_kristyna_hlinomazova_project_sql_primary_final),
	(SELECT MAX(payroll_year) FROM t_kristyna_hlinomazova_project_sql_primary_final));

-- Souhrnný výpočet z průměrné celorepublikové mzdy
SELECT
	payroll_year,
	food_category,
	ROUND(AVG(avg_month_salary_czk), 0) AS avg_national_salary,
	avg_price_czk,
	ROUND(AVG(avg_month_salary_czk) / avg_price_czk, 0) AS purchasing_power
FROM t_kristyna_hlinomazova_project_sql_primary_final
WHERE food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
	AND payroll_year IN (
	(SELECT MIN(payroll_year) FROM t_kristyna_hlinomazova_project_sql_primary_final),
	(SELECT MAX(payroll_year) FROM t_kristyna_hlinomazova_project_sql_primary_final)
 )
GROUP BY payroll_year, food_category, avg_price_czk
ORDER BY food_category, payroll_year;
