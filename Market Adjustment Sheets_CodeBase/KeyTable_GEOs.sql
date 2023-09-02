-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/
--------------------------------
--District Key
--------------------------------

Select Distinct
pm.neighborhood AS [GEO],
TRIM(pm.NeighborHoodName) AS [GEO_Name],
COUNT(pm.lrsn) AS [Parcels_In_GEO],

-- # District Key
CASE
  WHEN pm.neighborhood = '0' THEN 'Needs Reivew_Or_Personal Property'
  WHEN pm.neighborhood = '450' THEN 'PersonalProperty_CellTowers'
  --Commercial Geos
  WHEN pm.neighborhood BETWEEN '1' AND '899' THEN 'Commercial'
  --MH
  WHEN pm.neighborhood = '1000' THEN 'Manufactured Homes'
  WHEN pm.neighborhood = '1020' THEN 'Manufactured Homes'
  WHEN pm.neighborhood = '5000' THEN 'Manufactured Homes'
  WHEN pm.neighborhood = '5002' THEN 'Manufactured Homes'
  WHEN pm.neighborhood = '6000' THEN 'Manufactured Homes'
  WHEN pm.neighborhood = '6002' THEN 'Manufactured Homes'
--Districts      
  WHEN pm.neighborhood BETWEEN '1000' AND '1999' THEN 'District 1'
  WHEN pm.neighborhood BETWEEN '2000' AND '2999' THEN 'District 2'
  WHEN pm.neighborhood BETWEEN '3000' AND '3999' THEN 'District 3'
  WHEN pm.neighborhood BETWEEN '4000' AND '4999' THEN 'District 4'
  WHEN pm.neighborhood BETWEEN '5000' AND '5999' THEN 'District 5'
  WHEN pm.neighborhood BETWEEN '6000' AND '6999' THEN 'District 6'
--MH Again
  WHEN pm.neighborhood >= '9000' THEN 'Manufactured Homes'
--Else
  ELSE 'Needs Review'
END AS [District],

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
  WHEN pm.neighborhood IN ('1998','1999') THEN 'Res_MutliFamily'
--D2
  WHEN pm.neighborhood IN ('2105','2115','2125','2135','2145','2155') THEN 'Res_Waterfront'
  WHEN pm.neighborhood IN ('2996','2997','2998','2999') THEN 'Res_MutliFamily'
--D3
  WHEN pm.neighborhood IN ('3502','3503','3504','3505','3506') THEN 'Res_Waterfront'
  WHEN pm.neighborhood IN ('3998','3999') THEN 'Res_MutliFamily'
--D4
  WHEN pm.neighborhood IN ('4201','4202','4203','4204','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
  WHEN pm.neighborhood IN ('4833','4840','4997','4998','4999') THEN 'Res_MutliFamily'
--D5
  WHEN pm.neighborhood IN ('5001','5004','5009','5010','5012','5015','5018','5020','5021','5024','5030','5033','5036','5039',
                            '5042','5045','5048','5051','5053','5054','5056','5057','5060','5063','5066','5069','5072','5075','5078',
                            '5081','5750','5753','5756','5759','5762','5765','5850','5853','5856') THEN 'Res_Waterfront'
  -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D5 as of 08/02/2023
--D6
  WHEN pm.neighborhood BETWEEN '6100' AND '6123' THEN 'Res_Waterfront'
  -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D6 as of 08/02/2023
-- MH Sales Worksheet Type
  WHEN pm.neighborhood = '1000' THEN 'MH_Sales'
  WHEN pm.neighborhood = '1020' THEN 'MH_Sales'
  WHEN pm.neighborhood = '5000' THEN 'MH_Sales'
  WHEN pm.neighborhood = '5002' THEN 'MH_Sales'
  WHEN pm.neighborhood = '6000' THEN 'MH_Sales'
  WHEN pm.neighborhood = '6002' THEN 'MH_Sales'
  WHEN pm.neighborhood >= '9000' THEN 'MH_Sales'

--Else
  ELSE 'Res_Sales'
END AS [District_SubClass]



From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.neighborhood <> 0

Group By
pm.neighborhood,
pm.NeighborHoodName

Order By GEO;



