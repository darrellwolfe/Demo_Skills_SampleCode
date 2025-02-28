-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/



Declare @PrimaryTransferDateFROM DATE = '2023-01-01';
Declare @PrimaryTransferDateTO DATE = '2023-12-31';
--pxfer_date
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM INT = '20230101';
Declare @CertValueDateTO INT = '20231231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231


WITH


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
  WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
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
END AS Property_Class_Category

,TRIM(pm.TAG) AS TAG

,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip


,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.AttentionLine) AS AttentionLine
,TRIM(pm.MailingAddress) AS MailingAddress
,TRIM(pm.AddlAddrLine) AS AddlAddrLine
,TRIM(pm.MailingCityStZip) AS MailingCityStZip
,TRIM(pm.MailingCity) AS MailingCity
,TRIM(pm.MailingState) AS MailingState
,TRIM(pm.MailingZip) AS MailingZip
,TRIM(pm.CountyNumber) AS CountyNumber

,CASE
  WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
  ELSE NULL
END AS County_Name

,pm.LegalAcres
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

  -------------------------------------
--CTE_TransferSales
-------------------------------------
CTE_TransferSales AS (
SELECT DISTINCT
--  pmd.[GEO_Name],
  t.lrsn,
  t.status,
--Transfer Table Sale Details
  t.AdjustedSalePrice AS SalePrice,
  CAST(t.pxfer_date AS DATE) AS SaleDate,
  TRIM(t.SaleDesc) AS SaleDescr,
  TRIM(t.TfrType) AS TranxType,
  TRIM(t.DocNum) AS DocNumber -- Multiples will have the same DocNum
FROM transfer AS t -- ON t.lrsn for joins
WHERE t.status = 'A'
  AND t.AdjustedSalePrice <> '0'
  AND t.pxfer_date BETWEEN @PrimaryTransferDateFROM AND @PrimaryTransferDateTO
  --AND t.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'
),

CTE_Market AS (
  SELECT 
    lrsn,
    --Certified Values
    v.land_market_val AS Market_Land_PreEx,
    v.imp_val AS Market_Imp,
    (v.imp_val + v.land_market_val) AS Market_Total,
    v.eff_year AS Tax_Year_Market,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO
--Change to desired year
    AND v.status = 'A'
),

CTE_Assessed AS (
  SELECT 
    lrsn,
    --Assessed Values
    v.land_assess AS AssessedValue_Land_wEx,
    v.imp_assess AS AssessedValue_Imp,
    (v.imp_assess + v.land_assess) AS AssessedValue_Total,
    v.eff_year AS Tax_Year_Assessed,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO
--Change to desired year
    AND v.status = 'A'
)




SELECT DISTINCT
--Regional Categorioes
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Property_Class_Category
,pmd.TAG

--Situs
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip
--Owner Mailing
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

--Other Property Data
,pmd.LegalAcres
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 

--Transfer Table Sale Details
,tr.SalePrice
,tr.SaleDate
,tr.SaleDescr
,tr.TranxType
,tr.DocNumber -- Multiples will have the same DocNum


,market.Market_Land_PreEx
,market.Market_Imp
,market.Market_Total
,market.Tax_Year_Market
--Certified Market Values
,cv.CertValue_Land_PreEx
,cv.CertValue_Imp
,cv.CertValue_Total
,cv.Tax_Year_Cert
--Assessed Values after exemptions like Timber/Ag
,asd.AssessedValue_Land_wEx
,asd.AssessedValue_Imp
,asd.AssessedValue_Total
,asd.Tax_Year_Assessed


FROM CTE_ParcelMaster AS pmd
--  ON xxxx.lrsn = pmd.lrsn
JOIN CTE_TransferSales AS tr -- ON tr.lrsn for joins
  ON tr.lrsn = pmd.lrsn


LEFT JOIN CTE_Market AS market
  ON market.lrsn = tr.lrsn
  AND market.RowNumber = '1'

LEFT JOIN CTE_Assessed AS asd
  ON tr.lrsn=asd.lrsn
  AND asd.RowNumber = '1'




Order By District,GEO;

