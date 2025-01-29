-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/
--------------------------------
--District Key
--------------------------------
-------------------------------------
-- CTEs will drive this report and combine in the main query
-------------------------------------
WITH
-------------------------------------
--CTE_ParcelMasterData
-------------------------------------
CTE_ParcelMasterData AS (
SELECT DISTINCT
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
    END AS District,
-- # District SubClass
CASE
    --Commercial # Income properties use regular template, for now. 
    --  May build something. Set up just in case. DGW 08/02/2023.
      WHEN pm.neighborhood BETWEEN '1' AND '27' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '28' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pm.neighborhood BETWEEN '29' AND '41' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '41' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '42' THEN 'Section42_Workbooks'
      WHEN pm.neighborhood = '43' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '44' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pm.neighborhood BETWEEN '45' AND '99' THEN 'Comm_Sales'
      WHEN pm.neighborhood BETWEEN '100' AND '199' THEN 'Comm_Waterfront'
      WHEN pm.neighborhood BETWEEN '200' AND '899' THEN 'Comm_Sales'
    --D1
      WHEN pm.neighborhood IN ('1008','1010','1410','1420','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('1998','1999') THEN 'Res_MultiFamily'
    --D2
      WHEN pm.neighborhood IN ('2105','2115','2125','2135','2145','2155') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('2996','2997','2998','2999') THEN 'Res_MultiFamily'
    --D3
      WHEN pm.neighborhood IN ('3502','3503','3504','3505','3506') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('3998','3999') THEN 'Res_MultiFamily'
    --D4
      WHEN pm.neighborhood IN ('4201','4202','4203','4204','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('4833','4840','4997','4998','4999') THEN 'Res_MultiFamily'
    --D5
      WHEN pm.neighborhood IN ('5001','5004','5009','5010','5012','5015','5018','5020','5021','5024','5030','5033','5036','5039',
                                '5042','5045','5048','5051','5053','5054','5056','5057','5060','5063','5066','5069','5072','5075','5078',
                                '5081','5750','5753','5756','5759','5762','5765','5850','5853','5856') THEN 'Res_Waterfront'
      -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D5 as of 08/02/2023
    --D6
      WHEN pm.neighborhood BETWEEN '6100' AND '6123' THEN 'Res_Waterfront'
      -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D6 as of 08/02/2023
    -- MH Sales Worksheet Type
      WHEN pm.neighborhood = '1000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '1000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'

      WHEN pm.neighborhood = '1020' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '1020' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '5000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '5002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '6000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         
      
      WHEN pm.neighborhood = '6002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'  
      
      WHEN pm.neighborhood = '9103' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '9103' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

      WHEN pm.neighborhood >= '9000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood >= '9000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         
      
    --Else
      ELSE 'Res_Sales'
  END AS District_SubClass,
  pm.lrsn,
  TRIM(pm.pin) AS PIN,
  TRIM(pm.AIN) AS AIN,
  pm.neighborhood AS GEO,
  TRIM(pm.NeighborHoodName) AS GEO_Name
  
  FROM TSBv_PARCELMASTER AS pm
  --WHERE pm.EffStatus = 'A'
  
  )

Select Distinct
pmd.District,
pmd.District_SubClass,
pmd.GEO,
pmd.GEO_Name,
COUNT(pmd.lrsn) AS Parcels_In_GEO


From CTE_ParcelMasterData AS pmd

Where pmd.GEO <> 0
--AND pmd.District_SubClass LIKE 'MH%'
--AND pmd.District = 'Manufactured_Homes'
--AND pmd.PIN NOT LIKE 'M%'

Group By
pmd.District,
pmd.District_SubClass,
pmd.GEO,
pmd.GEO_Name

Order By pmd.District,
pmd.District_SubClass,
pmd.GEO;



