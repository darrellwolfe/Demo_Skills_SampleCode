-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

--DECLARE @VariableName INT = '';

--Change year 2023, 2024, 2025, etc. '702023'
DECLARE @LandModelId INT = '702024';


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
,pm.LegalAcres


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
AND pm.neighborhood <> 0
AND pm.neighborhood IS NOT NULL
),

CTE_WorksheetMarketValues AS(
SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_inc AS Worksheet_Land,
    (r.income_value - r.land_mkt_val_cost) AS Worksheet_Imp,
    r.income_value AS Worksheet_Total,
    r.land_model
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
    r.land_model

FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status='W'
AND r.method = 'C' 
--AND r.land_model = @LandModelId

--ORDER BY GEO, PIN;
)

SELECT DISTINCT
--pmd.District
pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,ws.land_model
,ws.Worksheet_Imp
,ws.Worksheet_Land
,ws.Worksheet_Total
,ws.PriceMethod

FROM CTE_ParcelMaster AS pmd

Left Join CTE_WorksheetMarketValues AS ws
  On ws.lrsn = pmd.lrsn





