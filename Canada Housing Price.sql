-- Data Source: https://www.kaggle.com/datasets/jeremylarcher/canadian-house-prices-for-top-cities
-- 1. Data import
-- 2. Data cleaning
-- 3. Calculate the average home price per bed and bath in each city along with family income

-- enable table updates
SET SQL_SAFE_UPDATES = 0;

-- import data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test.csv'
INTO TABLE canada_houselistings_top45cities
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- import data error, check for designated file folder
SHOW VARIABLES LIKE "secure_file_priv";

-- import data error, check local import option
SHOW VARIABLES LIKE 'local_infile';

-- enable local data import
SET GLOBAL local_infile=1;

-- import data error, checking for MySQL permission on the file
SELECT LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test.csv');

-- import data error due to character type, switching data type to encompass the character
ALTER TABLE canada_houselistings_top45cities
MODIFY COLUMN Address VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

/* switching data type did not fix the error, so instead the problematic characters
are indentified and replace in excel, furthermore problematic commas are removed in excel */

-- checking if the data is correctly imported
SELECT *
FROM canada_houselistings_top45cities;

-- standardize address column
UPDATE canada_houselistings_top45cities
SET Address = trim(LEADING '#' FROM Address);

-- remove duplicate city with different names
SELECT DISTINCT City
FROM canada_houselistings_top45cities
ORDER BY 1;

UPDATE canada_houselistings_top45cities
SET City = 'St. John''s' 
WHERE City = 'Saint John';

-- move city in the right province

UPDATE canada_houselistings_top45cities
SET Province = 'Saskatchewan'
WHERE City LIKE '%Regina%';

UPDATE canada_houselistings_top45cities
SET Province = 'Saskatchewan'
WHERE City LIKE '%Saskatoon%';

UPDATE canada_houselistings_top45cities
SET Province = 'Manitoba'
WHERE City LIKE '%Winnipeg%';

-- average price of home in each city by number of beds and baths
SELECT City, Number_Beds, Number_Baths,
	ROUND(avg(Price), 2) AS average_price
FROM canada_houselistings_top45cities
WHERE Number_Beds > 0
GROUP BY City, Number_Beds, Number_Baths
ORDER BY average_price DESC;

-- average price of home in each city per bed and bath
-- CTE that calculates price per bed and bath
WITH price_per_unit AS (
	SELECT City, Address, Number_Beds, Number_Baths, Price,
	(Price / (Number_Beds + Number_Baths)) AS price_per_bed_and_bath
	FROM canada_houselistings_top45cities
    -- omits home that contains no beds
	WHERE Number_Beds > 0
),
-- CTE that calculates that average price per bed and bath in each city
average_home_cost AS (
	SELECT City, Number_Beds, Number_Baths, COUNT(*) AS Num_Homes, ROUND(avg(Price), 2) AS Average_Price,
	ROUND(avg(price_per_bed_and_bath), 2) AS Average_Price_Per_Unit
	FROM price_per_unit
	GROUP BY City, Number_Beds, Number_Baths
)
-- includes family income of each city
SELECT a.City, c.Province, a.Number_Beds, a.Number_Baths, a.Num_Homes, a.Average_Price_Per_Unit, c.Median_Family_Income
FROM average_home_cost AS a
INNER JOIN (SELECT DISTINCT City, Province,
			Median_Family_Income
			FROM canada_houselistings_top45cities) AS c
ON a.City = c.City
-- omits unique homes
WHERE Num_Homes > 1
-- filter out city that we do not have salary data
AND a.City IN (SELECT DISTINCT City
				FROM canada_job_data)
ORDER BY average_price_per_unit DESC;
