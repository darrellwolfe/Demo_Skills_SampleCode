-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

Select Distinct 
Count(pm.lrsn) AS CountOfLRSN
From KCv_PARCELMASTER1 AS pm
Where pm.EffStatus = 'A'


Select Distinct 
Count(pm.lrsn) AS CountOfLRSN
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

*/


DECLARE @Year INT = 2023;
--Just update the year for the new counts

WITH

CTE_RollInventory AS (
  --------------------------------
  --CTE_RollInventory
  --------------------------------
SELECT 
r.AssessmentYear, 
r.Descr AS AssessmentType,
l.CadRollId,
i.TranId, 
i.CadLevelId, 
i.PIN, 
i.AIN, 
i.GeoCd, 
i.TAGDescr AS TAG

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId

/*   
CadRoll Table Id (r.Id) is the id for the specific tax roll desired. See CadRoll table or Schema in the Comptroller Reporting folder.
WHERE r.Id= '558'
WHERE r.Id IN ('558', '556', '555', '554')
*/

--WHERE r.Id IN ('558', '556', '555', '554')
WHERE r.AssessmentYear = @Year

),


CTE_ParcelMaster AS (
  --------------------------------
  --CTE_ParcelMaster
  --------------------------------
  Select Distinct
  pm.lrsn
, CASE
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
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Type
, CASE 
    WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
    WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
    WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
    WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
    WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
    WHEN pm.ClassCD = '667' THEN 'Operating_Property'
    WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
    WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
    ELSE 'Unasigned_or_OldInactiveParcel'
  END AS Property_Type_Class
, TRIM(pm.TAG) AS TAG
--,  TRIM(pm.DisplayName)) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip
, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.LegalAcres
,  pm.Improvement_Status -- <Improved vs Vacant


  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
    --AND pm.ClassCD NOT LIKE '010%'
    --AND pm.ClassCD NOT LIKE '020%'
    --AND pm.ClassCD NOT LIKE '021%'
    --AND pm.ClassCD NOT LIKE '022%'
    --AND pm.ClassCD NOT LIKE '030%'
    --AND pm.ClassCD NOT LIKE '031%'
    --AND pm.ClassCD NOT LIKE '032%'
    AND pm.ClassCD NOT LIKE '060%'
    AND pm.ClassCD NOT LIKE '070%'
    AND pm.ClassCD NOT LIKE '090%'
      
  Group By
  pm.lrsn
, pm.pin
, pm.PINforGIS
, pm.AIN
, pm.ClassCD
, pm.PropClassDescr
, pm.neighborhood
, pm.NeighborHoodName
, pm.TAG
--  pm.DisplayName,
, pm.SitusAddress
, pm.SitusCity
, pm.SitusState
, pm.SitusZip
, pm.CountyNumber
, pm.LegalAcres
, pm.Improvement_Status

),

CTE_Allocations AS (
SELECT 
a.lrsn
, a.extension
, a.improvement_id
, a.group_code
, impgroup.tbl_element_desc AS ImpGroup_Descr
, market_value
, cost_value

FROM allocations AS a 

LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'impgroup'

WHERE a.status='A' 
  --AND a.group_code IN ('01','03','04','05')
  AND a.group_code IN ('01','03','04','05','06','07','09')
  --AND a.group_code IN ('06','07') 
)


SELECT DISTINCT
ri.AssessmentYear,
ri.AssessmentType,
pm.District,
pm.GEO,
pm.GEO_Name,
pm.lrsn,
ri.PIN,
ri.AIN,
ri.TAG,
pm.ClassCD,
pm.Property_Class_Type,
pm.Property_Type_Class,
pm.LegalAcres,
pm.Improvement_Status,
STRING_AGG(ImpGroup_Descr, ', ') AS Timber_Ag

FROM CTE_ParcelMaster AS pm

JOIN CTE_RollInventory AS ri
  ON ri.AIN = pm.AIN

LEFT JOIN CTE_Allocations AS a
  ON a.lrsn=pm.lrsn

GROUP BY
ri.AssessmentYear,
ri.AssessmentType,
pm.District,
pm.GEO,
pm.GEO_Name,
pm.lrsn,
ri.PIN,
ri.AIN,
ri.TAG,
pm.ClassCD,
pm.Property_Class_Type,
pm.Property_Type_Class,
pm.LegalAcres,
pm.Improvement_Status


Order by District, GEO;