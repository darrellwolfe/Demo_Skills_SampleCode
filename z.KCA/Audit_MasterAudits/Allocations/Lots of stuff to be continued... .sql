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


Declare @Year int = 2023; -- Set this to the year you're working with

Declare @ModelYearCurrent varchar(6) = '70' + Cast(@Year as varchar) ; -- Generates '20230101' for the previous year
Declare @ModelYearPrevious varchar(6) = '70' + Cast(@Year - 1 as varchar) ; -- Generates '20230101' for the previous year


WITH

CTE_LandDetails AS (
Select Distinct 
lh.RevObjId AS lrsn
,ld.SoilIdent
,ld.ExcessLandFlag
--Land Details
,ld.LandLineNumber
--Land Type
,CONCAT(ld.LandType, ' | ', lt.land_type_desc) AS LandTypes
,ld.LandType
,lt.land_type_desc
--Land LCM
,CONCAT(ld.lcm, ' | ', ctlcm.tbl_element_desc) AS LCMs
,ld.lcm
,ctlcm.tbl_element_desc AS lcm_Desc
--Land Site Rating
,ld.SiteRating AS LegendType
,ctsr.tbl_element_desc AS LegendType_Descr
--Acres
,lh.TotalMktAcreage
,ld.LDAcres
,lh.TotalUseAcreage
,ld.ActualFrontage
,lh.BegEffDate
,lh.LastUpdate

From LandHeader AS lh 
  --ON parcel.lrsn=lh.RevObjId
JOIN LandDetail AS ld 
  ON lh.Id=ld.LandHeaderId 
  AND lh.LandModelId=ld.LandModelId
JOIN codes_table AS ctlcm 
  ON (ld.lcm=ctlcm.tbl_element 
  AND tbl_type_code='lcmshortdesc')
JOIN codes_table AS ctsr 
  ON (ld.SiteRating=ctsr.tbl_element 
  AND ctsr.tbl_type_code='siterating')
JOIN land_types AS lt 
  ON ld.LandType=lt.land_type
  
--Primary WHERE statements
WHERE lh.EffStatus='A'
  AND ld.EffStatus='A'
  AND ctlcm.code_status= 'A'
  AND ctsr.code_status= 'A'
  AND lh.PostingSource = 'A'
  AND ld.PostingSource = 'A'
  --Change land model ID for current year
  AND lh.LandModelId=@ModelYearCurrent
  AND ld.LandModelId=@ModelYearCurrent


),


CTE_AllocationsImp AS (
Select 
a.lrsn
,a.extension
,e.ext_description
,a.improvement_id
,a.land_line_number
,i.imp_type
,CONCAT(a.group_code, ' | ', c.tbl_element_desc) AS GroupCodes
,a.group_code
,c.tbl_element_desc AS CodeDescription
,a.property_class

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

,  pm.LegalAcres
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
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
,pmd.TAG


,ai.extension
,ai.ext_description
,ai.improvement_id
,ai.land_line_number
,ai.imp_type
,ai.GroupCodes
,ai.group_code
,ai.CodeDescription
,ai.property_class

,lds.SoilIdent
,lds.ExcessLandFlag
--Land Details
,lds.LandLineNumber
--Land Type
,lds.LandTypes
,lds.LCMs
,lds.LegendType_Descr
--Acres
,lds.TotalMktAcreage
,lds.LDAcres
,lds.TotalUseAcreage
,lds.ActualFrontage
,lds.BegEffDate
,lds.LastUpdate

,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity



FROM CTE_ParcelMaster AS pmd

JOIN CTE_AllocationsImp AS ai
  ON ai.lrsn = pmd.lrsn

LEFT JOIN CTE_LandDetails AS lds
  ON lds.lrsn = pmd.lrsn
  AND lds.LandLineNumber = ai.land_line_number
  













