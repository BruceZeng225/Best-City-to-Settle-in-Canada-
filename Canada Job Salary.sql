-- data source: https://www.kaggle.com/datasets/moun12345/canadian-salary-data-from-stack-overflow-survey
SELECT *
FROM canada_job_data;

SELECT DISTINCT City
FROM canada_job_data
ORDER BY 1;

SET SQL_SAFE_UPDATES = 0;

-- rename column
ALTER TABLE canada_job_data
CHANGE COLUMN `Company_Name` `Company_Size` text;

ALTER TABLE canada_job_data
CHANGE COLUMN `Salary_(USD)` `Salary_USD` int;

SELECT DISTINCT Company_Size, REPLACE(Company_Size, ',', '') AS test
FROM canada_job_data
ORDER BY Company_Size ASC;

-- remove comma from large numbers
UPDATE canada_job_data
SET Company_Size = REPLACE(Company_Size, ',', '');

-- clean up city names
UPDATE canada_job_data
SET City = 'Regina'
WHERE City = 'Reginaâ€“Moose Mountain';

UPDATE canada_job_data
SET City = 'Saskatoon'
WHERE City = 'Saskatoonâ€“Biggar';

UPDATE canada_job_data
SET City = 'Vancouver'
WHERE City = 'Vancouver Island and Coast';

UPDATE canada_job_data
SET City = 'Windsor'
WHERE City LIKE '%Windsor%';

-- average salary by industry and experience
SELECT Year, City, Industry, Experience, ROUND(avg(Salary_USD), 2) AS avg_salary
FROM canada_job_data
GROUP BY Industry, Experience, City, Year
ORDER BY avg_salary DESC;
