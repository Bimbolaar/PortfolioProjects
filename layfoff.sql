-- Exploratory Data Analysis

-- The dataset
SELECT *
FROM layoffs_staging2
LIMIT 20;

-- The size of your dataset
SELECT COUNT(*)
FROM layoffs_staging2;

-- Layoff Start and end date
SELECT MIN(`date`) As Start_date, MAX(`date`) As End_date
FROM layoffs_staging2;

-- The industries listed
SELECT DISTINCT industry
FROM layoffs_staging2;

-- The company stages listed
SELECT stage, COUNT(total_laid_off) As number_of_layoff
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- The distribution of layoffs by stage
SELECT stage, SUM(total_laid_off) Total_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY Total_off DESC;

-- Number of people laid off in different stage and years
SELECT stage, YEAR(`date`) 'Year', SUM(total_laid_off) As Total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`), stage
ORDER BY 3 DESC;

-- Company's total number of people laid off
SELECT company, SUM(total_laid_off) Total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Details of layoff in Nigeria
SELECT *
FROM layoffs_staging2
WHERE country = 'Nigeria'
ORDER BY total_laid_off DESC;

-- Companies with a total (100%) Layoff of employees
SELECT company, country, industry, `date`, percentage_laid_off, total_laid_off, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Ranking of num of people laid off by company
WITH Country_Layoff (Country, `Year`, Total_Laid_Off) As
(
SELECT country, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country, YEAR(`date`)
), Country_Layoff_Ranking As
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY Total_Laid_Off DESC) As Ranking
FROM Country_Layoff
WHERE `Year` IS NOT NULL
)
SELECT *
FROM Country_Layoff_Ranking;

-- Companies with the highest total number of layoffs
SELECT Company, Industry, SUM(total_laid_off) As Company_layoffs
FROM layoffs_staging2
GROUP BY Company, industry
ORDER BY Company_layoffs DESC LIMIT 5;

-- Average percentage of layoffs across all the companies
SELECT ROUND(AVG(percentage_laid_off),3) AS Avg_percentage
FROM layoffs_staging2;

WITH Company_Percentage_Layoff As
(
SELECT company, AVG(percentage_laid_off) As Avg_percentage_laid_off
FROM Layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY Company
)
SELECT ROUND(AVG(Avg_percentage_laid_off),3) As Company_Avg_percentage_laid_off
FROM Company_Percentage_Layoff;

-- Number of companies with layoffs
SELECT COUNT(DISTINCT COMPANY)
FROM layoffs_staging2;

-- Companies and Industry they belong to
SELECT DISTINCT company, industry
FROM layoffs_staging2 
Order by 1 ASC ;

-- Total funds raised (in millions) and the total number of layoffs per company
SELECT Company, SUM(funds_raised_millions) As funds_raised_in_millions, SUM(total_laid_off) As Total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY funds_raised_in_millions DESC;

--  Layoff trends from 2020 to 2023
-- Yearly layoff trend
SELECT EXTRACT(YEAR FROM `date`) AS `Year`, COUNT(total_laid_off) AS Number_of_layoffs, 
SUM(total_laid_off) As Total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `Year`
ORDER BY `Year`;

-- Year in which the highest number of layoffs occured
SELECT  YEAR(`date`) `Year`, COUNT(total_laid_off) As num_layoff, SUM(total_laid_off) As Total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `Year`
ORDER BY 2 DESC LIMIT 1;

-- Month that had the highest number of people laid off
WITH Monthly_Layoff As 
(
SELECT SUBSTRING(`date`, 1, 7) As `Month`, SUM(total_laid_off) As Total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `Month` 
ORDER BY 1
)
SELECT `Month`, Total_laid_off
FROM Monthly_Layoff
WHERE Total_laid_off = (SELECT MAX(Total_laid_off) FROM Monthly_Layoff) ;

-- Trend of layoffs by Months
SELECT EXTRACT(MONTH FROM `date`) AS `Month`, COUNT(total_laid_off) AS number_of_layoffs,
SUM(total_laid_off) Total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `Month`
ORDER BY 1;

-- Yearly trend of layoffs in Consumer and Healthcare industry
SELECT industry, year(`date`) As `Year`, COUNT(total_laid_off) As Number_of_layoff, SUM(total_laid_off) As Total_laid_off
FROM layoffs_staging2
WHERE industry IN ('Consumer', 'Healthcare')
GROUP BY 1, 2
ORDER BY 2;

-- Companies that laid off more than 100 employees
SELECT Company, SUM(total_laid_off) As TotalLaidOff
FROM layoffs_staging2
GROUP BY Company
HAVING TotalLaidOff > 100
ORDER BY 2;

-- Ranking layoffs by Years in company
WITH Company_Year (Company, Years, Total_laid_off) As
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year(`date`)
),
Company_Year_Rank As
(
SELECT *, DENSE_RANK() OVER (PARTITION BY Years ORDER BY Total_laid_off DESC) As Ranking
FROM Company_Year
WHERE Years IS NOT NULL
)
SElECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- Company Layoffs that occurred in 2023?
SELECT company, count(total_laid_off) As num_layoffs, sum(total_laid_off) As Total_laid_off
FROM layoffs_staging2
WHERE YEAR(`date`) = 2023
GROUP BY company
ORDER BY 3 DESC;

-- Rolling total of Monthly Layoffs
WITH Rolling_Layoff_Total As 
(
SELECT SUBSTRING(`date`, 1, 7) As `Month`, SUM(total_laid_off) As Total_LaidOff
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY Month
ORDER BY 1 ASC
)
SELECT `Month`, Total_LaidOff, SUM(total_Laidoff) OVER (ORDER BY `Month`) As rolling_total_LaidOff
FROM Rolling_Layoff_Total;

-- Total layoffs in 2023
SELECT COUNT(total_laid_off) As num_layoffs , SUM(total_laid_off) As Total_laid_off
FROM layoffs_staging2
WHERE YEAR(`date`) = 2023;

-- Average number of employees laid off by industry
SELECT industry, AVG(total_laid_off) As Average_laid_off
FROM layoffs_staging2
GROUP BY industry;

-- The total number of employees laid off from 2020 to 2023
SELECT SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2;

-- Where the percentage of employees laid off is greater than 10%
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off > 0.1;

-- The percentage of layoffs in each industry compared to the total number of layoffs
SELECT industry, SUM(total_laid_off) AS Total_Laid_Off,
(SUM(total_laid_off) / (SELECT SUM(total_laid_off) FROM layoffs_staging) * 100) AS Percentage_Laid_Off
FROM layoffs_staging2
GROUP BY industry
HAVING industry IS NOT NULL
ORDER BY 3 DESC;

-- The top 3 countries with the highest average number of layoffs
SELECT Country, AVG(total_laid_off) As Average_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC LIMIT 3; 

-- The company with the highest number of layoffs in each industry
WITH Industry_layoff (Industry, Company, Total_layoff) As
    (
    SELECT industry, company, max(total_laid_off)
    FROM layoffs_staging2
    GROUP BY Industry, Company
    ),
     Industry_layoff_ranking (Industry, Company, Total_layoff, Ranking) As
    (SELECT *, DENSE_RANK() OVER(PARTITION BY INDUSTRY ORDER BY Total_layoff DESC)
	FROM Industry_layoff
	WHERE industry IS NOT NULL
    )
    SELECT Industry, Company, Total_layoff
    FROM Industry_layoff_ranking
    WHERE Ranking = 1;
