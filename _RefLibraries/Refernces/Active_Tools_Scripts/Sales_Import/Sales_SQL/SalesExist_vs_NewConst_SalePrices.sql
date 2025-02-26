-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

*/

Declare @Year INT = 2023;

Declare @YearFrom DATE = Cast(@Year -10 as varchar) + '-01-01'; -- Generates '20230101' for the previous year
Declare @YearTo DATE = Cast(@Year as varchar) + '-12-31'; -- Generates '20230101' for the previous year
--Ten Year View 
--AND t.pxfer_date BETWEEN '2013-01-01' AND '2023-12-31'
--AND t.pxfer_date BETWEEN @YearFrom AND @YearTo

WITH

CTE_Sales AS (
SELECT
t.lrsn
,t.AdjustedSalePrice AS SalePrice
,CAST(t.pxfer_date AS DATE) AS SaleDate
,LEFT(CAST(t.pxfer_date AS DATE),4) AS Year
,TRIM(t.SaleDesc) AS SaleDescr
,TRIM(t.TfrType) AS TranxType
,TRIM(t.DocNum) AS DocNum -- Multiples will have the same DocNum

FROM transfer AS t -- ON t.lrsn for joins

WHERE t.status = 'A'
--AND pmd.AIN IN ('142762','135478','249334') -- Use to test cases only
AND t.AdjustedSalePrice <> '0'
--AND t.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'
AND t.pxfer_date BETWEEN @YearFrom AND @YearTo
),

CTE_ImpYearBuilt AS (
Select Distinct
--Extensions Table
e.lrsn
,MAX(i.year_built) AS MaxYearBuilt
--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
WHERE e.status = 'A'
GROUP BY e.lrsn
),

CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
Select Distinct
CASE
  WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 6003 THEN 'District_6'
  WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 6001 THEN 'District_6'
  WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 5003 THEN 'District_5'
  WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 5001 THEN 'District_5'
  WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 4000 THEN 'District_4'
  WHEN pm.neighborhood >= 3000 THEN 'District_3'
  WHEN pm.neighborhood >= 2000 THEN 'District_2'
  WHEN pm.neighborhood >= 1021 THEN 'District_1'
  WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 1001 THEN 'District_1'
  WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 451 THEN 'Commercial'
  WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
  WHEN pm.neighborhood >= 1 THEN 'Commercial'
  WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
  ELSE NULL
END AS District

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description

,CASE 
  WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
  WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
  WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
  WHEN pm.ClassCD = '667' THEN 'Operating_Property'
  WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
  WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
  ELSE 'Unasigned_or_OldInactiveParcel'
END AS Property_Class_Type


From TSBv_PARCELMASTER AS pm
),

CTE_SalesData AS (
Select Distinct
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,sale.SalePrice
,sale.SaleDate
,sale.Year
,sale.SaleDescr
,sale.TranxType
,sale.DocNum
,iyb.MaxYearBuilt
,CASE
    WHEN iyb.MaxYearBuilt = 0 THEN 'Vacant'
    WHEN iyb.MaxYearBuilt IS NULL THEN 'Vacant'
    WHEN sale.Year < iyb.MaxYearBuilt THEN 'Vacant'
    WHEN sale.Year > iyb.MaxYearBuilt THEN 'Existing'
    WHEN sale.Year = iyb.MaxYearBuilt THEN 'NewConstruction'
    ELSE 'Review'
  END AS 'SaleType'
From CTE_Sales AS sale

Left Join CTE_ImpYearBuilt AS iyb
  On sale.lrsn = iyb.lrsn
  
Left Join CTE_ParcelMaster AS pmd
  On pmd.lrsn = sale.lrsn
)

Select 
District
,GEO
,GEO_Name
,SUM(SalePrice) AS SumSalePrice
,SaleType
,Year
From CTE_SalesData
Group By 
District
,GEO
,GEO_Name
,SaleType
,Year















/*








SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Property_Class_Type
,pmd.TAG


,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip

,pmd.Owner
,pmd.AttentionLine
,pmd.MailingAddress
,pmd.AddlAddrLine
,pmd.MailingCityStZip
,pmd.MailingCity
,pmd.MailingState
,pmd.MailingZip
,pmd.CountyNumber
,pmd.County_Name

,pmd.LegalAcres
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 


FROM CTE_ParcelMaster AS pmd
--  ON xxxx.lrsn = pmd.lrsn


--Order By District,GEO;
*/