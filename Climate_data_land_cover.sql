-- Exploratory questions
DESCRIBE land_cover_accounts;

SELECT *
FROM land_cover_accounts
ORDER BY 2 LIMIT 50;

-- Size of dataset
SELECT COUNT(*)
FROM land_cover_accounts;

-- Create a copy of the data
CREATE TABLE land_cover_accounts2
LIKE land_cover_accounts;

INSERT land_cover_accounts2
SELECT *
FROM land_cover_accounts;

-- Countries listed
SELECT DISTINCT(country)
FROM land_cover_accounts;

-- Update Namibia iso2 from null
UPDATE land_cover_accounts2
SET ISO2 = 'NA'
WHERE Country = 'Namibia';

-- Create table for countries and exclude continents and regions listed in country
CREATE TABLE country_land_cover
LIKE land_cover_accounts2;

INSERT country_land_cover
SELECT *
FROM land_cover_accounts2
WHERE ISO2 IS NOT NULL;

-- Countries listed
SELECT DISTINCT(country)
FROM country_land_cover;

-- Climate influence grouping on land cover
SELECT DISTINCT(Climate_Influence)
FROM country_land_cover;

-- Climate influences indicators on land cover
SELECT Indicator, Climate_Influence
FROM country_land_cover
GROUP BY Indicator, Climate_Influence
ORDER BY 1;

-- Each country's Climate Altering Land Cover Index
SELECT Country, Indicator, F1992, F1993, F1994, F1995, F1996, F1997, F1998, F1999, F2000, F2001, F2002, F2003, F2004,
F2005, F2006, F2007, F2008, F2009, F2010, F2011, F2012, F2013, F2014, F2015, F2016, F2017, F2018, F2019, F2020
FROM country_land_cover
WHERE Indicator = 'Climate Altering Land Cover Index'
ORDER BY 1;

-- Distribution of Country's Land Cover Area by Indicators through the years
SELECT Climate_Influence, Country,
CEIL(SUM(F1997)) as '1997', CEIL(SUM(F1998)) as '1998', CEIL(SUM(F1999)) as '1999', CEIL(SUM(F2000)) as '2000', CEIL(SUM(F2001)) as '2001',
CEIL(SUM(F2002)) as '2002', CEIL(SUM(F2003)) as '2003', CEIL(SUM(F2004)) as '2004', CEIL(SUM(F2005)) as '2005', CEIL(SUM(F2006)) as '2006', 
CEIL(SUM(F2007)) as '2007', CEIL(SUM(F2008)) as '2008', CEIL(SUM(F2009)) as '2009', CEIL(SUM(F2010)) as '2010', CEIL(SUM(F2011)) as '2011',
CEIL(SUM(F2012)) as '2012', CEIL(SUM(F2013)) as '2013', CEIL(SUM(F2014)) as '2014', CEIL(SUM(F2015)) as '2015', CEIL(SUM(F2016)) as '2016',
CEIL(SUM(F2017)) as '2017', CEIL(SUM(F2018)) as '2018', CEIL(SUM(F2019)) as '2019', CEIL(SUM(F2020)) as '2020'
FROM country_land_cover
Group By Climate_Influence, Country
order by 2;

-- Percentage change in Land cover by Artificial surface across countries from 1992 to 2020
SELECT Country, F1992, F2020,
ROUND(((F2020 - F1992)/F1992)*100, 3) AS Percentage_change
FROM country_land_cover
WHERE Indicator LIKE 'Artificial surfaces%'
ORDER BY 4 DESC;

-- Each Country's Climate Altering Land Cover Index from 1992 to 2020 
SELECT Country, F1992, F1993, F1994, F1995, F1996, F1997, F1998, F1999, F2000, F2001, F2002, F2003, F2004,
F2005, F2006, F2007, F2008, F2009, F2010, F2011, F2012, F2013, F2014, F2015, F2016, F2017, F2018, F2019, F2020
FROM country_land_cover
WHERE Indicator = 'Climate Altering Land Cover Index'
ORDER BY 1;

-- Grouping all countries by indicators through the years and finding percentage change
WITH All_Indicators As
(
SELECT Indicator, CEIL(SUM(F1992)) As Y1992, CEIL(SUM(F2000)) As Y2000, CEIL(SUM(F2010)) As Y2010,
CEIL(SUM(F2020)) As Y2020
FROM country_land_cover
GROUP BY Indicator)
SELECT *, ROUND(((Y2020 - Y1992)/Y1992)*100,3) AS Percentage_change
FROM All_Indicators;

-- Distribution of Land Cover Area by Indicators through the years
SELECT Indicator, Country, F1992, F1993, F1994, F1995, F1996, F1997, F1998, F1999, F2000, F2001, F2002, F2003, F2004,
F2005, F2006, F2007, F2008, F2009, F2010, F2011, F2012, F2013, F2014, F2015, F2016, F2017, F2018, F2019, F2020
FROM country_land_cover
ORDER BY 1, 2;

-- Countries with highest climate influence in all categories in 1992
WITH Country_climate AS
(
SELECT Country, climate_influence, SUM(F1992) As Y1992
FROM country_land_cover
GROUP BY Country, Climate_Influence),
Climate_influence_ranking As
(
SELECT *, DENSE_RANK() OVER(PARTITION BY Climate_Influence ORDER BY Y1992 DESC) As Ranking
FROM Country_climate
)
SELECT Ranking, Climate_influence, Country, Y1992
FROM Climate_influence_ranking
WHERE Ranking <= 3;

-- Percentage change in climate influence for 1992 top ranking countries
WITH Country_climate_1992 AS 
(
    SELECT Country, climate_influence, SUM(F1992) As Y1992
    FROM country_land_cover
    GROUP BY Country, Climate_influence
),
Climate_influence_ranking AS 
(
    SELECT *, DENSE_RANK() OVER(PARTITION BY Climate_influence ORDER BY Y1992 DESC) AS Ranking
    FROM Country_climate_1992
),
Top_ranking AS (
    SELECT Ranking, Climate_influence, Country, Y1992
    FROM Climate_influence_ranking
    WHERE Ranking <= 3
),
Country_climate_2020 AS (
    SELECT Country, climate_influence, SUM(F2020) AS Y2020
    FROM country_land_cover
    GROUP BY Country, Climate_influence
)
SELECT tr.Ranking, tr.Climate_influence, tr.Country, CEIL(tr.Y1992) as '1992', CEIL(cc.Y2020) as '2020',
ROUND(((cc.Y2020 - tr.Y1992)/tr.Y1992)*100, 2) AS Percentage_change
FROM Top_ranking tr
JOIN Country_climate_2020 cc
ON tr.Country = cc.Country
AND tr.Climate_influence = cc.Climate_influence
ORDER BY 2,1;


-- Create table for continents and regions
CREATE TABLE regions_land_cover
LIKE land_cover_accounts2;

-- INSERT regions_land_cover
SELECT *
FROM land_cover_accounts2
WHERE ISO2 IS NULL;

-- Cleaning region_cover table
SELECT *
FROM regions_land_cover
ORDER BY 2;

ALTER TABLE regions_land_cover 
DROP COLUMN SOURCE;

-- Percentage change in Total land cover across region due to climate influence
SELECT Country, Climate_Influence,
ROUND(((F2020 - F1992)/F1992)/100, 5) AS Percentage_change
FROM regions_land_cover
WHERE Indicator = 'Total Land Cover' 
GROUP BY Climate_Influence, Country, Percentage_change
ORDER BY 2, 3 DESC;

-- Region with the highest percentage change in 'Climate Regulating' Climate influence
SELECT Country, Climate_Influence,
ROUND(((F2020 - F1992)/F1992)*100, 3) AS Percentage_change
FROM regions_land_cover
WHERE Climate_Influence = 'Climate regulating' AND
Country != 'World'
ORDER BY 3 DESC;

-- Visualising the Climate Altering Land Cover Index
CREATE VIEW Land_cover_index As
SELECT Country, F1992, F1993, F1994, F1995, F1996, F1997, F1998, F1999, F2000, F2001, F2002, F2003, F2004,
F2005, F2006, F2007, F2008, F2009, F2010, F2011, F2012, F2013, F2014, F2015, F2016, F2017, F2018, F2019, F2020
FROM country_land_cover
WHERE Indicator = 'Climate Altering Land Cover Index'
ORDER BY 1;

-- Visualising Global Land Cover Area by Climate Influence
CREATE VIEW Land_Cover_Area As
SELECT Climate_Influence,
CEIL(SUM(F1992)) as '1992', CEIL(SUM(F1993)) as '1993', CEIL(SUM(F1994)) as '1994', CEIL(SUM(F1995)) as '1995', CEIL(SUM(F1996)) as '1996', 
CEIL(SUM(F1997)) as '1997', CEIL(SUM(F1998)) as '1998', CEIL(SUM(F1999)) as '1999', CEIL(SUM(F2000)) as '2000', CEIL(SUM(F2001)) as '2001',
CEIL(SUM(F2002)) as '2002', CEIL(SUM(F2003)) as '2003', CEIL(SUM(F2004)) as '2004', CEIL(SUM(F2005)) as '2005', CEIL(SUM(F2006)) as '2006', 
CEIL(SUM(F2007)) as '2007', CEIL(SUM(F2008)) as '2008', CEIL(SUM(F2009)) as '2009', CEIL(SUM(F2010)) as '2010', CEIL(SUM(F2011)) as '2011',
CEIL(SUM(F2012)) as '2012', CEIL(SUM(F2013)) as '2013', CEIL(SUM(F2014)) as '2014', CEIL(SUM(F2015)) as '2015', CEIL(SUM(F2016)) as '2016',
CEIL(SUM(F2017)) as '2017', CEIL(SUM(F2018)) as '2018', CEIL(SUM(F2019)) as '2019', CEIL(SUM(F2020)) as '2020'
FROM country_land_cover
Group By Climate_Influence;