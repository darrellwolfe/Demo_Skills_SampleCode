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
,TRIM(pm.ClassCD) AS ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description

,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip
,pm.LegalAcres
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
--AND pm.ClassCD NOT LIKE '070%'
),

CTE_ImpTypes AS (
Select 
i.lrsn
,i.extension
,i.dwelling_number
,i.improvement_id
,i.imp_line_number
,i.imp_type

From improvements AS i
  Join extensions AS e
  On e.lrsn = i.lrsn
  And e.extension = i.extension
  And e.status = 'A'

Where i.status = 'A'
And (improvement_id LIKE 'A%'
    Or improvement_id LIKE 'M')
--And improvement_id IN ('A%','M')
/*
On i.lrsn = 
And i.extension = 
And i.dwelling_number = 
*/
),

CTE_DWELL_RDF AS (
SELECT 
d.lrsn
,d.extension
,it.imp_type
--,d.mkt_house_type
,htyp.tbl_element_desc AS HouseType
,CONCAT(d.rdf_inf1_percent, ' | ', d.rdf_inf2_percent, ' | ', d.rdf_inf3_percent) AS RDF_Perc

FROM dwellings AS d
  Join extensions AS e
  On e.lrsn = d.lrsn
  And e.extension = d.extension
  And e.status = 'A'

LEFT JOIN codes_table AS htyp 
ON d.mkt_house_type = htyp.tbl_element 
  AND htyp.tbl_type_code='htyp'  
  AND htyp.code_status = 'A'

LEFT JOIN CTE_ImpTypes AS it
  On it.lrsn = d.lrsn
  And it.extension = d.extension
  And it.dwelling_number = d.dwelling_number

WHERE d.status = 'A'
--AND d.lrsn = '3716'
)



SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,imp.extension
,imp.HouseType
,imp.imp_type
,imp.RDF_Perc

,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Owner
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip
,pmd.LegalAcres
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 


FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_DWELL_RDF AS imp
  ON imp.lrsn = pmd.lrsn

WHERE pmd.Property_Class_Description LIKE '%NREV%' --IN ('549%')
OR pmd.PIN LIKE 'M%'

--Where pmd.lrsn = 1315
--WHERE pmd.AIN = '112004'

Order By District,GEO, PIN;
