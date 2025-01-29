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
  WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
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

,CASE 
  WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
  WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
  WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
  WHEN pm.ClassCD = '667' THEN 'Operating_Property'
  WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
  WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
  ELSE 'Unasigned_or_OldInactiveParcel'
END AS Property_Class_Type

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

CTE_Improvements AS (
  Select Distinct
  --Extensions Table
  e.lrsn,
  e.extension,
  e.ext_description,
  STRING_AGG(cu.use_code, ',') AS CommUseCodes,
  -- AND htyp.tbl_type_code='htyp'  
  STRING_AGG(dw.mkt_house_type, ' | ') AS HouseTypeNum,
  STRING_AGG(htyp.tbl_element_desc, ' | ')  AS HouseTypeName

  --Extensions always comes first
  FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
    -- AND e.status = 'A' -- Filter if joining this to another query
  JOIN improvements AS i ON e.lrsn=i.lrsn 
        AND e.extension=i.extension
        AND i.status='A'
        AND i.improvement_id IN ('M','C','D')

  --manuf_housing, comm_bldg, dwellings all must be after e and i
  --RESIDENTIAL DWELLINGS
  LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
        AND dw.status='A'
        AND i.extension=dw.extension
    LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
      AND htyp.tbl_type_code='htyp'  
       
  --MANUFACTERED HOUSING
  LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
        AND i.extension=mh.extension
        AND mh.status='A'
    LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
      AND make.tbl_type_code='mhmake'
    LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
      AND model.tbl_type_code='mhmodel'
    LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
      AND park.tbl_type_code='mhpark'
  --COMMERCIAL
    LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
        AND i.extension=cb.extension
        AND cb.status='A'
      LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
        AND cb.extension = cu.extension
        AND cu.status='A'
  
    --Conditions
  WHERE e.status = 'A'
  AND i.improvement_id IN ('D','M','C')

  --AND e.ext_description LIKE 'CONDO'

  GROUP BY
  e.lrsn,
  e.extension,
  e.ext_description

)

--Order By District,GEO;



SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Property_Class_Type

,imp.extension
,imp.ext_description
,imp.CommUseCodes
,imp.HouseTypeNum
,imp.HouseTypeName

,pmd.SitusCity

,pmd.LegalAcres
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 


FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_Improvements AS imp
  ON imp.lrsn = pmd.lrsn


ORDER BY District, GEO, PIN;