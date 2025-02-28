
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
--Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev10 int = @Year - 10; -- Input the year here


Declare @EffYearFrom varchar(8) = Cast(@Year-10 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYearTo varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year


    SELECT 
      lrsn,
      --Assessed_Values
      v.land_assess AS [Assessed_Land],
      v.imp_assess AS [Assessed_Imp],
      (v.imp_assess + v.land_assess) AS [Assessed_Total_Value],
      LEFT(CONVERT(VARCHAR, v.eff_year), 4) AS [Assessed_Tax_Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
--    WHERE v.eff_year BETWEEN 20130101 AND 20231231
    WHERE v.eff_year BETWEEN @EffYearFrom AND @EffYearTo

--Change to desired year
      AND v.status = 'A'