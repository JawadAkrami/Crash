-- =========================================================
-- Portfolio Project: Motor Vehicle Collisions Data Cleaning
-- Description: Cleans and standardizes raw NYC crash data
-- Assumptions:
--   • Script assumes a raw, unmodified dataset
--   • Intended to be run once (non-idempotent)
-- =========================================================




-- ===============================================================================================================================
-- 														Introduction 
-- ===============================================================================================================================

-- Dataset: It contains information from all police reported motor vehicle collisions in NYC.
-- Data collected from 2012 to 2025. Data from Year 2015 is missing.
-- Rows: 1048575 
-- Columns: 29

SELECT
  table_name AS mvc_crash,
  ROUND(data_length / table_rows, 2) AS avg_row_bytes
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name = 'mvc_crash';

-- Memorey usage: 274 MB




-- ===========================================================================================================================
-- 											1 Profile the Data (Understand the Mess First)
-- ===========================================================================================================================


SELECT 
	COUNT(*) 
FROM mvc_crash;
-- Result: 1048575 rows

SELECT COUNT(*) 
FROM mvc_crash 
WHERE BOROUGH = '' 
	OR BOROUGH IS NULL;
-- Result: 367866 rows

-- Check for duplicate records using COLLISION_ID
SELECT COLLISION_ID, COUNT(COLLISION_ID)
FROM mvc_crash
GROUP BY COLLISION_ID
HAVING COUNT(*) > 1;
-- Result: No duplicate COLLISION_ID values found

 -- Range validation for numeric injury and fatality columns
SELECT 
	MIN(`NUMBER OF PERSONS INJURED`) AS min_injured, 
	MAX(`NUMBER OF PERSONS INJURED`) AS max_injured,
    MIN(`NUMBER OF PERSONS KILLED`) AS min_killed, 
	MAX(`NUMBER OF PERSONS KILLED`) AS max_killed,
    MIN(`NUMBER OF PEDESTRIANS INJURED`) AS min_pedestrain_injured, 
	MAX(`NUMBER OF PEDESTRIANS INJURED`) AS max_pedestraian_injured,
    MIN(`NUMBER OF PEDESTRIANS KILLED`) AS min_pedestrain_killed, 
	MAX(`NUMBER OF PEDESTRIANS KILLED`) AS max_pedestraian_killed,
	MIN(`NUMBER OF CYCLIST INJURED`) AS min_cyclist_injured, 
	MAX(`NUMBER OF CYCLIST INJURED`) AS max_cyclist_injured,
    MIN(`NUMBER OF CYCLIST KILLED`) AS min_cyclist_killed, 
	MAX(`NUMBER OF CYCLIST KILLED`) AS max_cyclist_killed,
    MIN(`NUMBER OF MOTORIST INJURED`) AS min_motorist_injured, 
	MAX(`NUMBER OF MOTORIST INJURED`) AS max_motorist_injured,
    MIN(`NUMBER OF MOTORIST KILLED`) AS min_motorist_killed, 
	MAX(`NUMBER OF MOTORIST KILLED`) AS max_motorist_killed        
FROM mvc_crash; 
-- Result: All values fall within expected non-negative ranges


-- Outlier detection
SELECT 
	`NUMBER OF PERSONS INJURED`, 
    COUNT(*) AS freq
FROM 
	mvc_crash
GROUP BY 
	`NUMBER OF PERSONS INJURED` 
ORDER BY 
	`NUMBER OF PERSONS INJURED` DESC;


SELECT 
	`NUMBER OF MOTORIST INJURED`, 
    COUNT(*) AS freq
FROM 
	mvc_crash
GROUP BY 
	`NUMBER OF MOTORIST INJURED`
ORDER BY 
	`NUMBER OF MOTORIST INJURED` DESC;

-- Extreme injury counts were retained, as they represent valid
-- high-severity crash events rather than data quality issues.

-- Date Validation: Crash Date
SELECT
	MIN(`crash date`) AS min_date,
    MAX(`crash date`) AS max_date
FROM
	mvc_crash;
    
SELECT 
	COUNT(*) 
FROM 
	mvc_crash
WHERE 
	`crash date` IS NULL;
-- Crash dates fall within the expected range (2018-01-01 to 2023-09-09)
-- No NULL values were detected in the crash date column

-- Check for future-dated records
SELECT COUNT(*)
FROM mvc_crash
WHERE `crash date` > CURDATE();
-- No future-dated records detected


-- ===========================================================================================================================
-- 													2 Standardize Data Types
-- ===========================================================================================================================

-- Converting Date and Time data type

UPDATE mvc_crash 
SET `crash date` = STR_TO_DATE(`crash date`, '%m/%d/%Y'); 

ALTER TABLE mvc_crash MODIFY `crash date` DATE;


UPDATE mvc_crash 
SET `crash time` = STR_TO_DATE(`crash time`, '%H:%i:%s')
WHERE `crash time` IS NOT NULL;

ALTER TABLE mvc_crash MODIFY `crash time` TIME;

-- CRASH DATE and CRASH TIME, stored as text.
-- were converted to proper DATE and TIME types to support validation and analysis.


-- ===========================================================================================================================
-- 													3 Handle Missing Data
-- ===========================================================================================================================

-- BOROUGH column
SELECT borough, COUNT(*)
FROM mvc_crash
GROUP BY borough
HAVING COUNT(*) >1;
-- BOROUGH column retained despite missing values due to analytical importance.

-- PERSONS INJURED and PERSONS KILLED columns
SELECT
  SUM(`NUMBER OF PERSONS INJURED` IS NULL) AS injured_nulls,
  SUM(`NUMBER OF PERSONS KILLED` IS NULL) AS killed_nulls
FROM mvc_crash;
-- Both columns have missing values. We keep them since they contain fewer than 35 rows.

-- column ON STREET NAME has over 265000 null values
SELECT COUNT(*)
FROM mvc_crash
WHERE `ON STREET NAME` IS NULL
   OR TRIM(`ON STREET NAME`) = '';
-- This column is kept because our analysis focused on street-level and borough-level trends.
-- It is retained as the primary location identifier to preserve analytical value.

-- Columns: OFF STREET NAME AND CROSS STREET NAME have over 544000 and 783000 null values respectively
SELECT COUNT(*)
FROM mvc_crash
WHERE `CROSS STREET NAME` IS NULL
OR TRIM(`CROSS STREET NAME`) = '';

SELECT COUNT(*)
FROM mvc_crash
WHERE `OFF STREET NAME` IS NULL
OR TRIM(`OFF STREET NAME`) = '';

-- Dropping column with high null values. 
ALTER TABLE mvc_crash
DROP COLUMN `OFF STREET NAME`,
DROP COLUMN `CROSS STREET NAME`,
DROP COLUMN LOCATION,
DROP COLUMN `CONTRIBUTING FACTOR VEHICLE 3`,
DROP COLUMN `CONTRIBUTING FACTOR VEHICLE 4`,
DROP COLUMN `CONTRIBUTING FACTOR VEHICLE 5`,
DROP COLUMN `VEHICLE TYPE CODE 3`,
DROP COLUMN `VEHICLE TYPE CODE 4`,
DROP COLUMN `VEHICLE TYPE CODE 5`;
-- Both CROSS/OFF STREET NAME columns were removed due to high sparsity and being outside our analysis scope.
-- Location column is the combination of LONGITUDE and LATITUDE columns
-- The rest of columns were removed due to containing over 96% null values. Thus, they provide limited analytical value.



-- ===========================================================================================================================
-- 													4 Deduplicate Records
-- ===========================================================================================================================

-- Detecting Duplicates
SELECT 
	COUNT(*) AS count_rows, 
    COUNT(DISTINCT collision_id) AS distinct_rows
FROM mvc_crash;
-- The number of total rows equals the number of distinct IDs. Therefore, there are 0 duplicates. 


-- ===========================================================================================================================
-- 												5 Normalize & Standardize Values
-- ===========================================================================================================================

UPDATE mvc_crash
SET borough = CONCAT(
  UPPER(LEFT(LOWER(borough), 1)),
  SUBSTRING(LOWER(borough), 2)
);

UPDATE mvc_crash
SET `ON STREET NAME` = LOWER(`ON STREET NAME`);
-- Case normalization was applied for consistency, while keeping original naming semantics.

-- Converting column names to snake_case format
ALTER TABLE mvc_crash
RENAME COLUMN COLLISION_ID TO collision_id,
RENAME COLUMN `crash date` TO crash_date,
RENAME COLUMN `crash time` TO crash_time,
RENAME COLUMN BOROUGH TO borough,
RENAME COLUMN `ZIP CODE` TO zip_code,
RENAME COLUMN LONGITUDE TO longitude,
RENAME COLUMN LATITUDE TO latitude,
RENAME COLUMN `ON STREET NAME` TO on_street_name,
RENAME COLUMN `NUMBER OF PERSONS INJURED` TO number_of_persons_injured,
RENAME COLUMN `NUMBER OF PERSONS KILLED` TO number_of_persons_killed,
RENAME COLUMN `NUMBER OF PEDESTRIANS INJURED` TO number_of_pedestrians_injured,
RENAME COLUMN `NUMBER OF PEDESTRIANS KILLED` TO number_of_pedestrians_killed,
RENAME COLUMN `NUMBER OF CYCLIST INJURED` TO number_of_cyclist_injured,
RENAME COLUMN `NUMBER OF CYCLIST KILLED` TO number_of_cyclist_killed,
RENAME COLUMN `NUMBER OF MOTORIST INJURED` TO number_of_motorist_injured,
RENAME COLUMN `NUMBER OF MOTORIST KILLED` TO number_of_motorist_killed,
RENAME COLUMN `CONTRIBUTING FACTOR VEHICLE 1` TO contributing_factor_vehicle_1,
RENAME COLUMN `CONTRIBUTING FACTOR VEHICLE 2` TO contributing_factor_vehicle_2,
RENAME COLUMN `VEHICLE TYPE CODE 1` TO vehicle_type_code_1,
RENAME COLUMN `VEHICLE TYPE CODE 2` TO vehicle_type_code_2;
-- Column names were standardized using lowercase snake_case to improve consistency, readability, and query reliability. 

-- Populating whitespace rows with NULL values
UPDATE mvc_crash
SET vehicle_type_code_1 = NULL
WHERE vehicle_type_code_1 IS NOT NULL 
	AND TRIM(vehicle_type_code_1) = '';

UPDATE mvc_crash
SET vehicle_type_code_2 = NULL
WHERE vehicle_type_code_2 IS NOT NULL 
	AND TRIM(vehicle_type_code_2) = '';

UPDATE mvc_crash
SET on_street_name = NULL
WHERE on_street_name IS NOT NULL
	AND TRIM(on_street_name) = '';

UPDATE mvc_crash
SET zip_code = NULL
WHERE zip_code IS NOT NULL
	AND TRIM(zip_code) = '';
    
UPDATE mvc_crash
SET borough = NULL
WHERE borough IS NOT NULL
	AND TRIM(borough) = '';

UPDATE mvc_crash
SET contributing_factor_vehicle_2 = NULL
WHERE contributing_factor_vehicle_2 IS NOT NULL
	AND TRIM(contributing_factor_vehicle_2) = '';
    
-- Empty strings and whitespace values were converted to NULL to standardize missing data representation 
-- and ensure accurate aggregation, filtering, and joins during analysis

ALTER TABLE mvc_crash MODIFY COLUMN collision_id int FIRST;
-- Move collision_id to first position

-- =========================================================================================================================== 
-- 											7 Data Integrity Constraints 						   
-- =========================================================================================================================== 

-- Primary key
ALTER TABLE mvc_crash ADD PRIMARY KEY (collision_id);
-- It enforces row-level uniqueness and improve data integrity.

-- Add CHECK constraint
ALTER TABLE mvc_crash
ADD CONSTRAINT chk_persons_injured_non_negative
CHECK (number_of_persons_injured >= 0);
-- CHECK constraints are applied only where supported by MySQL.
-- Date-based constraints using CURRENT_DATE cannot be enforced because MySQL does not support it.



-- ===========================================================================================================================
-- 														Conclusion
-- ===========================================================================================================================
-- After systematically cleaning the dataset, the following modifications occurred across rows, columns, and memory usage.

-- 		 		Before    After
-- Rows: 		1048575	  1048575 
		
-- 				Before 	  After
-- Columns:  	29		  20	
		
-- 				Before	  After
-- Memory Usage:274		  256 MB




-- ============================================================================================================================
-- 														Reference
-- ============================================================================================================================
-- Data.gov
-- Link: https://catalog.data.gov/dataset/motor-vehicle-collisions-crashes







