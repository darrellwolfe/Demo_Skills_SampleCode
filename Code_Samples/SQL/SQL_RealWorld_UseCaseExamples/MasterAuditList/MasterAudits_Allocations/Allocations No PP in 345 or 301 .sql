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

,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip

,TRIM(pm.AttentionLine) AS AttentionLine
,TRIM(pm.MailingAddress) AS MailingAddress
,TRIM(pm.AddlAddrLine) AS AddlAddrLine
,TRIM(pm.MailingCityStZip) AS MailingCityStZip
,TRIM(pm.MailingCity) AS MailingCity
,TRIM(pm.MailingState) AS MailingState
,TRIM(pm.MailingZip) AS MailingZip
,TRIM(pm.CountyNumber) AS CountyNumber

,CASE
  WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
  ELSE NULL
END AS County_Name

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

CTE_TAG_TA_TIF_Key AS (
  SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ta.Id AS TaxAuthId,
  TRIM(ta.Descr) AS TaxAuthority
  
  --TAG Table
  FROM TAG AS tag
  --TAGTIF Key
  LEFT JOIN TAGTIF 
    ON TAG.Id=TAGTIF.TAGId 
    AND TAGTIF.EffStatus = 'A'
  --TIF Table
  LEFT JOIN TIF AS tif 
    ON TAGTIF.TIFId=TIF.Id 
    AND TIF.EffStatus  = 'A'
  --TAGTaxAuthority Key
  LEFT JOIN TAGTaxAuthority 
    ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
  --TaxAuthority Table
  LEFT JOIN TaxAuthority AS ta 
    ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
  --CTE_ JOIN, only want TAGs in this TaxAuth
  
  WHERE tag.EffStatus = 'A'
  
  AND (ta.Descr LIKE '%345%'
    OR ta.Descr LIKE '%301%')
  /*
  AND (ta.Descr LIKE '%250%'
    OR ta.Descr LIKE '%251%')
    */
),

CTE_Allocations AS (
Select 
a.lrsn
,a.extension
,e.ext_description
,a.improvement_id
,a.land_line_number
,i.imp_type
,a.group_code
,c.tbl_element_desc AS CodeDescription


From TSBv_PARCELMASTER AS pm
-- Join a to pm for active parcels only
Join allocations AS a 
  On a.lrsn = pm.lrsn
  And a.status='A'
  --And a.group_code IN ('98','99')

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
  
Where pm.EffStatus = 'A'
--And a.group_code IN ('06','07')
)


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
,pmd.TAG
,ttt.TaxAuthority
,al.CodeDescription

,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip

,pmd.Owner
,pmd.AttentionLine
,pmd.MailingAddress
,pmd.AddlAddrLine
,pmd.MailingCityStZip
,pmd.MailingCity
,pmd.MailingState
,pmd.MailingZip
,pmd.CountyNumber
,pmd.County_Name

,pmd.LegalAcres
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 


FROM CTE_ParcelMaster AS pmd

JOIN CTE_TAG_TA_TIF_Key AS ttt
  On ttt.TAG = pmd.TAG

JOIN CTE_Allocations AS al
  On al.lrsn = pmd.lrsn
--  ON xxxx.lrsn = pmd.lrsn


WHERE pmd.PIN LIKE 'E%'


Order By District,GEO;


