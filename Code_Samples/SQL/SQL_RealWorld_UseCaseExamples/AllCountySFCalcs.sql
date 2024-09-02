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


Declare @Year int = 2024; -- Input THIS year here
Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here
--EXACT
Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year

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
--,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
/*
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
*/
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_ResFloorSF AS (
Select Distinct
rf.lrsn
,rf.extension
--,rf.finish_living_area
,SUM(rf.finish_living_area) AS ResFinishedLivingAreaSF
From res_floor AS rf
  --On rf.lrsn = i.lrsn
    --And rf.extension = e.extension
Where rf.status = 'A'
And rf.eff_year=@EffYear0101Current
--And rf.lrsn=39159
Group By rf.lrsn,rf.extension --,rf.finish_living_area
--Order by rf.lrsn
),

CTE_ComUseSF AS (
Select Distinct
cu.lrsn
,cu.extension
,SUM(cu.area) AS CommercialBuildingSF
From comm_uses AS cu
  --On i.lrsn=cu.lrsn
  --And e.extension=cu.extension
Where cu.[status]='A'
Group By cu.lrsn,cu.extension
),

-----------------------
--CTE_ImpTable pulls in Residential and Mobile SF 
-- For both Total Sq Feet (including other improvements) and finished living SF
--Also pulls extension IDs and Improvement Types
-----------------------
CTE_ImpTable AS (
Select Distinct
i.lrsn
,SUM(i.imp_size) AS AnyResComSFOtherImps

--,i.extension
--,e.ext_description
--,i.improvement_id
--,i.imp_type
--,i.eff_year
--,e.eff_year
--,i.imp_size AS ResSFIncludesOtherImp
--,crf.ResFinishedLivingAreaSF
--,ccu.CommSF
FROM extensions AS e
    --Ensures only active records (not future or voided)
Join improvements AS i
    On i.lrsn=e.lrsn
    And i.extension = e.extension
    And i.status = 'A'
Where e.status = 'A'
And e.eff_year = @EffYear0101Current
And i.improvement_id NOT IN ('C')
Group By i.lrsn
)


SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,ccusf.CommercialBuildingSF
,crsf.ResFinishedLivingAreaSF
,ressf.AnyResComSFOtherImps
--,ressf.extension
--,ressf.ext_description
--,ressf.improvement_id
--,ressf.imp_type
--,ressf.eff_year
--,ressf.CommSF
--,ressf.ResFinishedLivingAreaSF
--,ressf.ResSFIncludesOtherImp
,pmd.Property_Class_Description
,pmd.TAG
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_ImpTable AS ressf
  ON ressf.lrsn = pmd.lrsn
--,ressf.ResSFIncludesOtherImp

LEFT JOIN CTE_ResFloorSF AS crsf
  ON crsf.lrsn = pmd.lrsn
--,crsf.ResFinishedLivingAreaSF

LEFT JOIN CTE_ComUseSF AS ccusf
ON ccusf.lrsn = pmd.lrsn
--,ccusf.CommSF
--Where pmd.lrsn = 39159
Order By District,GEO,PIN;

/*
-----------------------
--CTE_CommBldgSF pulls in Commercial SF
-----------------------
CTE_CommUses AS (
  SELECT
  cu.lrsn
  ,cu.extension
  ,SUM(area) AS [CommSF]

  FROM comm_uses AS cu
  WHERE status = 'A'
  GROUP BY cu.lrsn,cu.extension
),

LEFT JOIN CTE_CommUses AS cmsf
  ON cmsf.lrsn = ressf.lrsn
  AND ressf.extension = cmsf.extension

,cmsf.CommSF



*/