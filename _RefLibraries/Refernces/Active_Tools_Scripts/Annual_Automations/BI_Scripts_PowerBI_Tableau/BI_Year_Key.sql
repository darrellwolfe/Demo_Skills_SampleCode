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

Declare @PXFerYearFrom varchar(8) = Cast(@Year-10 as varchar) + '-12-31'; -- Generates '20230101' for the previous year


SELECT DISTINCT
  YEAR(t.pxfer_date) AS Year_Key,
  FORMAT(CONVERT(DATETIME, CONCAT(YEAR(t.pxfer_date), '-01-01')), 'MM/dd/yyyy') AS Year_Date
FROM transfer AS t
WHERE t.AdjustedSalePrice IS NOT NULL
  AND t.AdjustedSalePrice > 0
--  AND t.pxfer_date > '2012-12-31'
  AND t.pxfer_date > @PXFerYearFrom
