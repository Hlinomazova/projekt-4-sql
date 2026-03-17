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
 AND e.year BETWEEN 2006 AND 2018; -- Aby to sedělo k mzdám v ČR

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
       WHEN ABS(gdp_growth - wage_growth) <= 1 THEN 'Silná (týž rok)'
       WHEN ABS(gdp_growth - wage_growth_next_year) <= 1 THEN 'Silná (násl. rok)'
       ELSE 'Slabá / Žádná'
   END AS wage_causality_check,
   CASE
       WHEN ABS(gdp_growth - food_growth) <= 1 THEN 'Silná (týž rok)'
       WHEN ABS(gdp_growth - food_growth_next_year) <= 1 THEN 'Silná (násl. rok)'
       ELSE 'Slabá / Žádná'
   END AS food_causality_check
FROM analysis
WHERE gdp_growth IS NOT NULL
ORDER BY year;
