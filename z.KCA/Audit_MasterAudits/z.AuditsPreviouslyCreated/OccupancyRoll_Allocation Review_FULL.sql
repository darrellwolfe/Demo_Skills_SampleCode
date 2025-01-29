-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

DECLARE @AnnualEffectiveYear AS INT = '20230101';
--DECLARE @OccupancyYear AS INT = '2023%';
DECLARE @OccupancyYear AS INT = (@AnnualEffectiveYear+1);


WITH

CTE_OccupancyListCreator AS (
SELECT 
ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNum
,v.*
FROM valuation AS v

WHERE v.status = 'A'
--AND v.lrsn = '76030'
AND v.eff_year >= @OccupancyYear
AND v.change_reason IN ('06','38')
--AND v.improvement_id = 'C'
--Order By extension
),

CTE_OccupancyList_Cleaned AS (
Select
oc.lrsn
,oc.last_update
,oc.update_user_id
,oc.land_assess
,oc.imp_assess
,oc.change_reason
,oc.valuation_comment
,oc.eff_year

From CTE_OccupancyListCreator AS oc
Where RowNum = 1
),

CTE_TotalOccupancies AS (
Select 
Count(ocl.lrsn) AS TotalOcc
From CTE_OccupancyList_Cleaned AS ocl
),

CTE_ExtensionsRaw AS (
SELECT DISTINCT 
ROW_NUMBER() OVER (PARTITION BY e.lrsn, e.extension ORDER BY e.sketch_update DESC) AS RowNum
,e.*
FROM extensions AS e
Where status IN ('A') --('A','H')
And eff_year >= @OccupancyYear
--And date_priced
And imp_tot_val1 <> 0
--And lrsn = 76030
),

CTE_ExtensionsClean AS (
Select
er.lrsn
,er.extension
,er.sketch_update
,er.ext_description
,er.date_priced
,er.val_change_date
,er.UserId

From CTE_ExtensionsRaw AS er
Where er.RowNum = 1
And extension NOT LIKE 'L%'
),

CTE_AllocationsRaw_Occupancy AS (
SELECT 
ROW_NUMBER() OVER (PARTITION BY a.lrsn, a.extension ORDER BY a.last_update DESC) AS RowNum
,a.*
FROM allocations AS a

WHERE a.status = 'H'
AND a.extension NOT LIKE 'L%'
AND a.eff_year >= @OccupancyYear
--AND a.improvement_id = 'C'
--Order By extension
),

CTE_AllocationsCleaned_Occupancy AS (
Select
ar.lrsn
,ar.last_update
,ar.eff_year
,ar.group_code
,ar.improvement_id
--ar.land_line_number
,TRIM(ar.extension) AS extension
,ar.cost_value

From CTE_AllocationsRaw_Occupancy AS ar
Where RowNum = 1
),

CTE_AllocationsRaw_AnnualRoll AS (
SELECT 
ROW_NUMBER() OVER (PARTITION BY a.lrsn, a.extension ORDER BY a.last_update DESC) AS RowNum
,a.*
FROM allocations AS a

WHERE a.status = 'H'
--AND a.lrsn = '76030'
AND a.eff_year = @AnnualEffectiveYear
--AND a.improvement_id = 'C'
--Order By extension
),

CTE_AllocationsCleaned_AnnualRoll AS (
Select
ar.lrsn
,ar.last_update
,ar.eff_year
,ar.group_code
,ar.improvement_id
--ar.land_line_number
,TRIM(ar.extension) AS extension
,ar.cost_value

From CTE_AllocationsRaw_AnnualRoll AS ar
Where RowNum = 1
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
        WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
        ELSE NULL
    END AS District
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
, pm.lrsn
, TRIM(pm.pin) AS PIN
, TRIM(pm.AIN) AS AIN
, TRIM(pm.TAG) AS TAG
, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity

  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
),

CTE_CompareCombined AS (
Select 
ocl.lrsn AS OccLrsn
,pmd.District
,pmd.GEO
,pmd.AIN
,pmd.PIN

,CASE
  WHEN acl.group_code = aacl.group_code THEN 'OK'
  ELSE 'Check'
 END AS Check_GroupCode

,CASE
  WHEN acl.cost_value = aacl.cost_value THEN 'OK'
  ELSE 'Check'
 END AS Check_Value

,acl.group_code AS GroupCode_Occ
,aacl.group_code AS GroupCode_Ann
,acl.cost_value AS Cost_Occ
,aacl.cost_value AS Cost_Ann


,'>AdditionalData' AS AdditionalData
,acl.improvement_id AS Imp_Occ
,aacl.improvement_id AS Imp_Ann
,acl.extension AS Ext_Occ
,aacl.extension AS Ext_Ann
,ocl.land_assess
,ocl.imp_assess
,ocl.change_reason
,ocl.valuation_comment
,ocl.eff_year
,ecl.extension AS Live_Ext
,ecl.ext_description AS Live_ExtDesc
,ocl.last_update
,ocl.update_user_id
,ecl.sketch_update
,ecl.date_priced
,ecl.val_change_date
,ecl.UserId

From CTE_OccupancyList_Cleaned AS ocl

Join CTE_ExtensionsClean AS ecl
  On ecl.lrsn = ocl.lrsn

Join CTE_AllocationsCleaned_Occupancy AS acl
  On ecl.lrsn = acl.lrsn
  And ecl.extension = acl.extension

Left Join CTE_AllocationsCleaned_AnnualRoll AS aacl
  On acl.lrsn = aacl.lrsn
  And acl.extension = aacl.extension

Left Join CTE_ParcelMaster AS pmd
  On pmd.lrsn = ocl.lrsn
  
)

-------------------------
-- Final List
-------------------------

Select 
(Select TotalOcc From CTE_TotalOccupancies) AS TotalOcc
,cc.*

From CTE_CompareCombined AS cc

/*
Where (cc.Check_GroupCode = 'Check'
      Or cc.Check_Value = 'Check')
--If we want4 to check either values or group codes, we can use this.
For now only checking group codes
*/
Where cc.Check_GroupCode = 'Check'
        
And cc.GroupCode_Ann <> '81'
-- I don't care if it changed from HB475 to Occupancy, Old Process for 2023

And cc.GroupCode_Ann IS NOT NULL
-- I don't care if it was brand new, therefore no value on annual roll

