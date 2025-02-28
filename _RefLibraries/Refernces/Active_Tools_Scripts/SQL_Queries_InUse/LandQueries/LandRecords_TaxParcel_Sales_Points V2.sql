-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 6, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year


Declare @PrimaryTransferDateFROM DATE = Cast(@Year-3 as varchar) + '-01-01'; -- Generates '20230101' for the previous year
Declare @PrimaryTransferDateTO DATE = Cast(@Year as varchar) + '-12-31'; -- Generates '20230101' for the previous year
--Declare @PrimaryTransferDateFROM DATE = '2020-01-01';
--Declare @PrimaryTransferDateTO DATE = '2023-12-31';
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM INT = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO INT = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20230101';
--Declare @CertValueDateTO INT = '20231231';
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

CTE_Cert AS (
  SELECT 
    lrsn,
    --Certified Values
    v.land_market_val AS CertValue_Land_PreEx,
    v.imp_val AS CertValue_Imp,
    (v.imp_val + v.land_market_val) AS CertValue_Total,
    v.eff_year AS Cert_Date,
    v.last_update AS cert_last_update,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO
--Change to desired year
    AND v.status = 'A'
),

CTE_WorksheetMarketValues AS(
SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_inc AS Worksheet_Land,
    (r.income_value - r.land_mkt_val_cost) AS Worksheet_Imp,
    r.income_value AS Worksheet_Total,
    r.last_update AS wksht_last_update

FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status = 'W'
AND r.method = 'I' 
--AND r.land_model = @LandModelId

UNION ALL

SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_cost AS Worksheet_Land,
    r.cost_value AS Worksheet_Imp,
    (r.cost_value + r.land_mkt_val_cost) AS Worksheet_Total,
    r.last_update AS wksht_last_update

FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status='W'
AND r.method = 'C' 
--AND r.land_model = @LandModelId

--ORDER BY GEO, PIN;
)

  




SELECT DISTINCT
--Regional Categorioes

--,pmd.GEO_Name
pmd.lrsn -- (RevObjId)
--Situs
,pmd.SitusAddress
--,pmd.SitusCity
--,pmd.SitusState
--,pmd.SitusZip
,tr.SaleDescr AS Source
,pmd.PIN
,pmd.AIN
,tr.SaleDate
--,tr.SalePrice
,CAST(tr.SalePrice AS nvarchar(12)) AS SalePrice
,pmd.ClassCD AS PropClass
--,pmd.Property_Class_Description
,pmd.GEO AS neighborhood
,pmd.LegalAcres AS Acres
,CAST(cv.CertValue_Land_PreEx AS nvarchar(12)) AS Cert_Land_Val
,CAST(cv.CertValue_Imp AS nvarchar(12)) AS Cert_Imp_Val
,CAST(wmv.Worksheet_Land AS nvarchar(12)) AS Wksht_Land_Val
,CAST(wmv.Worksheet_Imp AS nvarchar(12)) AS Wksht_Imp_Val
,wmv.wksht_last_update

,tr.TranxType AS tftrtype
,tr.SaleDate AS pxferdate

,cv.Cert_Date
,cv.cert_last_update

,tr.DocNumber AS docnum -- Multiples will have the same DocNum
,pmd.District AS ApprDist



FROM CTE_ParcelMaster AS pmd
--  ON xxxx.lrsn = pmd.lrsn
JOIN CTE_TransferSales AS tr -- ON tr.lrsn for joins
  ON tr.lrsn = pmd.lrsn

LEFT JOIN CTE_Cert AS cv
  ON tr.lrsn=cv.lrsn
  AND cv.RowNumber = '1'

LEFT JOIN CTE_WorksheetMarketValues AS wmv
  ON tr.lrsn=wmv.lrsn



Order By District,GEO;

