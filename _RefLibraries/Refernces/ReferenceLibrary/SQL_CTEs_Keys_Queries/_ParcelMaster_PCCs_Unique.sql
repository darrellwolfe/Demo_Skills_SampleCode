/*
AsTxDBProd
GRM_Main
*/

WITH

CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
Select Distinct
pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,CASE 
  WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040'
    , '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  
  WHEN pm.ClassCD IN ('527', '526') THEN 'Condos'

  WHEN pm.ClassCD IN ('546', '548', '565') THEN 'Manufactered_Home'
  WHEN pm.ClassCD IN ('555') THEN 'Floathouse_Boathouse'
  WHEN pm.ClassCD IN ('550','549','451') THEN 'LeasedLand'

  WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416'
  , '421', '435', '438', '442', '461') THEN 'Commercial_Industrial'

  WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '561') THEN 'Residential'

  WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  
  WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'

  WHEN pm.ClassCD = '667' THEN 'Operating_Property'
  WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
  WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'

  ELSE 'Unasigned_or_OldInactiveParcel'

END AS Property_Class_Type

From TSBv_PARCELMASTER AS pm
--Where pm.EffStatus = 'A'
--AND pm.ClassCD NOT LIKE '070%'
)

SELECT DISTINCT
pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Property_Class_Type

FROM CTE_ParcelMaster AS pmd

WHERE pmd.ClassCd BETWEEN '300' AND '700'

ORDER BY pmd.ClassCD