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


WITH

CTE_AllocationsImp AS (
Select 
a.lrsn
,a.extension
,e.ext_description
,a.improvement_id
,a.land_line_number
,i.imp_type
,a.group_code
,c.tbl_element_desc AS CodeDescription

From allocations AS a 
--Join e to i
Join extensions AS e
  On e.lrsn = a.lrsn
  And e.extension = a.extension
  And e.status = 'A'
--Join i to a
Left Join improvements AS i
  On a.lrsn=i.lrsn 
  And a.extension = i.extension
  And i.improvement_id = a.improvement_id
  And i.status = 'A'

-- Join a to c
Left Join codes_table AS c
  On a.group_code = c.tbl_element
  And c.code_status = 'A' 
  And tbl_type_code= 'impgroup'
  
  --c.tbl_type_code AS CodeType
  --c.tbl_element AS Group_Code, 
  --c.tbl_element_desc AS CodeDescription
  
Where a.status='A'
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

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.TAG) AS TAG


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
)

--Order By District,GEO;



SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.PIN
,pmd.AIN
,ai.group_code
,ai.CodeDescription
,pmd.ClassCD
,pmd.Property_Class_Description
,ai.extension
,ai.ext_description
,ai.improvement_id
,ai.land_line_number
,ai.imp_type
,pmd.GEO_Name
,pmd.lrsn
,pmd.TAG

FROM CTE_ParcelMaster AS pmd

JOIN CTE_AllocationsImp AS ai
  ON ai.lrsn = pmd.lrsn

WHERE ai.group_code IN ('81','82')









