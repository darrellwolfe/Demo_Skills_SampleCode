-- !preview conn=conn

--BI_Sales_10_Year

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
  AND t.pxfer_date BETWEEN '2013-01-01' AND '2023-12-31'