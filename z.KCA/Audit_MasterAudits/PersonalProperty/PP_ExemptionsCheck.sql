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


CTE_PPQAQC AS (
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


  
---------------------------------------
--Conditions
---------------------------------------
)


Select
ppq.Owner
--,ppq.AIN
,SUM(ppq.mAcquisitionValue) AS Total_mAcquisitionValue
,SUM(ppq.mAppraisedValue) AS Total_mAppraisedValue
,SUM(ppq.PPExemption602KK) AS Total_PPExemption602KK
,(SUM(ppq.mAppraisedValue) - SUM(ppq.PPExemption602KK)) AS TotalNetTaxable

From CTE_PPQAQC AS ppq
WHERE ppq.Property_Class_Desc NOT LIKE '%70%'
AND 
--AND ppq.Owner LIKE 'BRATTI%'
--Where 

GROUP BY ppq.Owner
---------------------------------------
--Order By
---------------------------------------



