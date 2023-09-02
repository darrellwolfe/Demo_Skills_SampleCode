/*
AsTxDBProd
GRM_Main


Building characteristics such as number of bedrooms, square footage, year built, and whether the property is waterfront or not.

improvements
dwellings
manuf_housing
comm_bldg

*/


----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------

--Extensions always comes first
JOIN extensions AS e ON kcv.lrsn=e.lrsn
  AND e.status = 'A'
  
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id='M'
--manuf_housing, comm_bldg, dwellings all must be after e and i
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
Join codes_table AS ct ON mh.mh_make=ct.tbl_element 
  AND ct.tbl_type_code='mhmake'
  
--manuf_housing, comm_bldg, dwellings all must be after e and i
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'

--manuf_housing, comm_bldg, dwellings all must be after e and i
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension












----------------------------------
-- View/Master Query - Limited Columns !!!!!!! UNDER CONSTRUCTION!!!!!!!
----------------------------------



Select *
  lrsn,
  extension AS [Record#],
  imp_type AS [BldgUse],
  year_built,
  eff_year_built,
  year_remodeled
From improvements

Select *
From dwellings

Select *
lrsn,
SUM (finish_living_area) AS [Bldg_SF]
From res_floor

Select *
From manuf_housing

Select *
From comm_bldg

Select *
From comm_uses



WITH
--Begin CTEs
CTE_ResBldgSF AS (
  SELECT
    lrsn,
    SUM(finish_living_area) AS [ResBldg_SF]
  FROM res_floor
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_ManBldgSF AS (
  SELECT
    lrsn,
    SUM(imp_size) AS [MH_SF]
  FROM improvements
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_CommBldgSF AS (
  SELECT
    lrsn,
    SUM(area) AS [CommSF]
  FROM comm_uses
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_YearBuilt AS (
  SELECT
    lrsn,
    MAX(year_built) AS [YearBuilt],
    MAX(eff_year_built) AS [EffYear],
    MAX(year_remodeled) AS [RemodelYear]
  FROM improvements
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_SalePrice AS (
  SELECT
    lrsn,
    pxfer_date,
    AdjustedSalePrice,
    ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY pxfer_date DESC) AS RowNum
  FROM transfer
  WHERE AdjustedSalePrice <> '0'
  GROUP BY lrsn, AdjustedSalePrice, pxfer_date
)

--End CTEs, Start Primary Query

SELECT
  pm.lrsn,
  LTRIM(RTRIM(pm.pin)) AS [PIN],
  LTRIM(RTRIM(pm.AIN)) AS [AIN],
  LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
  LTRIM(RTRIM(pm.TAG)) AS [TAG],
  LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
  pm.LegalAcres,
  pm.TotalAcres,
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
  pm.CostingMethod,
  --CTEs
  rsf.[ResBldg_SF],
  msf.[MH_SF],
  csf.[CommSF],
  yb.[YearBuilt],
  sp.AdjustedSalePrice
FROM TSBv_PARCELMASTER AS pm
--CTEs
LEFT JOIN CTE_ResBldgSF AS rsf ON pm.lrsn = rsf.lrsn
LEFT JOIN CTE_ManBldgSF AS msf ON pm.lrsn = msf.lrsn
LEFT JOIN CTE_CommBldgSF AS csf ON pm.lrsn = csf.lrsn
LEFT JOIN CTE_YearBuilt AS yb ON pm.lrsn = yb.lrsn
LEFT JOIN CTE_SalePrice AS sp ON pm.lrsn = sp.lrsn
WHERE pm.EffStatus = 'A'
  AND pm.ClassCD NOT LIKE '070%'
ORDER BY GEO, PIN;




/*


LEFT JOIN dwellings AS d ON i.lrsn=d.lrsn
  AND d.status='A'
  AND i.extension=d.extension
  --AND i.dwelling_number=d.dwelling_number


LEFT JOIN manuf_housing AS m ON i.lrsn=m.lrsn
  AND m.status='A'
  AND i.extension=m.extension
  --AND i.dwelling_number=m.dwelling_number

LEFT JOIN comm_bldg AS c ON i.lrsn=c.lrsn
  AND c.status='A'
  AND i.extension=c.extension
  --AND i.dwelling_number=c.dwelling_number



Where i.status='A'
  --AND improvement_id IN ('D','C','M')

*/











----------------------------------
-- Indiviual Queries below
----------------------------------





JOIN allocations AS a ON parcel.lrsn=a.lrsn 
  AND a.status='A' 
  AND a.group_code IN ('06','07') 
  AND a.last_update > '2023-01-01'




--Land Header
JOIN LandHeader AS lh ON lh.RevObjId=parcel.lrsn 
  AND lh.EffStatus= 'A' 
  AND lh.LastUpdate > '2023-01-01'
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
  AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')

--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

--allocations
LEFT JOIN allocations AS a ON parcel.lrsn=a.lrsn 
  AND a.status='A' 
  --AND a.group_code IN ('06','07')
  AND a.last_update > '2023-01-01'
  
  --Join codes_table to allocations
  LEFT JOIN codes_table AS impgroup ON a.group_code=impgroup.tbl_element 
    AND code_status='A'
    AND tbl_type_code IN ('impgroup')





--improvements ALL Primary Buildings SIMPLE NEW CONSTRUCTION
SELECT
lrsn,
extension,
dwelling_number,
imp_line_number,
improvement_id,
imp_type,
year_built,
eff_year_built,
year_remodeled,
pct_complete

FROM improvements

WHERE status='A'
AND improvement_id IN ('D', 'C', 'M')
AND year_built = '2022' 
--Use 2022 for NC22
--Change to 2023 for NC23

--IF the exact date were present in the dataset: AND year_built BETWEEN '2022-01-01' AND '2022-12-31';




--improvements ALL Primary Buildings SIMPLE

SELECT
lrsn,
extension,
dwelling_number,
imp_line_number,
improvement_id,
imp_type,
year_built,
eff_year_built,
year_remodeled,
pct_complete

FROM improvements --- AS imp

WHERE status='A'
AND improvement_id IN ('D','C','M')




--improvements ALL Primary Buildings

SELECT
lrsn,
extension,
dwelling_number,
imp_line_number,
improvement_id,
imp_type,
year_built,
eff_year_built,
year_remodeled,
condition,
reproduction_cost1,
phys_depreciation1,
pct_complete,
rem_value1,
true_tax_value1,
eff_year,
status

FROM improvements --- AS imp

WHERE status='A'
AND improvement_id IN ('D','C','M')



-----------Allocations

Select *
From allocations
Where status='A'


--Codes impgroup (aka Group Codes, aka group_code)
Select
tbl_element,
tbl_element_desc
From codes_table
Where code_status='A'
AND tbl_type_code IN ('impgroup')


--Codes PCC (aka Property Class Codes, aka ClassCD)
Select 
tbl_element,
tbl_element_desc
From codes_table
Where code_status='A'
AND tbl_type_code IN ('pcc')





