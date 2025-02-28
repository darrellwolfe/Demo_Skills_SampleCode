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


DECLARE @TaxYear INT = 2024; 
-- Current Tax Year -- Change this to the current tax year

DECLARE @MemoIDCurr VARCHAR(4) = CAST('NC' + RIGHT(CAST(@TaxYear AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDPrev VARCHAR(4) = CAST('NC' + RIGHT(CAST(@TaxYear - 1 AS VARCHAR(4)), 2) AS VARCHAR(4));
--WHERE m.memo_id='RY24'

Declare @CertValueDateFROM varchar(8) = Cast(@TaxYear - 1 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@TaxYear - 1 as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20230101';
--Declare @CertValueDateTO INT = '20231231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231

Declare @EffYearCurrent varchar(8) = Cast(@TaxYear as varchar) + '%';
Declare @EffYearPrevious varchar(8) = Cast(@TaxYear - 1 as varchar) + '%';
--For improvements

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
  WHEN pm.neighborhood = 0 THEN 'Personal-OperatingProperty_N/A_or_Error'
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
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity

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

CTE_WorksheetMarketValues AS(
SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_inc AS Worksheet_Land_Market,
    (r.income_value - r.land_mkt_val_inc) AS Worksheet_Imp_Market,
    r.income_value AS Worksheet_Total_Market

FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status = 'W'
AND r.method = 'I' 
--AND r.land_model = @LandModelId

UNION ALL

SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_cost AS Worksheet_Land_Market,
    r.cost_value AS Worksheet_Imp_Market,
    (r.cost_value + r.land_mkt_val_cost) AS Worksheet_Total_Market
    
FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status='W'
AND r.method = 'C' 
--AND r.land_model = @LandModelId
--ORDER BY GEO, PIN;
),

CTE_Memos_NC AS (
Select
m.lrsn
--,m.memo_id
,STRING_AGG (m.memo_text, ', ') AS NC_Memo
--,m.memo_text AS NC_Memo
FROM memos AS m
WHERE (m.memo_id = @MemoIDPrev
      OR m.memo_id = @MemoIDCurr)
  --WHERE m.memo_id='NC24'
  AND m.status = 'A'
  --AND m.memo_line_number = 2
GROUP BY m.lrsn

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



CTE_ImprovementYears AS (
Select Distinct
i.lrsn
,STRING_AGG (i.year_built, ', ') AS year_built
,STRING_AGG (i.improvement_id, ', ') AS improvement_id
--i.year_built
--i.improvement_id

From improvements AS i
Join extensions AS e
  On i.lrsn = e.lrsn
  And i.extension = e.extension
  And e.status = 'A'

Where i.status = 'A'
--And e.eff_year LIKE '2023%'
--And e.eff_year LIKE @EffYearPrevious
--Year not needed if only looking for active i and active e
And i.improvement_id IN ('C','M','D','A01','A02','A03','A04','G01','G02','G03','G04','G05','G06','G07','G08')
Group By i.lrsn
)



/*
CTE_MAYBEDOCALCSHERE AS (
CALCS HERE THEN JOIN THEM?
)
*/


----LEFT OFF AT JOINS
----NEEDS CACLS

SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,wk.PriceMethod

,(wk.Worksheet_Land_Market - market.Market_Land_PreEx) AS DiffValue_Land
,(wk.Worksheet_Imp_Market - market.Market_Imp) AS DiffValue_Imp
,(wk.Worksheet_Total_Market - market.Market_Total) AS DiffValue_Total

,(Cast(wk.Worksheet_Land_Market AS Decimal(18,2)) / NULLIF(Cast(market.Market_Land_PreEx AS Decimal(18,2)), 0)) AS DiffPerc_Land
,(Cast(wk.Worksheet_Imp_Market AS Decimal(18,2)) / NULLIF(Cast(market.Market_Imp AS Decimal(18,2)), 0)) AS DiffPerc_Imp
,(Cast(wk.Worksheet_Total_Market AS Decimal(18,2)) / NULLIF(Cast(market.Market_Total AS Decimal(18,2)), 0)) AS DiffPerc_Total

,'Wk' AS WorksheetValues
,wk.Worksheet_Land_Market
,wk.Worksheet_Imp_Market
,wk.Worksheet_Total_Market
,'Cert' AS CertifiedValues
,market.Market_Land_PreEx AS Cert_Market_Land_PreEx
,market.Market_Imp AS Cert_Market_Imp
,market.Market_Total AS Cert_Market_Total
,market.Tax_Year_Market AS Cert_TaxYear


,'OtherData' AS OtherData
,TRIM(nc.NC_Memo) AS NC_Memo
,iy.year_built AS YearBuiltLivableStructures
,iy.improvement_id
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.TAG
,pmd.SitusAddress
,pmd.SitusCity
,pmd.Improvement_Status 

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_WorksheetMarketValues AS wk
  ON wk.lrsn = pmd.lrsn
  --AND PriceMethod = 'I'

LEFT JOIN CTE_Market AS market
  ON market.lrsn = pmd.lrsn
  AND market.RowNumber = '1'

LEFT JOIN CTE_Memos_NC AS nc
  ON nc.lrsn = pmd.lrsn

LEFT JOIN CTE_ImprovementYears AS iy
  ON iy.lrsn = pmd.lrsn

Order By District,GEO, PIN;


/*
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
,ass.AssessedValue_Land_wEx
,ass.AssessedValue_Imp
,ass.AssessedValue_Total
,ass.Tax_Year_Assessed

LEFT JOIN CTE_Assessed AS ass
  ON ass.lrsn = pmd.lrsn
  AND ass.RowNumber = '1'
*/
