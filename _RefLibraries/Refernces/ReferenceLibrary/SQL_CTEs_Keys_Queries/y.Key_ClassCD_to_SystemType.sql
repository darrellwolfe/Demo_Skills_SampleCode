-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

res_floor.finish_living_area
rf.finish_living_area


rf.lrsn,
SUM(rf.br_count) AS Bedrooms,
SUM(((rf.fix_2_count/2) + rf.fix_3_count + rf.fix_4_count + rf.fix_5_count)) AS Bathrooms

*/


Select
tbl_type_code AS PCC
,CAST(tbl_element AS INT) AS ClassCD
,tbl_element_desc AS ClassCD_Desc
,CodesToSysType AS ClassCD_SystemType
,CASE 
  WHEN CAST(tbl_element AS INT) IN ('010', '020', '021', '022', '030', '031', '032', '040'
    , '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  
  WHEN CAST(tbl_element AS INT) IN ('527', '526') THEN 'Condos'

  WHEN CAST(tbl_element AS INT) IN ('546', '548', '565') THEN 'Manufactered_Home'
  WHEN CAST(tbl_element AS INT) IN ('555') THEN 'Floathouse_Boathouse'
  WHEN CAST(tbl_element AS INT) IN ('550','549','451') THEN 'LeasedLand'

  WHEN CAST(tbl_element AS INT) IN ('314', '317', '322', '336', '339', '343', '413', '416'
  , '421', '435', '438', '442', '461') THEN 'Commercial_Industrial'

  WHEN CAST(tbl_element AS INT) IN ('411', '512', '515', '520', '534', '537', '541', '561') THEN 'Residential'

  WHEN CAST(tbl_element AS INT) IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  
  WHEN CAST(tbl_element AS INT) IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'

  WHEN CAST(tbl_element AS INT) = '667' THEN 'Operating_Property'
  WHEN CAST(tbl_element AS INT) = '681' THEN 'Exempt_Property'
  WHEN CAST(tbl_element AS INT) = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'

  ELSE 'Unasigned_or_OldInactiveParcel'

END AS Property_Class_Category
From codes_table
Where tbl_type_code LIKE '%PCC%'
And code_status = 'A'
Order by tbl_element_desc

