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


DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @CurrentDate DATE = GETDATE();

--FIRST Year of Reval Cycle
DECLARE @FirstYearOfRevalCycle INT = 2023; 
--FIRST ACTUAL FUNCTIONAL Year of Reval Cycle
-- RY23 started 04/16/2022
-- 04/16/2022 -- 04/15/2027
DECLARE @FirstFunctionalYearOfRevalCycle INT = @FirstYearOfRevalCycle-1; 

DECLARE @MemoIDYear4YearsAgo VARCHAR(4) = CAST('RY' + RIGHT(CAST(@CurrentYear-4 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYearCurrentCycle VARCHAR(4) = CAST('RY' + RIGHT(CAST(@CurrentYear+1 AS VARCHAR(4)), 2) AS VARCHAR(4));
--PRINT @MemoIDYear4YearsAgo;
--PRINT @MemoIDYearCurrentCycle;

-- Current Tax Year -- Change this to the current tax year
DECLARE @MemoIDYear1 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear2 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+1 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear3 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+2 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear4 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+3 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear5 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+4 AS VARCHAR(4)), 2) AS VARCHAR(4));

DECLARE @FunctionalYearFROM DATE = CAST(CAST(@FirstFunctionalYearOfRevalCycle AS VARCHAR) + '-04-16' AS DATE);
DECLARE @FunctionalYearTO DATE = CAST(CAST(@FirstFunctionalYearOfRevalCycle+5 AS VARCHAR) + '-04-15' AS DATE);



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
, CASE
    WHEN pm.LegalAcres < 1 THEN 'Acres_LessThan_1'
    WHEN pm.LegalAcres BETWEEN 1 AND 4.9999 THEN 'Acres_1-5'
    WHEN pm.LegalAcres > 5 THEN 'Acres_Over_5'  
    ELSE NULL
  END AS Acres_Category
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod


,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
And pm.pin NOT LIKE 'E%'
And pm.pin NOT LIKE 'G%'
And pm.pin NOT LIKE 'U%'
AND pm.ClassCD NOT LIKE '070%'

),

--------------------------------
--Memos
--------------------------------

CTE_Memos_RY AS (
Select
m.lrsn
,m.memo_id AS RYYear
,ROW_NUMBER() OVER (PARTITION BY m.lrsn ORDER BY m.memo_id DESC) AS rn
FROM memos AS m

WHERE m.memo_id LIKE '%RY%'
And m.memo_line_number = '1'
AND m.status = 'A'
And m.memo_id BETWEEN @MemoIDYear4YearsAgo AND @MemoIDYearCurrentCycle

),


--------------------------------
--Land
--------------------------------

CTE_Land AS (
Select
m.lrsn
,m.memo_id AS LAND
,m.memo_text AS LAND_Text
,ROW_NUMBER() OVER (PARTITION BY m.lrsn ORDER BY m.memo_id DESC) AS rn
FROM memos AS m

WHERE m.memo_id = 'LAND'
And m.memo_line_number = '2'
AND m.status = 'A'
)



SELECT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.PIN
,pmd.AIN
,mry.RYYear
,land.LAND_Text
,pmd.lrsn
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
,pmd.Acres_Category
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_Memos_RY AS mry
  ON pmd.lrsn = mry.lrsn
  AND mry.rn = 1

LEFT JOIN CTE_Land AS land
  ON pmd.lrsn = land.lrsn
  AND land.rn = 1

--WHERE mry.RYYear IS NULL
--WHERE pmd.lrsn = 570061
--WHERE mry.RYYear LIKE 'RY11'


Order By District,GEO;
