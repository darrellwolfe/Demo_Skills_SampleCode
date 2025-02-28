-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

Improvements Table last_update only goes back to 1998, no further back
Select *
From improvements AS i
--Where status = 'A'
Where last_update < '1999-01-01'

TSBv_PARCELMASTER shows only BegEffDate of 2006 or after (when we converted to the new software)
Select *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
And (CAST(BegEffDate AS DATE) > '1900-01-02' 
    And CAST(BegEffDate AS DATE) < '2007-01-01')
--CAST(BegEffDate AS DATE ())
Order By BegEffDate DESC;


*/




DECLARE @YearFrom INT = 1601; -- Needed to filter out errors
--Appraisers have accidentially typed nonsensical dates into the system, 
--  like "2" or "1091", not possible in Idaho, USA
Declare @YearTo INT = 1972; -- Only needed if you are filtering results
--And i.year_built BETWEEN 1601 AND 1972 -- Adjusted to a WHERE clause for clarity and flexibility




WITH 

CTE_ImprovementYears AS (
Select
i.lrsn
--,e.lrsn -- Check
,i.year_built
/*
, CASE
      WHEN i.year_built < 1920 THEN 'High Risk - Pre-1920s'
      WHEN i.year_built >= 1920 AND i.year_built < 1986 THEN 'Moderate Risk - 1920s-1985'
      WHEN i.year_built >= 1986 AND i.year_built <= 1991 THEN 'Lower Risk - 1986-1991'
      WHEN i.year_built > 1991 THEN 'Minimal Risk - Post-1991'
      ELSE 'NoCategory_Review'
  END AS LeadRiskCategory
--,e.ext_id
--,e.extension -- Check
,CONCAT_WS('-',i.extension, i.imp_type, e.ext_description) AS Improvement_Info
--,i.extension
--,i.improvement_id
--,i.imp_type
--,e.ext_description
*/
From extensions AS e

Join improvements AS i
  On i.lrsn=e.lrsn 
    And i.extension=e.extension
    And i.status='A'
  --And i.year_built BETWEEN 1601 AND 1972 -- Adjusted to a WHERE clause for clarity and flexibility
  And i.year_built > @YearFrom -- Adjusted to a WHERE clause for clarity and flexibility

Where e.status = 'A'
--Order by i.lrsn, i.year_built ASC;
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
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
/*
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

,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant
*/

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.pin NOT LIKE 'E%'
AND pm.pin NOT LIKE 'UP%'
)

SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
--,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip
,iy.year_built


FROM CTE_ParcelMaster AS pmd

JOIN CTE_ImprovementYears AS iy
  ON iy.lrsn = pmd.lrsn




