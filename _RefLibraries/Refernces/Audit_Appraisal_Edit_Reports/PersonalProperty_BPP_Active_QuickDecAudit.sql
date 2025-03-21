-- !preview conn=conn


/*
AsTxDBProd
GRM_Main

**PERSONAL PROPERTY QUERY REQUIRES YEARLY UPDATES IN SEVERAL TABLES, REVIEW ALL YEARS
2023 TO 2024, ETC.

*/


--------------------------------
--Variables BEGIN
--------------------------------

DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

-- DECLARE @Year INT = 2024; -- Input year

-- Use CONCAT to create date strings for the start and end of the year
DECLARE @LastYearCertFrom VARCHAR(8) = CAST(CONCAT(@Year - 1, '0101') AS VARCHAR(8));
DECLARE @LastYearCertTo VARCHAR(8) = CAST(CONCAT(@Year - 1, '1231') AS VARCHAR(8));

-- Date and time for January 1 of the input year
DECLARE @ThisYearCertFrom VARCHAR(8) = CAST(CONCAT(@Year, '0101') AS VARCHAR(8));
DECLARE @ThisYearCertTo VARCHAR(8) = CAST(CONCAT(@Year, '1231') AS VARCHAR(8));

-- Use CONCAT for creating range values for MPPV
DECLARE @ThisYearMPPVFrom VARCHAR(9) = CAST(CONCAT(@Year, '00000') AS VARCHAR(9));
DECLARE @ThisYearMPPVTo VARCHAR(9) = CAST(CONCAT(@Year, '99999') AS VARCHAR(9));

-- Declare cadaster year as the input year
DECLARE @CadasterYear INT = @Year;

DECLARE @NoteYear VARCHAR(10) = CAST(CONCAT('%',@Year,'%') AS VARCHAR(10));





WITH
--------------------------------
--CTEs BEGIN
--------------------------------
CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
  Select Distinct
  pm.lrsn
,pm.EffStatus AS AccountStatus
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Desc
, TRIM(pm.TAG) AS TAG
, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip
--, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.AttentionLine) AS Attn
, TRIM(pm.MailingAddress) AS MailingAddress
, TRIM(pm.MailingCityStZip) AS MailingCSZ
, TRIM(pm.DisplayDescr) AS LegalDescription

, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.LegalAcres
,  pm.Improvement_Status -- <Improved vs Vacant


  From TSBv_PARCELMASTER AS pm
  
  Where pm.ClassCD IN ('020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090')
  AND pm.PIN NOT LIKE 'U%'
  AND pm.PIN NOT LIKE 'G%'

  AND pm.EffStatus = 'A'
--Order By District,GEO;
),

CTE_MPPV AS (
--Looking for Aquisition Value and Appraised Value from MPPV, aggragated by lrsn (mPropertyId); rather than by individual asset.
--DECLARE @ThisYearMPPVFrom INT = '202300000';
--DECLARE @ThisYearMPPVTo INT = '202399999';
SELECT 
mPropertyId AS lrsn
,SUM(mAcquisitionValue) AS mAcquisitionValue
,SUM(
 CASE 
--mOverrideReason = 1 --This means the checkmark is checked
--mOverrideReason = 0 --This means the checkmark is NOT checked  
    WHEN mOverrideReason = 0 THEN mAppraisedValue
    WHEN mOverrideReason = 1 THEN mOverrideValue
    ELSE mAppraisedValue
  END
  ) AS mAppraisedValue

FROM tPPAsset
WHERE mEffStatus = 'A' 
--AND mPropertyId = 510587 -- Use as Test
And mbegTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo
And mendTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo

GROUP BY 
mPropertyId
--,mAssetCategory
--,mScheduleName
),

--Pulling in Aumentum Notes
CTE_Note_Status AS (
SELECT
ROW_NUMBER() OVER (PARTITION BY n.objectId ORDER BY n.createTimestamp DESC) AS RowNum,
n.createTimestamp,
--n.createdByUserId,
CONCAT(TRIM(up.FirstName), ' ', TRIM(up.LastName)) AS UserName,
--up.FirstName,
--up.LastName,
--n.effStatus
n.objectId, --lrsn or RevObjId
n.noteText,
n.taxYear
FROM Note AS n
JOIN UserProfile AS up
  ON up.Id = n.createdByUserId
JOIN CTE_ParcelMaster AS pmd
  ON pmd.lrsn = n.objectId

WHERE n.effStatus = 'A'
AND noteText LIKE '%DONE%'
AND YEAR(createTimestamp) = @Year
),

--Pulling in Aumentum Notes
CTE_Note_DecProcessing AS (
Select
  n.objectId
  ,STRING_AGG(n.noteText, ', ') AS noteText

From Note AS n
JOIN CTE_ParcelMaster AS pmd
  ON pmd.lrsn = n.objectId

WHERE n.effStatus = 'A'
AND noteText NOT LIKE '%DONE%'
AND noteText LIKE @NoteYear
AND YEAR(createTimestamp) = @Year
Group By n.objectId

),


--Looking for the Personal Property 63-602KK $250,000 exemption from Aumentum Modifiers, paying special attention to the shared exemptions
CTE_63602KK AS (
SELECT
lrsn,
TRIM(ModifierDescr) AS PPExemption602KK_ModifierDescr,
ModifierPercent,
--CAST(OverrideAmount AS BIGINT) AS PPExemption602KK,
--TRY_CAST(ISNUMERIC(OverrideAmount) AS BIGINT) AS PPExemption602KK,
CAST(OverrideAmount AS INT) AS PPExemption602KK,
ExpirationYear

FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%602KK%'
AND PINStatus='A'
AND ExpirationYear > @CurrentYear
),




---------------------------------------
--Begins Primary Query
---------------------------------------
CTE_PP_Query_20_32 AS (
--------------------------
-- SELECT START HERE
-------------------------
SELECT DISTINCT
pmd.lrsn
,pmd.AIN
,pmd.PIN
,pmd.Property_Class_Desc

,CASE
  WHEN pmd.Property_Class_Desc LIKE '%20%' THEN 'PP1'
  WHEN pmd.Property_Class_Desc LIKE '%30%' THEN 'PP1'
  WHEN pmd.Property_Class_Desc LIKE '%22%' THEN 'PP2'
  WHEN pmd.Property_Class_Desc LIKE '%32%' THEN 'PP2'
  ELSE 'ReviewClassCode'
END AS RollType

,pmd.Owner
,decnotes.noteText AS DecNotes
,statusnotes.noteText AS StatusNotes
,statusnotes.UserName
,CAST(statusnotes.createTimestamp AS DATE) AS DateDone
,mppv.mAcquisitionValue
,mppv.mAppraisedValue
, CASE
    WHEN kk602.PPExemption602KK IS NULL THEN 0
    ELSE kk602.PPExemption602KK
  END AS PPExemption602KK
,(mppv.mAppraisedValue-kk602.PPExemption602KK) AS NetTaxable


--------------------------
-- FROM START HERE
-------------------------

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_MPPV AS mppv 
  ON pmd.lrsn=mppv.lrsn

LEFT JOIN CTE_63602KK AS kk602
  ON pmd.lrsn=kk602.lrsn

LEFT JOIN CTE_Note_DecProcessing  AS decnotes
  ON pmd.lrsn=decnotes.objectId
  --,n.objectId --lrsn or RevObjId
  --AND decnotes.noteText NOT LIKE '%DONE%'

LEFT JOIN CTE_Note_Status AS statusnotes
  ON pmd.lrsn=statusnotes.objectId
  And statusnotes.RowNum = 1
  --,n.objectId --lrsn or RevObjId
  --AND statusnotes.noteText NOT LIKE '%DONE%'
  
---------------------------------------
--Conditions
---------------------------------------
--Where pmd.AIN = '254940'
--Where pmd.Property_Class_Desc NOT LIKE '%70%'
---------------------------------------
--Order By
---------------------------------------
--ORDER BY pmd.Owner, ClassCD, pmd.PIN;

)

Select Distinct *
From CTE_PP_Query_20_32
Where Property_Class_Desc NOT LIKE '%70%'
ORDER BY Owner, Property_Class_Desc, PIN;