-- !preview conn=conn

SELECT DISTINCT
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

--,m.lrsn
,m1.memo_id AS RY_Year
,m2.memo_line_number
,m2.memo_text
,m2.last_update AS RY_LastUpdate
,YEAR(m2.last_update) AS RY_Year_Updated


--,col.lrsn
,col.data_source_code
,col.appraiser
,col.appraisal_date
,col.data_collector
,col.collection_date

--,apr.lrsn
,apr.data_source_code
,apr.appraiser
,apr.appraisal_date
,apr.data_collector
,apr.collection_date

--,p.lrsn
,p.permit_type
,c.tbl_element_desc
,p.inactivedate
,f.date_completed
,f.field_person

FROM TSBv_PARCELMASTER AS pm

LEFT JOIN memos AS m1 ON pm.lrsn=m1.lrsn 
  AND m1.memo_id IN ('RY23','RY24','RY25','RY26','RY27')
  AND m1.memo_line_number = 1

LEFT JOIN memos AS m2 ON pm.lrsn=m2.lrsn 
  AND m2.memo_id IN ('RY23','RY24','RY25','RY26','RY27')
  AND m2.memo_line_number = 2

LEFT JOIN extensions AS col ON pm.lrsn=col.lrsn
  AND col.extension = 'L00'
  AND col.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
  
LEFT JOIN extensions AS apr ON pm.lrsn=apr.lrsn
  AND apr.extension = 'L00'
  AND apr.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
  
LEFT JOIN permits AS p ON pm.lrsn=p.lrsn
  AND p.status= 'I' 
  AND p.inactivedate BETWEEN '2022-04-16' AND '2027-04-15'
  
    LEFT JOIN field_visit AS f ON p.field_number=f.field_number
      --AND f.status='A'
    
    LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type 
      AND c.tbl_type_code= 'permits'
      AND c.code_status= 'A'
  
  
  WHERE pm.EffStatus = 'A'
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
      
GROUP BY
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

--,m.lrsn
,m1.memo_id
,m2.memo_line_number
,m2.memo_text
,m2.last_update

--,col.lrsn
,col.data_source_code
,col.appraiser
,col.appraisal_date
,col.data_collector
,col.collection_date

--,apr.lrsn
,apr.data_source_code
,apr.appraiser
,apr.appraisal_date
,apr.data_collector
,apr.collection_date

--,p.lrsn
,p.permit_type
,c.tbl_element_desc
,p.inactivedate
,f.date_completed
,f.field_person

