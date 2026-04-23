CREATE DATABASE SDG_Analytics_DB;
GO
USE SDG_Analytics_DB;
GO

EXEC sp_help 'RAW_Goal4'

-- If you ran this command before, run this first to clean up:
IF OBJECT_ID('Staging_SDG_Data') IS NOT NULL
    DROP TABLE Staging_SDG_Data;
GO


-----------------------------------------------------------
-- STEP 1: CREATE THE UNIFIED STAGING TABLE
-----------------------------------------------------------
CREATE TABLE Staging_SDG_Data (
    FactID BIGINT PRIMARY KEY IDENTITY(1,1),
    Goal INT NOT NULL,
    Indicator NVARCHAR(50) NOT NULL,
    SeriesCode NVARCHAR(50) NOT NULL,
    SeriesDescription NVARCHAR(500),
    CountryCode NVARCHAR(3) NOT NULL,
    CountryName NVARCHAR(100) NOT NULL,
    DataYear INT NOT NULL,
    IndicatorValue FLOAT,
    Sex NVARCHAR(10),
    Education_Level NVARCHAR(50), -- Used Education_level
    Skill_Type NVARCHAR(50),      -- Used Type_of_skill
    Age_Group NVARCHAR(50),       -- Used Age
    Observation_Status NVARCHAR(10), -- Used Observation_Status
    Data_Source NVARCHAR(255)
);
GO

-----------------------------------------------------------
-- STEP 2: LOAD AND CLEAN GOAL 4 DATA (EDUCATION)
-- *** Using confirmed column names: Education_level, Type_of_skill ***
-----------------------------------------------------------
USE SDG_Analytics_DB;
GO

-----------------------------------------------------------
-- RECREATE/ALTER STAGING TABLE WITH SAFE LENGTHS
-----------------------------------------------------------
IF OBJECT_ID('dbo.Staging_SDG_Data', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_SDG_Data;
GO

CREATE TABLE Staging_SDG_Data (
    FactID BIGINT PRIMARY KEY IDENTITY(1,1),

    Goal INT NOT NULL,
    Indicator NVARCHAR(100) NOT NULL,           -- increased length to handle long indicator names
    SeriesCode NVARCHAR(100) NOT NULL,
    SeriesDescription NVARCHAR(MAX),            -- MAX to handle very long descriptions
    CountryCode NVARCHAR(3) NOT NULL,
    CountryName NVARCHAR(100) NOT NULL,
    DataYear INT NOT NULL,
    IndicatorValue FLOAT,
    Sex NVARCHAR(20),                            -- increased length for future-proofing
    Education_Level NVARCHAR(100),
    Skill_Type NVARCHAR(100),
    Age_Group NVARCHAR(50),
    Observation_Status NVARCHAR(50),
    Data_Source NVARCHAR(MAX)                    -- changed to MAX to prevent truncation
);
GO

INSERT INTO Staging_SDG_Data (
    Goal, Indicator, SeriesCode, SeriesDescription, CountryCode, CountryName, DataYear, IndicatorValue,
    Sex, Education_Level, Skill_Type, Age_Group, Observation_Status, Data_Source
)
SELECT
    CAST(Goal AS INT),
    CAST(Indicator AS NVARCHAR(100)),  -- match updated staging table
    SeriesCode,
    SeriesDescription,                  -- NVARCHAR(MAX) now, safe for long text
    CAST(GeoAreaCode AS NVARCHAR(3)),
    GeoAreaName,
    CAST(TimePeriod AS INT),
    CAST(Value AS FLOAT),
    Sex,
    Education_level,
    Type_of_skill,
    NULL,       -- Age_Group not applicable for Goal 4
    NULL,       -- Observation_Status not applicable for Goal 4
    Source
FROM
    RAW_Goal4
WHERE
    Nature = 'C'  -- Country-level data only
    AND Value IS NOT NULL;
GO

SELECT TOP 10 *
FROM Staging_SDG_Data
WHERE Goal = 4;

SELECT Goal, COUNT(*) AS Rows_Per_Goal
FROM Staging_SDG_Data
GROUP BY Goal;


-----------------------------------------------------------
-- STEP 3: LOAD AND CLEAN GOAL 8 DATA (NEET)
-- *** Using assumed column names: Observation_Status, Age ***
-----------------------------------------------------------
INSERT INTO Staging_SDG_Data (
    Goal, Indicator, SeriesCode, SeriesDescription, CountryCode, CountryName, DataYear, IndicatorValue,
    Sex, Education_Level, Skill_Type, Age_Group, Observation_Status, Data_Source
)
SELECT
    CAST(Goal AS INT),
    CAST(Indicator AS NVARCHAR(100)),   -- match staging table
    SeriesCode,
    SeriesDescription,
    CAST(GeoAreaCode AS NVARCHAR(3)),
    GeoAreaName,
    CAST(TimePeriod AS INT),
    CAST(Value AS FLOAT),
    CASE 
        WHEN Sex = 'BOTHSEX' THEN 'Total'
        WHEN Sex = 'FEMALE' THEN 'Female'
        WHEN Sex = 'MALE' THEN 'Male'
        ELSE 'Unknown'
    END,
    NULL,                               -- Education_Level not applicable for Goal 8
    NULL,                               -- Skill_Type not applicable for Goal 8
    Age,                                -- Age column from RAW_Goal8
    Observation_Status,                 -- A = Normal, U = Low reliability
    Source
FROM
    RAW_Goal8
WHERE
    Nature = 'C'                        -- Country-level data only
    AND Value IS NOT NULL;
GO


SELECT TOP 10 *
FROM RAW_Goal8;


-----------------------------------------------------------
-- STEP 4: FINAL CLEANING
-----------------------------------------------------------

-- 1️⃣ Standardize Sex values
UPDATE Staging_SDG_Data
SET Sex = CASE
    WHEN Sex = 'BOTHSEX' THEN 'Total'
    WHEN Sex = 'FEMALE' THEN 'Female'
    WHEN Sex = 'MALE' THEN 'Male'
    ELSE 'Unknown'
END;

-- 2️⃣ Remove rows with low reliability
DELETE FROM Staging_SDG_Data
WHERE Observation_Status = 'U';

-- 3️⃣ Optional: Standardize Age_Group codes (if needed)
-- Example mapping (uncomment and edit if you want to convert codes to ranges)
UPDATE Staging_SDG_Data
SET Age_Group = CASE
    WHEN Age_Group = 'N' THEN '15-24'
    WHEN Age_Group = 'A' THEN '25-34'
    WHEN Age_Group = 'G' THEN '35-44'
    ELSE Age_Group
END;

-- 4️⃣ Verify final counts
SELECT Goal, COUNT(*) AS Rows_Per_Goal
FROM Staging_SDG_Data
GROUP BY Goal;

-- Optional: preview first 10 rows
SELECT TOP 10 *
FROM Staging_SDG_Data;
GO


-- Dim_Country
CREATE TABLE Dim_Country (
    CountryKey INT PRIMARY KEY IDENTITY(1,1),
    CountryCode NVARCHAR(3) NOT NULL UNIQUE,
    CountryName NVARCHAR(100) NOT NULL
);
INSERT INTO Dim_Country (CountryCode, CountryName)
SELECT DISTINCT CountryCode, CountryName FROM Staging_SDG_Data;
GO

-- Dim_Time
CREATE TABLE Dim_Time (
    TimeKey INT PRIMARY KEY, 
    DataYear INT NOT NULL,
    Is_Baseline_Year BIT DEFAULT 0
);
INSERT INTO Dim_Time (TimeKey, DataYear, Is_Baseline_Year)
SELECT DISTINCT DataYear, DataYear, 
    CASE WHEN DataYear = 2015 THEN 1 ELSE 0 END
FROM Staging_SDG_Data;
GO

-- Dim_Indicator
CREATE TABLE Dim_Indicator (
    IndicatorKey INT PRIMARY KEY IDENTITY(1,1),
    Goal INT NOT NULL,
    SeriesCode NVARCHAR(50) NOT NULL UNIQUE,
    IndicatorName NVARCHAR(500) NOT NULL
);
INSERT INTO Dim_Indicator (Goal, SeriesCode, IndicatorName)
SELECT DISTINCT Goal, SeriesCode, SeriesDescription
FROM Staging_SDG_Data;
GO


CREATE TABLE Fact_SDG_Data (
    FactID BIGINT PRIMARY KEY,
    CountryKey INT FOREIGN KEY REFERENCES Dim_Country(CountryKey),
    IndicatorKey INT FOREIGN KEY REFERENCES Dim_Indicator(IndicatorKey),
    TimeKey INT FOREIGN KEY REFERENCES Dim_Time(TimeKey),
    Sex NVARCHAR(10),
    Education_Level NVARCHAR(50),
    Skill_Type NVARCHAR(50),
    Age_Group NVARCHAR(50),
    IndicatorValue FLOAT NOT NULL
);

INSERT INTO Fact_SDG_Data (FactID, CountryKey, IndicatorKey, TimeKey, Sex, Education_Level, Skill_Type, Age_Group, IndicatorValue)
SELECT
    s.FactID,
    dc.CountryKey,
    di.IndicatorKey,
    dt.TimeKey,
    s.Sex,
    s.Education_Level,
    s.Skill_Type,
    s.Age_Group,
    s.IndicatorValue
FROM Staging_SDG_Data s
JOIN Dim_Country dc ON s.CountryCode = dc.CountryCode
JOIN Dim_Indicator di ON s.SeriesCode = di.SeriesCode
JOIN Dim_Time dt ON s.DataYear = dt.DataYear;
GO

DROP TABLE Staging_SDG_Data;
GO

-- Verification
SELECT 'Fact Table Rows' AS TableName, COUNT(*) AS CountValue FROM Fact_SDG_Data
UNION ALL
SELECT 'Dim Country Rows', COUNT(*) AS CountValue FROM Dim_Country
UNION ALL
SELECT 'Dim Indicator Rows', COUNT(*) AS CountValue FROM Dim_Indicator
UNION ALL
SELECT 'Dim Time Rows', COUNT(*) AS CountValue FROM Dim_Time;
GO


-- Remove rows where IndicatorValue is NULL
DELETE FROM Fact_SDG_Data
WHERE IndicatorValue IS NULL;

-- Update UnitOfMeasure based on SeriesCode / Goal
UPDATE Dim_Indicator
SET UnitOfMeasure = CASE
    WHEN SeriesCode LIKE '4%' THEN 'Percent'
    WHEN SeriesCode LIKE '8%' THEN 'Percent'
    ELSE 'Unknown'
END;




