# **Analýza dostupnosti základních potravin**

## **Zadání projektu**
Cílem projektu bylo připravit robustní datový podklad pro porovnání dostupnosti základních potravin na základě průměrných příjmů v České republice v letech 2006–2018. Součástí zadání bylo také zpracování dodatečného materiálu v podobě tabulky s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, aby bylo možné sledovat vývoj v ČR v širším evropském kontextu.

## 2. Popis tvorby primární a sekundární tabulky

Pro účely analýzy byly vytvořeny dvě hlavní datové sady, které sjednocují roztříštěná data z různých vládních a ekonomických zdrojů do přehledných celků.

### t_kristyna_hlinomazova_project_SQL_primary_final
Tato tabulka sjednocuje data o průměrných mzdách a cenách potravin v ČR pro zajištění 100% porovnatelnosti v čase.

* **Agregace mezd:** Pomocí **CTE** (`payroll_data`) byly z tabulky `czechia_payroll` vyfiltrovány záznamy pro průměrné hrubé mzdy (kód **5958**) a přepočtené počty zaměstnanců (kód **200**). Data byla seskupena (`GROUP BY`) podle roku a odvětví.
* **Agregace cen:** Z tabulky `czechia_price` byly vybrány celorepublikové průměry kategorií potravin vyfiltrováním regionálních dat (`region_code IS NULL`). Rok měření byl získán funkcí `EXTRACT` z data platnosti a ceny byly zprůměrovány na úroveň roku.
* **Finální integrace:** Obě sady byly propojeny přes **`JOIN`** pomocí společného klíče kalendářního roku. Výsledná tabulka umožňuje přímé srovnání vývoje mezd a cen pro každé odvětví a typ potraviny v jednom řádku.

### t_kristyna_hlinomazova_project_SQL_secondary_final
Tabulka slouží jako dodatečný podklad pro srovnání České republiky s širším evropským kontextem pomocí makroekonomických ukazatelů.

* **Zdroj dat:** Informace o HDP, GINI koeficientu a populaci byly čerpány z tabulek `countries` a `economies`.
* **Filtrace a sjednocení:** Data byla filtrována výhradně na **evropské státy** a časové období **2006–2018**, aby přesně korespondovala s dostupností dat v primární tabulce.
* **Zpracování:** Tabulky byly propojeny přes název státu (`country`), přičemž hodnoty HDP a populace byly zaokrouhleny pro lepší čitelnost a srozumitelnost při následných analýzách.

## **Výzkumné otázky a odpovědi**

**Chybějící a neúplná data**
Vzhledem k tomu, že data o cenách potravin jsou dostupná až od roku 2006, byla analýza omezena na období 2006–2018, ačkoliv mzdová data sahají až do roku 2000. V tabulce mezd se vyskytují záznamy s hodnotou NULL u odvětví, které však nepředstavují chybu, nýbrž celorepublikový průměr využitý pro výpočet celkové kupní síly. Z důvodu regionální neúplnosti u cen potravin pracuje analýza s celorepublikovými průměry. Do srovnání zdražování byly zahrnuty pouze potraviny se souvislou řadou dat, čímž byly vyloučeny položky s výpadky či pozdějším počátkem sledování.

### **1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
Při pohledu na celkové období 2006–2018 mzdy vzrostly ve všech sledovaných odvětvích. Nejvyšší celkový nárůst zaznamenalo odvětví Informační a komunikační činnosti, kde mzda stoupla o 20 935 Kč. Nicméně, při detailním meziročním srovnání analýza odhalila, že mzdy v určitých letech klesaly. V rámci analýzy byl jako kritický rok identifikován rok 2013, kdy došlo k poklesu průměrných mezd u většiny sledovaných odvětví. Nejvýraznější propad v tomto období pocítilo peněžnictví a pojišťovnictví, kde průměrná mzda klesla o 4 484 Kč. Tento negativní trend se projevil i v dalších sektorech, jako byla výroba a rozvod elektřiny, plynu a tepla s poklesem o 1 895 Kč, těžba a dobývání se snížením o 1 053 Kč a profesní, vědecké i technické činnosti, kde mzdy poklesly o 992 Kč
Ostatní roky: K mírnějším poklesům docházelo ojediněle i v letech 2009, 2010 nebo 2011.
Závěr: Dlouhodobý trend je rostoucí, ale mzdy nejsou imunní vůči meziročním výkyvům, což se nejvíce projevilo během ekonomického útlumu v roce 2013.

### **2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
ROK  ODVĚTVÍ                          MZDA   POTRAVINA               CENA   JEDN. KUPNÍ SÍLA
2006 Vzdělávání                       20030  Chléb konzumní kmínový  16.12  kg    1243
2006 Zásobování vodou (...)           18740  Mléko polotučné         14.44  l     1298
2006 Zásobování vodou (...)           18740  Chléb konzumní kmínový  16.12  kg    1163
2006 Zdravotní a sociální péče        19042  Mléko polotučné         14.44  l     1319
2006 Zdravotní a sociální péče        19042  Chléb konzumní kmínový  16.12  kg    1181
2006 Zemědělství, lesnictví...        14818  Mléko polotučné         14.44  l     1026
2006 Zemědělství, lesnictví...        14818  Chléb konzumní kmínový  16.12  kg    919
2006 Zpracovatelský průmysl           18482  Chléb konzumní kmínový  16.12  kg    1147
2006 Zpracovatelský průmysl           18482  Mléko polotučné         14.44  l     1280
...
2018 Informační a kom. činnosti       56728  Chléb konzumní kmínový  24.24  kg    2340
2018 Informační a kom. činnosti       56728  Mléko polotučné         19.82  l     2862
2018 Peněžnictví a pojišťovnictví     54883  Chléb konzumní kmínový  24.24  kg    2264
2018 Peněžnictví a pojišťovnictví     54883  Mléko polotučné         19.82  l     2769
2018 Ubytování, stravování...         19270  Chléb konzumní kmínový  24.24  kg    795
2018 Ubytování, stravování...         19270  Mléko polotučné         19.82  l     972

### **3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**
Analýza ukázala, že nejpomaleji zdražující kategorií je Cukr krystalový. V jeho případě se však nejedná o zdražování, ale o průměrný meziroční pokles ceny o 1,92 %. Druhou položkou, která v průměru zlevňovala, byla Rajská jablka červená kulatá s poklesem o 0,74 %.
První kategorií, u které byl zaznamenán skutečný (kladný) nárůst ceny, jsou Banány žluté, které zdražovaly v průměru pouze o 0,81 % ročně.

### **4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**
Při srovnání meziročního nárůstu cen potravin a mezd bylo zjištěno, že v žádném sledovaném roce rozdíl nepřekročil hranici 10 %. Nejvýraznější rozdíl nastal v roce 2013, kdy ceny potravin vzrostly o 5,10 %, zatímco mzdy zaznamenaly pokles o 1,56 %. Celkový rozdíl tak činil 6,65 procentního bodu.

### **5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**
Analýza dat ukazuje, že vliv HDP na mzdy a ceny není jednoznačný. Vliv na mzdy (poměr 6:6): Vztah mezi HDP a mzdami je přesně vyrovnaný. V 6 případech byla zaznamenána silná korelace (buď v témže roce, nebo s ročním zpožděním), ale ve zbývajících 6 případech byla vazba slabá nebo žádná. To potvrzuje, že mzdy reagují na výkon ekonomiky jen v polovině případů. U vlivu HDP na ceny potravin  je vazba výrazně slabší. Pouze ve 3 případech byla zaznamenána silnější souvislost s HDP, zatímco v 9 případech byla korelace slabá nebo žádná. Ceny potravin se vyvíjejí nezávisle na HDP (např. v roce 2012 kleslo HDP o 0,79 %, ale ceny potravin vzrostly o 6,73 %).
Závěr: Vliv HDP na mzdy je nepravidelný (poměr 50/50), což znemožňuje využít HDP jako spolehlivý prediktor pro růst platů. U potravin je vliv HDP téměř nulový.


