DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

-- DECLARE @Year INT = 2024; -- Input year

-- Use CONCAT to create date strings for the start and end of the year
DECLARE @LastYearCertFrom VARCHAR(8) = CAST(CONCAT(@Year - 1, '0101') AS VARCHAR(8));
DECLARE @LastYearCertTo VARCHAR(8) = CAST(CONCAT(@Year - 1, '1231') AS VARCHAR(8));

-- Date and time for January 1 of the input year
DECLARE @ThisYearCertFrom VARCHAR(8) = CAST(CONCAT(@Year, '0101') AS VARCHAR(8));
DECLARE @ThisYearCertTo VARCHAR(8) = CAST(CONCAT(@Year, '1231') AS VARCHAR(8));

-- Use CONCAT for creating range values for MPPV
DECLARE @ThisYearMPPVFrom VARCHAR(9) = CAST(CONCAT(@Year, '00000') AS VARCHAR(9));
DECLARE @ThisYearMPPVTo VARCHAR(9) = CAST(CONCAT(@Year, '99999') AS VARCHAR(9));

-- Declare cadaster year as the input year
DECLARE @CadasterYear INT = @Year;

DECLARE @NoteYear VARCHAR(10) = CAST(CONCAT('%',@Year,'%') AS VARCHAR(10));

--Pulling in Aumentum Notes
CTE_Note_Status AS (
SELECT
ROW_NUMBER() OVER (PARTITION BY n.objectId ORDER BY n.createTimestamp DESC) AS RowNum,
n.createTimestamp,
--n.createdByUserId,
CONCAT(TRIM(up.FirstName), ' ', TRIM(up.LastName)) AS UserName,
--up.FirstName,
--up.LastName,
--n.effStatus
n.objectId, --lrsn or RevObjId
n.noteText,
n.taxYear
FROM Note AS n
JOIN UserProfile AS up
  ON up.Id = n.createdByUserId
JOIN CTE_ParcelMaster AS pmd
  ON pmd.lrsn = n.objectId

WHERE n.effStatus = 'A'
AND noteText LIKE '%DONE%'
AND YEAR(createTimestamp) = @Year
--noteText LIKE @NoteYear
),

--Pulling in Aumentum Notes
CTE_Note_DecProcessing AS (
Select
  n.objectId
  ,STRING_AGG(n.noteText, ', ') AS noteText

From Note AS n
JOIN CTE_ParcelMaster AS pmd
  ON pmd.lrsn = n.objectId

WHERE n.effStatus = 'A'
AND noteText NOT LIKE '%DONE%'
AND YEAR(createTimestamp) = @Year
--noteText LIKE @NoteYear
Group By n.objectId
),
