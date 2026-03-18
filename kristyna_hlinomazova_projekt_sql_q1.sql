-- 3. VÝZKUMNÉ OTÁZKY
-- Q1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- Identifikace konkrétních odvětví a let, kdy došlo k meziročnímu poklesu
SELECT *
FROM (
	SELECT
		industry_name,
		payroll_year,
		avg_month_salary_czk,
		avg_month_salary_czk - LAG(avg_month_salary_czk) OVER (PARTITION BY industry_name ORDER BY payroll_year) AS salary_diff
	FROM (
		SELECT DISTINCT industry_name, payroll_year, avg_month_salary_czk
		FROM t_kristyna_hlinomazova_project_SQL_primary_final
	) AS selected_payroll_data
) AS final_table
WHERE salary_diff < 0  
ORDER BY salary_diff ASC; 

-- Celkové porovnání platů mezi prvním (2006) a posledním (2018) rokem
SELECT
	industry_name,
	MAX(CASE WHEN payroll_year = 2006 THEN avg_month_salary_czk END) AS salary_2006,
	MAX(CASE WHEN payroll_year = 2018 THEN avg_month_salary_czk END) AS salary_2018,
	MAX(CASE WHEN payroll_year = 2018 THEN avg_month_salary_czk END) -
	MAX(CASE WHEN payroll_year = 2006 THEN avg_month_salary_czk END) AS total_growth_czk
FROM (
	SELECT DISTINCT industry_name, payroll_year, avg_month_salary_czk
	FROM t_kristyna_hlinomazova_project_SQL_primary_final
) AS clean_data
GROUP BY industry_name
ORDER BY total_growth_czk DESC;
