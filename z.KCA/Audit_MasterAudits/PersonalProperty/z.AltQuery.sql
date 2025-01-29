-- !preview conn=conn


/*
AsTxDBProd
GRM_Main

**PERSONAL PROPERTY QUERY REQUIRES YEARLY UPDATES IN SEVERAL TABLES, REVIEW ALL YEARS
2023 TO 2024, ETC.

*/


--Begins CTE Statements chained within a single WITH statement

--Only change year, not structure
--Change first four digits to last year for both
DECLARE @LastYearCertFrom INT = '20220101';
DECLARE @LastYearCertTo INT = '20221231';

--Change first four digits to this year for both
DECLARE @Jan1ThisYear1 DATETIME;
SET @Jan1ThisYear1 = '2023-01-01 00:00:00';

DECLARE @Jan1ThisYear2 DATETIME;
SET @Jan1ThisYear2 = '2023-01-01 23:59:59';



DECLARE @ThisYearCertFrom INT = '20230101';
DECLARE @ThisYearCertTo INT = '20231231';

DECLARE @ThisYearMPPVFrom INT = '202300000';
DECLARE @ThisYearMPPVTo INT = '202399999';

DECLARE @CadasterYear INT = '2023';



WITH

CTE_PCC_to_System AS (
Select
tbl_type_code AS PCC
,tbl_element AS ClassCD
,tbl_element_desc AS ClassCD_Desc
,CodesToSysType AS ClassCD_SystemType

From codes_table
Where tbl_type_code LIKE '%PCC%'
And code_status = 'A'

--Order by tbl_element_desc
),

CTE_GetRevObjByEffDate_Jan1 AS (
SELECT
grobed.Id -- Id is RevObjId is lrsn
,grobed.BegEffDate
,grobed.TranId
,grobed.GeoCd
,grobed.ClassCd
--,grobed.ClassCd AS ClassCd_Today
,sys.ClassCD AS ClassCd_Jan1
,sys.ClassCD_Desc AS ClassCdDesc_Jan1


,TRIM(grobed.PIN) AS PIN
,TRIM(grobed.UnformattedPIN) AS UnformattedPIN
,TRIM(grobed.AIN) AS AIN
,ROW_NUMBER() OVER (PARTITION BY grobed.Id ORDER BY grobed.BegEffDate DESC) AS RowNumber

From RevObj AS grobed
LEFT JOIN CTE_PCC_to_System AS sys
  ON grobed.ClassCd = sys.ClassCD_SystemType


Where BegEffDate BETWEEN @Jan1ThisYear1 AND @Jan1ThisYear2
--Where BegEffDate = @Today
),


CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
  Select Distinct
  pm.lrsn
, CASE
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
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Desc
, CASE 
    WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
    WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
    WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
    WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
    WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
    WHEN pm.ClassCD = '667' THEN 'Operating_Property'
    WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
    WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
    ELSE 'Unasigned_or_OldInactiveParcel'
  END AS Property_Type_Class
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
    --AND pm.ClassCD NOT LIKE '010%'
    --AND pm.ClassCD NOT LIKE '020%'
    --AND pm.ClassCD NOT LIKE '021%'
    --AND pm.ClassCD NOT LIKE '022%'
    --AND pm.ClassCD NOT LIKE '030%'
    --AND pm.ClassCD NOT LIKE '031%'
    --AND pm.ClassCD NOT LIKE '032%'
--    AND pm.ClassCD NOT LIKE '060%'
--    AND pm.ClassCD NOT LIKE '070%'
--    AND pm.ClassCD NOT LIKE '090%'
      
  Group By
  pm.lrsn
, pm.pin
, pm.PINforGIS
, pm.AIN
, pm.ClassCD
, pm.PropClassDescr
, pm.neighborhood
, pm.NeighborHoodName
, pm.TAG
, pm.AttentionLine
, pm.MailingAddress
, pm.MailingCityStZip
, pm.DisplayDescr
, pm.DisplayName
, pm.SitusAddress
, pm.SitusCity
, pm.SitusState
, pm.SitusZip
, pm.CountyNumber
, pm.LegalAcres
, pm.Improvement_Status

--Order By District,GEO;
),

--Looking for Aquisition Value and Appraised Value from MPPV, aggragated by lrsn (mPropertyId); rather than by individual asset.
CTE_MPPV AS (
--DECLARE @ThisYearMPPVFrom INT = '202300000';
--DECLARE @ThisYearMPPVTo INT = '202399999';

SELECT 
mPropertyId AS lrsn
--,mAssetCategory
--,mScheduleName

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

/*
GROUP BY 
mAssetCategory
,mScheduleName

ORDER BY
mAssetCategory
,mScheduleName
*/
),

--Looking for the Personal Property 63-602KK $250,000 exemption from Aumentum Modifiers, paying special attention to the shared exemptions
    CTE_63602KK (lrsn,[63-602KK], [63-602KK%],[63-602KK$]) AS (
    SELECT
        lrsn,
        ModifierDescr,
        ModifierPercent,
        CAST(OverrideAmount AS BIGINT) AS OverrideAmount
     FROM TSBv_MODIFIERS
    WHERE ModifierStatus='A'
    AND ModifierDescr LIKE '%602KK%'
    AND PINStatus='A'
)


---------------------------------------
--Begins Primary Query
---------------------------------------

--------------------------
-- SELECT START HERE
-------------------------

SELECT DISTINCT
pmd.Property_Type_Class
,pmd.lrsn
,pmd.AIN
,pmd.PIN
,CAST(pmd.ClassCD AS INT) AS ClassCD
,pmd.Property_Class_Desc
,mppv.mAcquisitionValue
,mppv.mAppraisedValue
,kk.[63-602KK$]
,(mppv.mAppraisedValue-kk.[63-602KK$]) AS NetTaxable
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

LEFT JOIN CTE_MPPV AS mppv ON pmd.lrsn=mppv.lrsn

LEFT JOIN CTE_63602KK AS kk ON pmd.lrsn=kk.lrsn


---------------------------------------
--Conditions
---------------------------------------
WHERE pmd.ClassCD IN ('020', '021', '022', '030', '031', '032')
--, '040', '050', '060', '070', '080', '090')
--WHERE pmd.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090')

--AND pmd.PIN = 'EESH00014001' -- Use PINs as TEST
---------------------------------------
--Order By
---------------------------------------
ORDER BY 
pmd.Owner,
ClassCD,
pmd.PIN;


/*

--c19.PPCertValue2019,
--c20.PPCertValue2020,
--c21.PPCertValue2021,

**This did not work because by including the date it seperated values by change date/times, 
which automatically considers individual asset changes, it has to be total values for active assets. 
--Looking for Aquisition Value and Appraised Value from MPPV, aggragated by lrsn (mPropertyId); rather than by individual asset.
CTE_MPPV (lrsn,[MostRecentAprslDate],[AcquisitionValue_2023],[AppraisedValue_2023],RowNumber) AS (
    SELECT
        mPropertyId,
        --mChangeTimeStamp,
        --SUM(mAcquisitionValue),
        SUM(mAppraisedValue)
--ROW_NUMBER() OVER (PARTITION BY mPropertyId ORDER BY mChangeTimeStamp DESC) AS RowNumber

    FROM tPPAsset
    WHERE mEffStatus = 'A' 
      And mbegTaxYear BETWEEN '202300000' AND '202399999'
      And mendTaxYear BETWEEN '202300000' AND '202399999'
--Change each year for current values (after MPPV has been rolled over
    GROUP BY mPropertyId




*/