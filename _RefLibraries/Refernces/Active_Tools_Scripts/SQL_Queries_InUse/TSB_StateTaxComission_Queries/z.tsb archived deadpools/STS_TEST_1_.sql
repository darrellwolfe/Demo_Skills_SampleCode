-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/


Declare @SalesFromDate DATE = '2022-10-01';
--From date requested by State Tax Commission Rep

Declare @SalesToDate DATE = '2023-12-31';
--To date requested by State Tax Commission Rep

Declare @LastCertifiedStart INT = '20230101';
--01/01 of most recent Assessed Values

Declare @LastCertifiedEnd INT = '20231231';
--12/31 of most recent Assessed Values

Declare @MemoLastUpdatedNoEarlierThan DATE = '2022-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022


WITH 
CTE_Assessed AS (
  SELECT DISTINCT
    lrsn,
    --Assessed Values
    v.land_assess AS AssessedValue_Land_wEx,
    v.imp_assess AS AssessedValue_Imp,
    (v.imp_assess + v.land_assess) AS AssessedValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNum
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @LastCertifiedStart AND @LastCertifiedEnd
--Change to desired year
    AND v.status = 'A'
)

--CTE_MultiSale_Assessed AS (
Select 
t.lrsn
,assd.AssessedValue_Total
--,SUM(assd.AssessedValue_Total) AS MultiSale_Assessed
,t.DocNumber

From TSBv_Transfers AS t

Join CTE_Assessed AS assd
  On t.lrsn = assd.lrsn
  And RowNum = 1

Where t.AdjSalesPrice > 1
And t.SaleDate BETWEEN @SalesFromDate AND @SalesToDate

And t.lrsn = 22030



----VARIABLE DATE
--Group By t.lrsn, t.DocNumber

--),
