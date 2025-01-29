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
--  ON xxxx.lrsn = pmd.lrsn


--Order By District,GEO;
