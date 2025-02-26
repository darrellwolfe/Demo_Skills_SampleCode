
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


Declare @EffYearFrom varchar(8) = Cast(@Year-10 as varchar) + '-01-01'; -- Generates '20230101' for the previous year
Declare @EffYearTo varchar(8) = Cast(@Year as varchar) + '-12-31'; -- Generates '20230101' for the previous year


SELECT DISTINCT
  t.lrsn,
pmd.neighborhood AS GEO,
TRIM(pmd.NeighborHoodName) AS GEO_Name,
TRIM(pmd.pin) AS PIN,
TRIM(pmd.AIN) AS AIN,
TRIM(pmd.PropClassDescr) AS PCC_ClassCD,
CAST(LEFT(pmd.PropClassDescr,3) AS INT) AS PCC#,
TRIM(pmd.SitusAddress) AS SitusAddress,
TRIM(pmd.SitusCity) AS SitusCity,
  t.AdjustedSalePrice AS SalePrice,
  CAST(t.pxfer_date AS DATE) AS SaleDate,
  TRIM(t.SaleDesc) AS SaleDescr,
  TRIM(t.TfrType) AS TranxType,
  TRIM(t.DocNum) AS Doc# -- Multiples will have the same DocNum

FROM transfer AS t -- ON t.lrsn for joins
--CTEs
JOIN TSBv_PARCELMASTER AS pmd ON t.lrsn=pmd.lrsn
  AND pmd.EffStatus = 'A'

WHERE t.status = 'A'
--AND pmdd.AIN IN ('142762','135478','249334') -- Use to test cases only
  AND t.AdjustedSalePrice <> '0'
  --AND t.pxfer_date BETWEEN '2013-01-01' AND '2023-12-31'
  AND t.pxfer_date BETWEEN @EffYearFrom AND @EffYearTo
