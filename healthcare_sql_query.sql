-- Exploratory Data Analysis
-- Please note that before importing the dataset into SQLQuery, 
-- I encountered issues with importing the full data since SQLQuery requires the YYYY-MM-DD format. 
-- I used Microsoft Excel Power Query to convert the date from text to date and adjust the format accordingly.

SELECT TOP (1000) [ID]
      ,[Name]
      ,[Age]
      ,[Gender]
      ,[City]
      ,[Blood Type]
      ,[Education]
      ,[Employment Status]
      ,[Salary]
      ,[Health Condition]
      ,[Credit Score]
      ,[Date of Admission]
  FROM [PortfolioProject].[dbo].['dirty_healthcare-data$']

SELECT * 
  FROM [PortfolioProject].[dbo].['dirty_healthcare-data$'] AS DHD

-- I checked the row count in my data to ensure it matches the number of rows in the CSV file.

 SELECT COUNT(*) 
 AS total_rows
 FROM PortfolioProject..['dirty_healthcare-data$']

-- I checked the data to identify how many NULL values were present.

SELECT Gender,
	COUNT(*) AS missing_count 
	FROM dbo.['dirty_healthcare-data$']
	WHERE Gender IS NULL
	GROUP BY Gender

SELECT 
    ID, 
    COUNT(*) AS NullCount 
FROM dbo.['dirty_healthcare-data$']
WHERE ID IS NULL
GROUP BY ID

-- I investigated the data for duplicates based on the ID and Health Condition columns.

SELECT
	ID, 
	COUNT(*)
FROM dbo.['dirty_healthcare-data$']
GROUP BY ID
HAVING COUNT(*) > 1

SELECT 
    ID, 
    [Health Condition], 
    COUNT(*) AS DuplicateCount
FROM dbo.['dirty_healthcare-data$']
GROUP BY ID, [Health Condition]
HAVING COUNT(*) > 1

SELECT 
	COUNT(DISTINCT ID) AS UniquePatients, 
    COUNT(*) AS TotalRecords
FROM dbo.['dirty_healthcare-data$']

-- I utilized the Min, Max, and AVG functions to analyze the patients' age range.

SELECT 
    MIN(Age) AS MinAge, 
    MAX(Age) AS MaxAge, 
    AVG(Age) AS AvgAge,
    COUNT(*) AS TotalPatients
FROM dbo.['dirty_healthcare-data$']

-- I used the SELECT TOP 1 command to identify the dominant gender and prevalent health conditions.

SELECT TOP 1 Gender, 
	COUNT(*) AS Count
FROM dbo.['dirty_healthcare-data$']
GROUP BY Gender
ORDER BY COUNT(*) DESC;

SELECT TOP 1 [Health Condition], 
	COUNT(*) AS Count
FROM dbo.['dirty_healthcare-data$']
GROUP BY [Health Condition]
ORDER BY COUNT(*) DESC;

SELECT ID, Salary, [Credit Score]
FROM dbo.['dirty_healthcare-data$']

-- I explored numeric columns for outliers using different queries to ensure the accuracy of further analysis.

SELECT ID, Salary
FROM dbo.['dirty_healthcare-data$']
WHERE Salary > (SELECT AVG(Salary) + 3 * STDEV(Salary) FROM dbo.['dirty_healthcare-data$'])
   OR Salary < (SELECT AVG(Salary) - 3 * STDEV(Salary) FROM dbo.['dirty_healthcare-data$'])

SELECT ID, [Credit Score]
FROM dbo.['dirty_healthcare-data$']
WHERE [Credit Score] > (SELECT AVG([Credit Score]) + 3 * STDEV(Salary) FROM dbo.['dirty_healthcare-data$'])
   OR [Credit Score] < (SELECT AVG([Credit Score]) - 3 * STDEV(Salary) FROM dbo.['dirty_healthcare-data$'])

 WITH STATS AS (
    SELECT 
        AVG(Salary) AS MeanSalary,
        STDEV(Salary) AS StdDevSalary
    FROM dbo.['dirty_healthcare-data$']
),
Outliers AS (
    SELECT 
        ID, 
        Salary,
        (Salary - Stats.MeanSalary) / Stats.StdDevSalary AS Score
    FROM dbo.['dirty_healthcare-data$'], Stats
)
SELECT *
FROM Outliers
WHERE ABS(Score) > 3; 

-- I noticed NULL values in the Age column and conducted further analysis to understand them.

SELECT TOP 5 Age
FROM dbo.['dirty_healthcare-data$']
ORDER BY Age DESC;

SELECT TOP 200 Age
FROM dbo.['dirty_healthcare-data$']
ORDER BY Age ASC;

-- I categorized patients into age ranges to facilitate a more structured analysis of trends and patterns across different age groups.

SELECT 
    CASE 
        WHEN Age < 18 THEN 'Children'
        WHEN Age BETWEEN 18 AND 65 THEN 'Adults'
        ELSE 'Seniors'
    END AS AgeGroup, 
    COUNT(*) AS PatientCount
FROM dbo.['dirty_healthcare-data$']
GROUP BY 
    CASE 
        WHEN Age < 18 THEN 'Children'
        WHEN Age BETWEEN 18 AND 65 THEN 'Adults'
        ELSE 'Seniors'
    END;

-- Analyzed the different blood types to identify the most prevalent one among the patients.

SELECT 
    [Blood Type], 
    COUNT(*) AS BloodTypeCount
FROM dbo.['dirty_healthcare-data$']
GROUP BY [Blood Type]

-- Data Cleaning

--I replaced all occurrences of 'M' and 'F' in the Gender column with 'Male' and 'Female' to improve clarity and standardize the data.

UPDATE dbo.['dirty_healthcare-data$']
SET Gender = 'Male'
WHERE Gender = 'M'

UPDATE dbo.['dirty_healthcare-data$']
SET Gender = 'Female'
WHERE Gender = 'F'

-- I corrected the case formatting in the Name and City column to ensure proper presentation.

UPDATE dbo.['dirty_healthcare-data$']
SET Name = CONCAT(
UPPER(LEFT(Name, 1)), 
LOWER(SUBSTRING(Name, 2, CHARINDEX(' ', Name) - 1)), 
' ',
UPPER(LEFT(SUBSTRING(Name, CHARINDEX(' ', Name) + 1, LEN(Name)), 1)), 
LOWER(SUBSTRING(Name, CHARINDEX(' ', Name) + 2, LEN(Name))) 
)
WHERE CHARINDEX(' ', Name) > 0; 

UPDATE dbo.['dirty_healthcare-data$']
SET City = CONCAT(
UPPER(LEFT(City, 1)),
LOWER(SUBSTRING(City, 2, LEN(City) - 1))
);

-- By utilizing the ID and Health Condition columns, I identified and removed duplicates to ensure data accuracy.

WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ID, [Health Condition] ORDER BY ID) AS RowNumber
    FROM dbo.['dirty_healthcare-data$']
)
DELETE FROM CTE
WHERE RowNumber > 1

-- The Gender column contained over 1000 NULL values. I deleted it to prevent inaccurate analysis based on gender.

ALTER TABLE dbo.['dirty_healthcare-data$']
DROP COLUMN Gender

SELECT *
FROM dbo.['dirty_healthcare-data$']

-- Fixed a typographical error of "(?!)" in the Health Condition column.

SELECT TOP 6 [Health Condition], 
	COUNT(*) AS Count
FROM dbo.['dirty_healthcare-data$']
GROUP BY [Health Condition]
ORDER BY COUNT(*) DESC;

UPDATE dbo.['dirty_healthcare-data$']
SET [Health Condition] = 'Excellent'
WHERE [Health Condition]= 'Excellent (?!)';

SELECT TOP 6 [Health Condition], 
	COUNT(*) AS Count
FROM dbo.['dirty_healthcare-data$']
GROUP BY [Health Condition]
ORDER BY COUNT(*) DESC;

-- I replaced NULL values in the Salary column with the average salary to ensure data completeness and enable more accurate analysis.

SELECT AVG(Salary) AS AverageSalary
FROM dbo.['dirty_healthcare-data$'];

SELECT COUNT(*),
       COUNT(CASE WHEN Salary IS NULL THEN 1 END) AS Null_Count
FROM dbo.['dirty_healthcare-data$']

UPDATE dbo.['dirty_healthcare-data$']
SET Salary = 31182.122
WHERE Salary IS NULL;

-- I replaced NULL values in the Credit Score column with the average credit score.

SELECT AVG([Credit Score]) AS AverageCreditScrore
FROM dbo.['dirty_healthcare-data$'];

UPDATE dbo.['dirty_healthcare-data$']
SET [Credit Score] = 680
WHERE [Credit Score] IS NULL;

 SELECT *
FROM dbo.['dirty_healthcare-data$']

-- I replaced the NULL values in the age column with the average age to avoid skewing the analysis 
-- and ensure that missing values do not impact statistical summaries.

SELECT AVG(Age) AS AverageCreditScrore
FROM dbo.['dirty_healthcare-data$'];

UPDATE dbo.['dirty_healthcare-data$']
SET Age = 32
WHERE Age IS NULL;

-- I analyzed the relationship between age and employment status to better predict the education level of patients,
-- aiming to make informed imputations for missing data.

 SELECT *
FROM dbo.['dirty_healthcare-data$']

SELECT Age, [Employment Status], Education
FROM dbo.['dirty_healthcare-data$']


SELECT 
    *,
    CASE
        WHEN Age BETWEEN 1 AND 18 AND [Employment Status] = 'Student' THEN 'High School'
        WHEN Age > 18 AND [Employment Status] IN ('Self-employed (part-time)', 'Student (Internship)', 'Student', 'Student (Full-time)', 'Unemployed') THEN 'Bachelor'
        WHEN Age > 50 AND [Employment Status] IN ('Retired', 'Self-employed', 'Student (part-time)', 'Student (Internship)', 'Student (Full-time)', 'Gig Worker', 'Employed (Part-time)') THEN 'Masters'
        WHEN Age > 80 AND [Employment Status] IN ('Retired', 'Self-employed', 'Gig Worker', 'Employed (Part-time)') THEN 'Masters'
        ELSE 'Unknown'
    END AS Proposed_Education
FROM dbo.['dirty_healthcare-data$']
WHERE Education IS NULL;

-- I used the correlation between Age and Employment Status to predict and handle NULL values in the Education column.

UPDATE dbo.['dirty_healthcare-data$']
SET Education = CASE
    WHEN Age BETWEEN 1 AND 18 AND [Employment Status] = 'Student' THEN 'High School'
    WHEN Age > 18 AND [Employment Status] IN ('Self-employed (part-time)', 'Student (Internship)', 'Student', 'Student (Full-time)', 'Unemployed') THEN 'Bachelor'
    WHEN Age > 50 AND [Employment Status] IN ('Retired', 'Self-employed', 'Student (part-time)', 'Student (Internship)', 'Student (Full-time)', 'Gig Worker', 'Employed (Part-time)') THEN 'Masters'
    WHEN Age > 80 AND [Employment Status] IN ('Retired', 'Self-employed', 'Gig Worker', 'Employed (Part-time)') THEN 'Masters'
    ELSE 'Unknown'
END
WHERE Education IS NULL;

-- I handled NULL values in the Health Condition column by replacing them with "Unknown" to ensure data consistency.

UPDATE dbo.['dirty_healthcare-data$']
SET [Health Condition] = 'Unknown'
WHERE [Health Condition] IS NULL;

SELECT COUNT(*) AS Null_Count
FROM dbo.['dirty_healthcare-data$']
WHERE [Health Condition] IS NULL;

 SELECT *
FROM dbo.['dirty_healthcare-data$']

-- I handled NULL values in the Blood Type column by replacing them with "Unknown"

SELECT COUNT(*) AS Null_Count
FROM dbo.['dirty_healthcare-data$']
WHERE [Blood Type] IS NULL;

SELECT TOP 3 [Blood Type], 
	COUNT(*) AS Count
FROM dbo.['dirty_healthcare-data$']
GROUP BY [Blood Type]
ORDER BY COUNT(*) DESC;

UPDATE dbo.['dirty_healthcare-data$']
SET [Blood Type] = 'Unknown'
WHERE [Blood Type] IS NULL;

SELECT 
	COUNT(*) AS Null_Count
FROM dbo.['dirty_healthcare-data$']
WHERE [Blood Type] IS NULL


 SELECT *
FROM dbo.['dirty_healthcare-data$']

-- To analyze the relationship between city and health condition.

SELECT City, [Health Condition], 
	COUNT(*) AS Condition_Count
FROM [PortfolioProject].[dbo].[Clean_Data$]
GROUP BY City, [Health Condition]
ORDER BY Condition_Count DESC;

-- To analyze the relationship between city and health condition.

SELECT Age, [Health Condition], 
	COUNT(*) AS Age_Count
FROM [PortfolioProject].[dbo].[Clean_Data$]
GROUP BY Age, [Health Condition]
ORDER BY Age_Count DESC;

-- To analyze the relationship between City, Date of Admission, and health condition.

SELECT City, YEAR([Date of Admission]) AS Admission_Year, 
MONTH([Date of Admission]) AS Admission_Month, 
COUNT(*) AS Admission_Count
FROM [PortfolioProject].[dbo].[Clean_Data$]
GROUP BY City, YEAR([Date of Admission]), MONTH([Date of Admission])
ORDER BY Admission_Count DESC;

SELECT 
    City, 
    [Health Condition], 
    COUNT(*) AS Admission_Count, 
    AVG(Age) AS Average_Age, 
    MIN([Date of Admission]) AS First_Admission_Date, 
    MAX([Date of Admission]) AS Last_Admission_Date
FROM [PortfolioProject].[dbo].[Clean_Data$]
GROUP BY 
    City, 
    [Health Condition]
ORDER BY Admission_Count DESC;

-- To fix the typographical error of 'Albuque' and change it to Albuquerque.

UPDATE [PortfolioProject].[dbo].[Clean_Data$]
SET City = 'Albuquerque'
WHERE City = 'Albuque';

SELECT * 
FROM [dbo].[Clean_Data$]