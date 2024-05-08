-- Data Cleaning Report: World Layoffs Data 

-- Objective: Prepare the World Layoff Data 2021 for exploratory data analysis (EDA) by addressing duplicates, inconsistencies, null values, and unnecessary columns.

-- Step 1. Duplicate Removal
-- Step 2. Standardize the data
-- Step 3. Handling Null values or blank values
-- Step 4. Remove unnecesary columns if needed

-- Creating a duplicate of the raw data to work with in case we make mistakes, ensuring the raw data remains intact. 
CREATE TABLE layoffs_clone AS
	(SELECT * FROM layoffs);

-- View the new table
SELECT * FROM layoffs_clone;

-- Removing duplicates: Since we lack a unique identifier, we'll utilize the row_number() function to generate one.
SELECT *, 
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, Percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_clone;

-- Now we will use the row number to identify duplicates. If a row has a row_number greater than 1, it indicates a duplicate. We'll accomplish this using Common Table Expressions (CTEs).    
WITH CTE_layoffs AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, Percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_clone
)
SELECT * 
FROM CTE_layoffs 
WHERE row_num > 1;    


-- In MySQL, direct deletion from Common Table Expressions (CTEs) isn't supported. Therefore, we'll create a new table with an added row number column for this purpose.
CREATE TABLE layoffs_clone2 AS(
	  SELECT *, 
          ROW_NUMBER () OVER(
	            PARTITION BY company, location, industry, total_laid_off, Percentage_laid_off, `date`, stage, country, funds_raised_millions
          ) AS row_num
	  FROM layoffs_clone);

-- View new Table
SELECT * 
FROM layoffs_clone2
WHERE row_num > 1;

-- Delete duplicates
DELETE 
FROM layoffs_clone2
WHERE row_num > 1;

-- Step 2: Standardization
-- With duplicates removed, the next step is data standardization, aimed at identifying and rectifying discrepancies.
-- An initial error noticed is irregular spacing in the company names, which is addressed using the TRIM() function.

-- Selecting and trimming whitespace from the company names
SELECT company, TRIM(company)
FROM layoffs_clone2;

-- Updating the table to apply the trimmed company names
UPDATE layoffs_clone2
SET company = TRIM(company);

-- Checking for distinct industry names
SELECT DISTINCT(industry)
FROM layoffs_clone2 
ORDER BY 1;

-- We observe variations in industry names, such as "Crypto" and "Cryptocurrency". We will standardize these entries for consistency.
UPDATE layoffs_clone2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Check location
SELECT DISTINCT(location)
FROM layoffs_clone2;
-- The location data appears to be in good shape.

-- Check country
SELECT DISTINCT(country)
FROM layoffs_clone2
ORDER BY 1;
-- There's a period at the end of a country name.

-- Remove the trailing period from country names that contain "United States".
UPDATE layoffs_clone2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- The date column is currently stored as TEXT datatype, which needs to be converted to the appropriate date datatype.
-- Convert the 'date' column from string format to date format using the STR_TO_DATE function
UPDATE layoffs_clone2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Now that the date is in the correct format, we can proceed to alter the datatype of the 'date' column
ALTER TABLE layoffs_clone2
MODIFY COLUMN `date` DATE;

-- Viewing the data again, the errors seem to have been corrected so next step would be handling null and blank values
-- Step 3: Null Values Handling

-- Industry Column 
SELECT * 
FROM layoffs_clone2
WHERE industry IS NULL
OR industry = '';

-- Here, we're identifying companies with blank or null values in the industry column (a), but have corresponding non-null values in the same company's record (b). 
-- This allows us to update the null or blank values in the industry column with the non-null values.
SELECT a.company, a.location, a.industry, b.industry
FROM layoffs_clone2 a
JOIN layoffs_clone2 b
ON a.company = b.company
WHERE (a.industry IS NULL OR a.industry = '')
AND b.industry IS NOT NULL;

-- 3 companies have blank values for industry but we can trace the industry from other columns with the same company and same location
-- first we need to change the blanks to null so our subsequentupdate can function correctly
-- Update blank values in the 'Industry' column to NULL
UPDATE layoffs_clone2
SET industry = NULL
WHERE industry = '';

-- Now we can update
UPDATE layoffs_clone2 a
JOIN layoffs_clone2 b
	ON a.company = b.company 
  SET a.industry = b.industry
WHERE a.industry IS NULL 
AND b.industry IS NOT NULL;

-- As the next step, we will remove unnecessary columns that do not contribute to our analysis.
-- Step 4: Column Deletion
-- Identify and delete columns with no relevant data.
SELECT *
FROM layoffS_clone2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Doesnt look like there were any layoffs for those columns so we would delete the columns
DELETE
FROM layoffS_clone2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Now the data looks clean and ready to work on and we can drop the row column created at the start
ALTER TABLE layoffs_clone2
DROP COLUMN row_num;

-- View Data
SELECT *
FROM layoffS_clone2;


