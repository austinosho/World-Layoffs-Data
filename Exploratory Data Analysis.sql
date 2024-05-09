-- Exploratory Data Analysis
-- We are going to explore the data and find trends or patterns or anything interesting

-- View the data
SELECT * FROM layoffs_clone2;

-- Looking at the maximum total_laid_off
SELECT 
    MAX(total_laid_off)
FROM layoffs_clone2;
-- The maximum number of layoffs at once was 12,000.

-- Looking at the percentage to see how significant these layoffs were
SELECT 
    MAX(percentage_laid_off)
FROM layoffs_clone2;
-- Multiple companies laid off 100% of their workforce.

-- Companies with 1 in the percentage_laid_off column laid off 100% of their workforce
SELECT * 
FROM layoffs_clone2 
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- For example, Blockfi laid off 100% of its workforce and closed down.

-- I have a personal interest in the crypto industry, so let's see the data we have for that industry
SELECT * 
FROM layoffs_clone2 
WHERE industry = 'crypto'
ORDER BY total_laid_off DESC;

-- Looking at the company and the sum of their total layoffs
SELECT company,
SUM(total_laid_off) as "Total Laid Off"
FROM layoffs_clone2
GROUP BY 1
ORDER BY 2 DESC;
-- Amazon has the highest total layoffs followed by Google and then Meta.

-- What is the date range for these layoffs?
SELECT 
MIN(`date`), 
MAX(`date`)
FROM layoffs_clone2;
-- The date range is between 2020-03-11 and 2023-03-06.

-- Which industry had the most layoffs?
SELECT industry,
SUM(total_laid_off) as "Total Laid Off"
FROM layoffs_clone2
GROUP BY 1
ORDER BY 2 DESC;
-- The Consumer and Retail industries had the most layoffs, which is not surprising.

-- Which country had the most layoffs?
SELECT country,
SUM(total_laid_off) as "Total Laid Off"
FROM layoffs_clone2
GROUP BY 1
ORDER BY 2 DESC;
-- The United States had the most layoffs, with over 200,000.

-- Years and total layoffs 
SELECT YEAR(`date`),
SUM(total_laid_off) as "Total Laid Off"
FROM layoffs_clone2
GROUP BY 1
ORDER BY 2 DESC;

-- Total layoffs by month
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`,
SUM(total_laid_off) AS TOTAL
FROM layoffs_clone2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

-- Let's do a rolling sum of the total layoffs
WITH ROLLING_TOTAL AS(
    SELECT SUBSTRING(`date`, 1,7) AS `MONTH`,
    SUM(total_laid_off) AS TOTAL
    FROM layoffs_clone2
    WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1)
SELECT `MONTH`, 
    TOTAL,
    SUM(TOTAL) OVER(ORDER BY `MONTH`) AS ROLLING_TOTAL
FROM ROLLING_TOTAL;

-- Another way to do this is using a subquery, which gives the same result although CTEs make the SQL Code more readable and easier to understand
SELECT `MONTH`,
    TOTAL,
    SUM(TOTAL) OVER(ORDER BY `MONTH`) AS ROLLING_TOTAL
FROM (SELECT SUBSTRING(`date`, 1,7) AS `MONTH`,
    SUM(total_laid_off) AS TOTAL
    FROM layoffs_clone2
    WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1) AS ROLLING_TOTAL;

-- Things of note:
-- 1. 2020 had a high number of layoffs, probably due to COVID-19.
-- 2. 2021 was a significantly better year, with only 15,823 additional layoffs compared to 80,998 in 2020.
-- 3. 2022 also had a high number of layoffs, particularly in November just before the holidays.
-- 4. 2023 had a devastating number of layoffs.

-- Let's have a look at the companies and their layoff data per year
SELECT company,
YEAR(`date`),
SUM(total_laid_off) as "Total Laid Off"
FROM layoffs_clone2
GROUP BY 1,2
ORDER BY 3 DESC;

-- Let's rank the layoffs from highest to lowest using CTEs
WITH Layoffs_Rank AS(
    SELECT company,
    YEAR(`date`) AS years,
    SUM(total_laid_off) as total_laid_off
    FROM layoffs_clone2
    GROUP BY 1,2
    ORDER BY 3 DESC
    ) 
SELECT *, 
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Layoffs_Rank
WHERE years IS NOT NULL
ORDER BY ranking;

-- Uber had the highest layoffs in 2020, followed by Booking.com.
-- Bytedance had the highest layoffs in 2021, followed by Katerra.
-- Meta had the highest layoffs in 2022, followed by Amazon.
-- Google had the highest layoffs in 2023 up to the date in the data, followed by Microsoft.

-- Let's see the top 5 layoffs per year
WITH Layoffs_Rank AS(
    SELECT company,
    YEAR(`date`) AS years,
    SUM(total_laid_off) as total_laid_off
    FROM layoffs_clone2
    GROUP BY 1,2
    ORDER BY 3 DESC
    ), 
Company_Year_Rank AS(
    SELECT *, 
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM Layoffs_Rank
    WHERE years IS NOT NULL
    ORDER BY ranking)
SELECT * FROM 
Company_Year_Rank
WHERE ranking <= 5
ORDER BY years;
