
Declare @Year int = 2024; -- Input THIS year here
--DECLARE @TaxYear INT;
--SET @TaxYear = YEAR(GETDATE());

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here


Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2024-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

Declare @PrimaryTransferDateFROM date = CAST(CAST(@Year-1 as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateTO date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @PrimaryTransferDateFROM DATE = '2024-01-01';
--Declare @PrimaryTransferDateTO DATE = '2024-12-31';
--pxfer_date
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20240101';
--Declare @CertValueDateTO INT = '20241231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231


Declare @LandModelId varchar(6) = '70' + Cast(@Year as varchar); -- Generates '702023' for the previous year
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    --AND lh.LandModelId= @LandModelId
    --AND ld.LandModelId= @LandModelId 

-------------------------------------
-- CTEs will drive this report and combine in the main query
-------------------------------------
WITH

-------------------------------------
--CTE_CertValues
-------------------------------------
CTE_CertValues AS (
SELECT 
v.lrsn,
--Certified Values
v.land_market_val AS [Cert_Land],
v.imp_val AS [Cert_Imp],
(v.imp_val + v.land_market_val) AS [Cert_Total],
--v.eff_year AS [Tax_Year],
CAST(CONVERT(varchar, v.eff_year) AS DATE) AS AssessedYear,
ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
FROM valuation AS v
WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO
--Change to desired year
AND v.status = 'A'
)  

Select *
From CTE_CertValues
Where Cert_Total IS NOT NULL















/*


-------------------------------------
-- CTE_MultiSaleSums
-------------------------------------
-- Common Table Expression (CTE) to calculate the sums for Multi-Sale cases
CTE_MultiSaleSums AS (
  SELECT
    ctet.DocNumber,
    SUM(cv23.[Cert_Land]) AS [MultiSale_Land],
    SUM(cv23.[Cert_Imp]) AS [MultiSale_Imp],
    SUM(cv23.Cert_Total) AS [MultiSale_TotalSums],
    SUM(pm.WorkValue_Impv) AS [MultiSale_WorksheetImp]
    
  FROM CTE_TransferSales AS ctet -- ON t.lrsn for joins
  JOIN CTE_CertValues AS cv23 ON ctet.lrsn=cv23.lrsn
  JOIN CTE_ParcelMasterData AS pm ON ctet.lrsn=pm.lrsn

  WHERE
    ctet.TranxType = 'M' -- Filter only Multi-Sale cases
  GROUP BY
    ctet.DocNumber
),
*/