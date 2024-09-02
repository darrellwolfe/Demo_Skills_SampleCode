-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/



DECLARE @TaxYear INT = 2024; 
-- Current Tax Year -- Change this to the current tax year
DECLARE @MemoID VARCHAR(4); -- Specify an appropriate length

-----------------
-- By changing these years, you will have effectively changed all effective years
-----------------

--WHERE m.memo_id='RY24'
SET @MemoID = CAST('RY' + RIGHT(CAST(@TaxYear AS VARCHAR(4)), 2) AS VARCHAR(4));

DECLARE @PrevTaxYear INT = @TaxYear - 1;
-- Now, derive other variables from @TaxYear
DECLARE @PrimaryTransferDateFROM DATE = CAST(CAST(@TaxYear AS VARCHAR) + '-01-01' AS DATE);
DECLARE @PrimaryTransferDateTO DATE = CAST(CAST(@TaxYear AS VARCHAR) + '-12-31' AS DATE);

DECLARE @CertValueDateFROM INT = CAST(CAST(@TaxYear AS VARCHAR) + '0101' AS INT);
DECLARE @CertValueDateTO INT = CAST(CAST(@TaxYear AS VARCHAR) + '1231' AS INT);

DECLARE @PrevCertValueDateFROM INT = CAST(CAST(@PrevTaxYear AS VARCHAR) + '0101' AS INT);
DECLARE @PrevCertValueDateTO INT = CAST(CAST(@PrevTaxYear AS VARCHAR) + '1231' AS INT);

-- Assuming you want to construct @LandModelId based on the year too, here's a potential way to do it:
-- Example assumes the prefix '70' is constant and the year is appended to it.
DECLARE @LandModelIdPrefix VARCHAR(2) = '70'; -- This is just an example. Adjust as needed.
DECLARE @LandModelId INT = CAST(@LandModelIdPrefix + CAST(@TaxYear AS VARCHAR) AS INT);

/*

EXAMPLES without CAST:
--DECLARE @LandModelIDYear INT = 2023; 
-- Current Land Model ID Year -- Change this to the desired year
Declare @PrimaryTransferDateFROM DATE = '2023-01-01';
Declare @PrimaryTransferDateTO DATE = '2023-12-31';
--pxfer_date
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM INT = '20230101';
Declare @CertValueDateTO INT = '20231231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231

--DECLARE @VariableName INT = '';

--Change year 2023, 2024, 2025, etc. '702023'
DECLARE @LandModelId INT = '702024';
*/

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
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip
,TRIM(pm.AttentionLine) AS AttentionLine
,TRIM(pm.MailingAddress) AS MailingAddress
,TRIM(pm.AddlAddrLine) AS AddlAddrLine
,TRIM(pm.MailingCityStZip) AS MailingCityStZip
,TRIM(pm.MailingCity) AS MailingCity
,TRIM(pm.MailingState) AS MailingState
,TRIM(pm.MailingZip) AS MailingZip

,pm.LegalAcres
--,pm.WorkValue_Land
--,pm.WorkValue_Impv
--,pm.WorkValue_Total
--,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
AND pm.neighborhood <> 0
AND pm.neighborhood IS NOT NULL
),

CTE_LandInfluenceCodesKey AS (
  SELECT
  tbl_element AS InfluenceCode,
  tbl_element_desc AS InfluenceCodeDescription
  FROM codes_table
  WHERE TRIM(tbl_type_code) LIKE 'landinf%'
  AND code_status='A'
),

CTE_LegendKey AS (
  SELECT
  TRIM(sr.tbl_element) AS Site_Rating,
  TRIM(sr.tbl_element_desc) AS Legend,
  CASE
    WHEN TRIM(sr.tbl_element_desc) LIKE 'Leg%' THEN CAST(RIGHT(TRIM(sr.tbl_element_desc),2) AS INT)
    ELSE
      CASE
        WHEN sr.tbl_element_desc IS NULL THEN CAST(1 AS INT)
        WHEN sr.tbl_element_desc LIKE 'No%' THEN CAST(1 AS INT)
        WHEN sr.tbl_element_desc LIKE 'Average%' THEN CAST(2 AS INT)
        WHEN sr.tbl_element_desc LIKE 'Good%' THEN CAST(3 AS INT)
        WHEN sr.tbl_element_desc LIKE 'Excellent%' THEN CAST(4 AS INT)
        ELSE 0
      END
  END AS LegendNum

  FROM codes_table AS sr 
      
  WHERE sr.tbl_type_code='siterating'
  AND code_status = 'A'
  
  --JOIN ON
  --ON ld.SiteRating = sr.tbl_element
),

CTE_LandDetails AS (
  SELECT
  lh.RevObjId AS lrsn
, ld.LandType
,  CONCAT_WS('-',ld.LandType,lt.land_type_desc) AS LandType_Desc
,  STRING_AGG (ld.LDAcres, ', ') AS LDAcres
,  STRING_AGG (leg.Legend, ', ') AS Legend

  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  --Legend Key    
  LEFT JOIN CTE_LegendKey AS leg ON ld.SiteRating = leg.Site_Rating
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  --Land Influence
  LEFT JOIN LandInfluence AS li ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'
  --Land Influcnce Code Key for Description
  LEFT JOIN CTE_LandInfluenceCodesKey AS lic ON lic.InfluenceCode=li.InfluenceCode
  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  GROUP BY
  lh.RevObjId

--  ld.LDAcres
,  ld.LandType
,  lt.land_type_desc
--  leg.Legend

),

CTE_WorksheetMarketValues AS(
SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_inc AS Worksheet_Land,
    (r.income_value - r.land_mkt_val_cost) AS Worksheet_Imp,
    r.income_value AS Worksheet_Total

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
    (r.cost_value + r.land_mkt_val_cost) AS Worksheet_Total
    
FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status='W'
AND r.method = 'C' 
--AND r.land_model = @LandModelId

--ORDER BY GEO, PIN;
),

CTE_ParcelCounter AS (
SELECT
Owner
,COUNT(lrsn) AS CountParcels_PerOwner

FROM CTE_ParcelMaster
WHERE GEO = '42'
GROUP BY Owner
),

CTE_LegalAcresCounter AS (
SELECT
Owner
,SUM(LegalAcres) AS SUMLegalAcres_PerOwner

FROM CTE_ParcelMaster
WHERE GEO = '42'
GROUP BY Owner
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
    v.land_market_val AS CertValue_Land_Current,
    v.imp_val AS CertValue_Imp_Current,
    (v.imp_val + v.land_market_val) AS CertValue_Total_Current,
    v.eff_year AS Tax_Year_Cert,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO
--Change to desired year
    AND v.status = 'A'
),

CTE_Cert_Prev AS (
  SELECT 
    lrsn,
    --Certified Values
    v.land_market_val AS CertValue_Land_Previous,
    v.imp_val AS CertValue_Imp_Previous,
    (v.imp_val + v.land_market_val) AS CertValue_Total_Previous,
    v.eff_year AS Tax_Year_Cert,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  --WHERE v.eff_year BETWEEN @PrevCertValueDateFROM AND @PrevCertValueDateTO
  WHERE v.eff_year BETWEEN '20230101' AND '20231231'
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
),

CTE_Memos_RY AS (
Select
m.lrsn
,m.memo_id
,m.memo_text AS RY_Memo

FROM memos AS m
WHERE m.memo_id = @MemoID
--WHERE m.memo_id='RY24'
AND m.status = 'A'
AND m.memo_line_number <> '1'
)


SELECT DISTINCT
pmd.District
--,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,pc.CountParcels_PerOwner
,pmd.SitusAddress
,pmd.LegalAcres
,lac.SUMLegalAcres_PerOwner
--Worksheet Values Current
,ws.Worksheet_Land
,ws.Worksheet_Imp
,ws.Worksheet_Total
--Certified Market Values Previous
,cvp.CertValue_Land_Previous
,cvp.CertValue_Imp_Previous
,cvp.CertValue_Total_Previous
,cvp.Tax_Year_Cert


--Difference $
,(ws.Worksheet_Land - cvp.CertValue_Land_Previous) AS LandDiffAmount

,(ws.Worksheet_Imp - cvp.CertValue_Imp_Previous) AS ImpDiffAmount

,(ws.Worksheet_Total - cvp.CertValue_Total_Previous) AS TotalDiffAmount

--Difference %
,(ws.Worksheet_Land / NULLIF(cvp.CertValue_Land_Previous, 0)) AS LandDiffPerc

,(ws.Worksheet_Imp / NULLIF(cvp.CertValue_Imp_Previous, 0)) AS ImpDiffPerc

,(ws.Worksheet_Total / NULLIF(cvp.CertValue_Total_Previous, 0)) AS TotalDiffPerc

--Certified Market Values Current
,cv.CertValue_Land_Current
,cv.CertValue_Imp_Current
,cv.CertValue_Total_Current
,cv.Tax_Year_Cert

,mry.RY_Memo

,pmd.Property_Class_Description
,pmd.TAG
,pmd.Owner
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip
,pmd.AttentionLine
,pmd.MailingAddress
,pmd.AddlAddrLine
,pmd.MailingCityStZip
--,pmd.LegalAcres
,pmd.Improvement_Status

/*

,pmd.Property_Class_Description
,pmd.TAG
,pmd.Owner
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip
,pmd.AttentionLine
,pmd.MailingAddress
,pmd.AddlAddrLine
,pmd.MailingCityStZip
,pmd.LegalAcres
,pmd.Improvement_Status


,'>LandDetails>' AS LandDetails
,land.LandType_Desc
,land.Legend AS Legend_Land
,land.LDAcres AS LDAcres_Land

,waste.LandType_Desc
,waste.Legend AS Legend_Waste
,waste.LDAcres AS LDAcres_Waste

,carea.LandType_Desc
,carea.Legend AS Legend_Carea
,carea.LDAcres AS LDAcres_Carea

--Assessed Values after exemptions like Timber/Ag
,asd.AssessedValue_Land_wEx
,asd.AssessedValue_Imp
,asd.AssessedValue_Total
,asd.Tax_Year_Assessed

--Transfer Table Sale Details
,tr.SalePrice
,tr.SaleDate
,tr.SaleDescr
,tr.TranxType
,tr.DocNumber -- Multiples will have the same DocNum

*/


FROM CTE_ParcelMaster AS pmd

Left Join CTE_WorksheetMarketValues AS ws
  On ws.lrsn = pmd.lrsn
  
Left Join CTE_ParcelCounter AS pc
  On pmd.owner = pc.owner
  --,COUNT(lrsn) AS CountParcels_PerOwner

Left Join CTE_LegalAcresCounter AS lac
  On pmd.owner = lac.owner
  --,COUNT(LegalAcres) AS CountLegalAcres_PerOwner

Left Join  CTE_TransferSales AS tr -- ON tr.lrsn for joins
  ON tr.lrsn = pmd.lrsn

Left Join CTE_Cert AS cv
  ON pmd.lrsn=cv.lrsn
  AND cv.RowNumber = '1'

Left Join CTE_Cert_Prev AS cvp
  ON pmd.lrsn=cvp.lrsn
  AND cvp.RowNumber = '1'

Left Join CTE_Assessed AS asd
  ON pmd.lrsn=asd.lrsn
  AND asd.RowNumber = '1'
  
Left Join CTE_Memos_RY AS mry
  On pmd.lrsn = mry.lrsn
  
  
  
  
  
Left Join CTE_LandDetails AS land
  ON land.lrsn = pmd.lrsn
  And land.LandType IN ('9','9V','31','32','90','94','11','12')

Left Join CTE_LandDetails AS carea
  ON carea.lrsn = pmd.lrsn
  And carea.LandType IN ('C','CA')

Left Join CTE_LandDetails AS waste
  ON waste.lrsn = pmd.lrsn
  And waste.LandType IN ('82') 

--Order By AIN;
--And pmd.lrsn = 70757 -- for test only

--Where pmd.AIN = '309026'
--Where pmd.AIN = '309027'


Where pmd.GEO = '42'




Order By pmd.Owner;
