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
, CAST(pm.ClassCD AS INT) AS ClassCD
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
pp.mPropertyId AS lrsn
,pp.mAcquisitionValue AS mAcquisitionValue
,CASE 
--mOverrideReason = 1 --This means the checkmark is checked
--mOverrideReason = 0 --This means the checkmark is NOT checked  
    WHEN pp.mOverrideReason = 0 THEN mAppraisedValue
    WHEN pp.mOverrideReason = 1 THEN mOverrideValue
    ELSE pp.mAppraisedValue
  END AS mAppraisedValuewOverrides
,pp.mAppraisedValue
,pp.mOverrideValue
,pp.mOverrideReason
,pp.mAssetCategory
,pp.mScheduleName
,LEFT(pp.mbegTaxYear,4) AS mbegTaxYear
,pp.mPropertyId
,pp.mAssetId
,pp.mEffStatus
,pp.mDescription
,CAST(pp.mAcquisitionDate AS DATE) AS mAcquisitionDate
,pp.mNote
,pp.mSerialNumber
,pp.mMfg
,pp.mModel
,pp.mBody

FROM tPPAsset AS pp
WHERE mEffStatus = 'A' 
--AND mPropertyId = 510587 -- Use as Test
And mbegTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo
And mendTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo
),

CTE_MPPV_Sum AS (
Select Distinct
wtf.lrsn
,SUM(wtf.mAppraisedValuewOverrides) AS SUM_By_AIN
From CTE_MPPV AS wtf
Group By wtf.lrsn
),

---------------------------------------
--Begins Primary Query
---------------------------------------

--------------------------
-- SELECT START HERE
-------------------------

CTE_Assets AS (
SELECT DISTINCT
--pmd.lrsn
--,SUM(mppv.mAppraisedValuewOverrides) AS TEST
mppv.mbegTaxYear
,mppv.mAssetCategory
,mppv.mScheduleName

,mppv.mAcquisitionDate
,mppv.mAcquisitionValue
,mppv.mAppraisedValuewOverrides
,wtf.SUM_By_AIN
,mppv.mAppraisedValue
,mppv.mOverrideValue
,mppv.mOverrideReason
,mppv.mDescription
,mppv.mNote
,mppv.mSerialNumber
,mppv.mMfg
,mppv.mModel
,mppv.mBody
,mppv.mAssetId -- Requires so you don't filter out duplicate descriptions that are legit doubles
,mppv.mEffStatus
,pmd.ClassCD
,pmd.Property_Class_Desc
,pmd.Owner
,pmd.SitusAddress
,pmd.lrsn
,pmd.AIN
,pmd.PIN
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

Left Join CTE_MPPV_Sum AS wtf
  On pmd.lrsn = wtf.lrsn

---------------------------------------
--Conditions
---------------------------------------
Where pmd.ClassCD <> 70
--And pmd.lrsn = 511387
And mppv.mScheduleName = '08'
--Group By pmd.lrsn

---------------------------------------
--Order By
---------------------------------------
--ORDER BY pmd.Owner,ClassCD,pmd.PIN,mppv.mAssetCategory,mppv.mScheduleName;

)


--Audit for Schedule 8

Select 
Owner,
AIN,
PIN,
SUM(mAcquisitionValue) AS SUM_AcquisitionValue,
SUM(mAppraisedValuewOverrides) AS SUM_AppraisedValue
From CTE_Assets
Group By Owner,AIN,PIN
Order by Owner;
