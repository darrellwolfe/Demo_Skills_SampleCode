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
DECLARE @Year INT = 2024; -- Input year

-- Use CONCAT to create date strings for the start and end of the year
DECLARE @LastYearCertFrom INT = CONCAT(@Year - 1, '0101');
DECLARE @LastYearCertTo INT = CONCAT(@Year - 1, '1231');

-- Date and time for January 1 of the input year
DECLARE @Jan1ThisYear1 DATETIME = CONCAT(@Year, '-01-01 00:00:00');
DECLARE @Jan1ThisYear2 DATETIME = CONCAT(@Year, '-01-01 23:59:59');

-- Use CONCAT to create certification date strings for the current year
DECLARE @ThisYearCertFrom INT = CONCAT(@Year, '0101');
DECLARE @ThisYearCertTo INT = CONCAT(@Year, '1231');

-- Use CONCAT for creating range values for MPPV
DECLARE @ThisYearMPPVFrom INT = CONCAT(@Year, '00000');
DECLARE @ThisYearMPPVTo INT = CONCAT(@Year, '99999');

-- Declare cadaster year as the input year
DECLARE @CadasterYear INT = @Year;

DECLARE @NoteYear VARCHAR(10) = CONCAT('%',@Year,'%');

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
  
  Where pm.EffStatus = 'A'
  And pm.ClassCD IN ('020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090')
  AND pm.PIN NOT LIKE 'U%'
  AND pm.PIN NOT LIKE 'G%'
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
--noteText LIKE @NoteYear
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
AND YEAR(createTimestamp) = @Year
--noteText LIKE @NoteYear
Group By n.objectId
),





--Looking for the Personal Property 63-602KK $250,000 exemption from Aumentum Modifiers, paying special attention to the shared exemptions
CTE_63602KK AS (
SELECT
lrsn,
TRIM(ModifierDescr) AS ModifierDescr,
ModifierPercent,
CAST(OverrideAmount AS BIGINT) AS PPExemption602KK

FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%602KK%'
AND PINStatus='A'
),

--Looking to ensure no PP accounts have a TAG in the 301 or 345 Taxing Districts
CTE_TaxAuth301345 ([TaxAuthTAG], [301_345]) AS (
SELECT
    TRIM(TagDescr),
    TRIM(TaxAuthorityDescr)

FROM KCv_AumentumEasy_TagTaxAuthorities
WHERE (TaxAuthorityDescr LIKE '%345%' 
OR TaxAuthorityDescr LIKE '%301%')
),


--Looking to see what PP accounts have a URD Modifier, to be compared with URD in the legal descriptions
CTE_ModURD (lrsn, [URD], [URD%], [URD$]) AS (
SELECT
    lrsn,
    TRIM(ModifierDescr),
    ModifierPercent,
    OverrideAmount
FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%URD%'
AND PINStatus='A'
),


--2022 Looking for Cert and Assessed Values (should match) for prior year(s) and current year. However, current year will not show until after Price & Post.
CTE_CertValuesLastYear (lrsn, PPCertValueLastYear, LastUpdated, RowNumber) AS (
  SELECT DISTINCT
      lrsn,
      SUM(imp_val) AS [CertValue],
      MAX(last_update) AS [LastUpdated],
ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY last_update DESC) AS RowNumber

  FROM valuation
  WHERE status='A'
  AND property_class IN ('10','20','21','22','30','32','60','70','80','90')
  AND eff_year BETWEEN @LastYearCertFrom AND @LastYearCertTo
--Change year for new Cert Values
  GROUP BY lrsn,last_update
),

--2023 Looking for Cert and Assessed Values (should match) for prior year(s) and current year. However, current year will not show until after Price & Post.
CTE_CertValuesThisYear (lrsn, PPCertValueThisYear, LastUpdated, RowNumber) AS (
  SELECT DISTINCT
      lrsn,
      SUM(imp_val) AS [CertValue],
      MAX(last_update) AS [LastUpdated],
ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY last_update DESC) AS RowNumber

  FROM valuation
  WHERE status='A'
  AND property_class IN ('10','20','21','22','30','32','60','70','80','90')
  AND eff_year BETWEEN @ThisYearCertFrom AND @ThisYearCertTo
--Change year for new Cert Values
  GROUP BY lrsn,last_update
)

---------------------------------------
--Begins Primary Query
---------------------------------------

--------------------------
-- SELECT START HERE
-------------------------

SELECT DISTINCT
pmd.lrsn
,pmd.AIN
,pmd.PIN
,CAST(pmd.ClassCD AS INT) AS ClassCD
,pmd.Property_Class_Desc

,mppv.mAcquisitionValue
,mppv.mAppraisedValue
,kk602.PPExemption602KK
,(mppv.mAppraisedValue-kk602.PPExemption602KK) AS NetTaxable

,pmd.Owner
,pmd.SitusAddress
,pmd.SitusCity
--Other Audits
,'Check>' AS AuditsToRight
--Notes
,decnotes.noteText AS DecNotes
,statusnotes.createTimestamp
,statusnotes.UserName
,statusnotes.noteText AS StatusNotes
,ta.[301_345]--Should be zero at all times, if not, change the tag to a tag ending in 500
,mURD.[URD%]
,mURD.[URD$]
,mURD.[URD]

,pmd.SitusState
,pmd.SitusZip
,pmd.Attn
,pmd.MailingAddress
,pmd.MailingCSZ
,pmd.TAG
,pmd.LegalDescription



--------------------------
-- FROM START HERE
-------------------------

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_MPPV AS mppv 
  ON pmd.lrsn=mppv.lrsn

LEFT JOIN CTE_63602KK AS kk602
  ON pmd.lrsn=kk602.lrsn

--JOIN vs LEFT JOIN shows only those in 345 and 301
JOIN CTE_TaxAuth301345 AS ta 
  ON pmd.TAG=ta.TaxAuthTAG

LEFT JOIN CTE_CertValuesThisYear AS cvc --current
  ON pmd.lrsn=cvc.lrsn
  AND cvc.RowNumber=1
  --cvc.PPCertValueThisYear
LEFT JOIN CTE_CertValuesLastYear AS cvp -- past
  ON pmd.lrsn=cvp.lrsn
  AND cvp.RowNumber=1
  --cvp.PPCertValueLastYear

LEFT JOIN CTE_ModURD AS mURD 
  ON pmd.lrsn=mURD.lrsn

LEFT JOIN CTE_Note_DecProcessing  AS decnotes
  ON pmd.lrsn=decnotes.objectId
  --,n.objectId --lrsn or RevObjId
  --AND decnotes.noteText NOT LIKE '%DONE%'

LEFT JOIN CTE_Note_Status AS statusnotes
  ON pmd.lrsn=statusnotes.objectId
  --,n.objectId --lrsn or RevObjId
  --AND statusnotes.noteText NOT LIKE '%DONE%'
  
---------------------------------------
--Conditions
---------------------------------------
--JOIN vs LEFT JOIN shows only those in 345 and 301
--JOIN CTE_TaxAuth301345 AS ta 

---------------------------------------
--Order By
---------------------------------------
ORDER BY 
pmd.Owner,
ClassCD,
pmd.PIN;



