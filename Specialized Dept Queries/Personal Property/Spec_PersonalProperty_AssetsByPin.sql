

/*
AsTxDBProd
GRM_Main
See Notes Below
*/


WITH 
--codes_table required for Asset Category Name
CTE_CatDesc AS (
  SELECT 
  c.tbl_type_code AS [CodeType], 
  CAST(LEFT(c.tbl_element,2) AS INT) AS [Code#], 
  c.tbl_element_desc AS [CodeDescription]
  
  FROM codes_table AS c
  
  WHERE c.code_status= 'A' 
    AND c.tbl_type_code= 'impgroup'
    AND c.tbl_element LIKE '%P'
)


SELECT
    LTRIM(RTRIM(pm.pin)) AS [PIN_ref],
    LTRIM(RTRIM(pm.AIN)) AS [AIN_ref],
    LTRIM(RTRIM(pm.SitusCity)) AS [SitusCityGroup],
-- '' AS [Asset Information >>],
    -- Asset Details
    pp.mAssetCategory AS [Category#],
    cd.[CodeDescription] AS [Category Description],
    LEFT(cd.[CodeDescription],4) AS [Category Description Short],
    pp.mScheduleName AS [Schedule#],
    pp.mAcquisitionDate,
    pp.mAcquisitionValue,
    pp.mAppraisedValue,
    pp.mDescription,    
    pp.mNote,
    pp.mSerialNumber,
    pp.mMfg,

--Parcel ID Info
'' AS [Parcel Information >>],
    pp.mPropertyId AS [LRSN], -- mPropertyId is lrsn
    LTRIM(RTRIM(pm.pin)) AS [PIN],
    LTRIM(RTRIM(pm.AIN)) AS [AIN],
    LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
    LTRIM(RTRIM(pm.TAG)) AS [TAG],
    LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
    LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
    LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
    pm.AttentionLine,
    pm.MailingAddress,
    pm.AddlAddrLine,
    pm.MailingCity,
    pm.MailingState,
    pm.MailingZip,
    pm.MailingCountry
    
FROM
    TSBv_PARCELMASTER AS pm
JOIN
    tPPAsset AS pp ON pp.mPropertyId = pm.lrsn
      AND pp.mEffStatus = 'A'
      And pp.mbegTaxYear BETWEEN '202300000' AND '202399999'
      And pp.mendTaxYear BETWEEN '202300000' AND '202399999'
JOIN CTE_CatDesc AS cd ON pp.mAssetCategory=cd.[Code#]

WHERE
    pm.EffStatus = 'A'
    AND (LEFT(pm.ClassCD, 3) IN ('010', '020', '021', '022', '030', '032', '060', '070', '080', '090'))
ORDER BY
    [Owner],
    [SitusCityGroup],
    [AIN],
    pp.mAssetCategory,
    pp.mScheduleName,
    pp.mAcquisitionDate
    ;

/*



SELECT c.tbl_type_code AS CodeType, c.tbl_element AS Code#, c.tbl_element_desc AS CodeDescription
FROM codes_table AS c
WHERE code_status= 'A' AND tbl_type_code= 'impgroup'
ORDER BY CodeDescription

If Wanted
    -- Additional
    pp.mAppraiser,
    pp.mChangeTimeStamp,
    pp.mUserId,
    -- Join Details
    pp.mPropertyId,
    pp.mbegTaxYear,
    pp.mendTaxYear,
    pp.mEffStatus

-- This is the final value assigned by MPPV, after depreciation. 
-- The Appraised Value will initially pull by asset, creating duplicate results for most ID/lrsn's. 
-- To get the aggregate value for the year for a single account, must filter by year, active, and do some kind of agregation, 
like a sum and group by, possibly in a cte with your joins.


Select *
From tPPAsset AS pp
--ON pp.mPropertyId = pm.lrsn
  Where pp.mEffStatus = 'A'
  And pp.mbegTaxYear BETWEEN '202300000' AND '202399999'
  And pp.mendTaxYear BETWEEN '202300000' AND '202399999'



Select *

FROM
    TSBv_PARCELMASTER AS pm
WHERE
    pm.EffStatus = 'A'
    AND (LEFT(pm.ClassCD, 3) IN ('010', '020', '021', '022', '030', '032', '060', '070', '080', '090'))
    
    
    
    
SELECT
pp.mPropertyId AS [LRSN], -- mPropertyId is lrsn
--ParcelMaster
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
--Asset Details
pp.mAssetCategory, --(First drop down, Cat# that lives under Cat Desc (Ex: Misc =  68)
pp.mNote, --(Cat Desc)
pp.mScheduleName, --(Schedule, like 00,05,19)
pp.mAcquisitionDate, --(from annual declaration, then goes into MPPV)
pp.mAcquisitionValue, --(from annual declaration, then goes into MPPV)
pp.mDescription, --(Ex: MILK DISP)
pp.mAppraisedValue, -- This is the final value, see next note
pp.mOverrideValue, -- Rare, but MPPV values can have override
pp.mProrateValue, -- Rare, but MPPV values can prorate, usually because of a hyper special case, usually ordered from state or bocc
pp.mSerialNumber, -- Optional, can include serial num on asset
pp.mMfg, -- Optional, can include other details, like Manufacterer on asset
--Additional
pp.mAppraiser, -- Who changed value, human or system?
pp.mChangeTimeStamp, -- When was it changed (this is a date)
pp.mUserId, -- (This shows if individual or system change)
--Join Details
pp.mPropertyId, -- this is the lrsn, join to lrsn on Parcel Master
pp.mbegTaxYear, -- in year plus five formatt for some reason
pp.mendTaxYear, -- in year plus five formatt for some reason
pp.mEffStatus -- 'A' or 'I' Active,Inactive


FROM TSBv_PARCELMASTER AS pm 

JOIN tPPAsset AS pp ON pp.mPropertyId=pm.lrsn
      AND pp.mEffStatus='A'
      AND pp.mbegTaxYear ='202300000'
      AND pp.mendTaxYear = '202399999'
--Change Year each year 202300000 becomes 20240000, etc.

WHERE pm.EffStatus= 'A'
  AND (pm.ClassCD LIKE '10%'
  	OR pm.ClassCD LIKE '20%'
  	OR pm.ClassCD LIKE '21%'
  	OR pm.ClassCD LIKE '22%'
  	OR pm.ClassCD LIKE '30%'
  	OR pm.ClassCD LIKE '32%'
  	OR pm.ClassCD LIKE '60%'
  	OR pm.ClassCD LIKE '70%'
  	OR pm.ClassCD LIKE '80%'
  	OR pm.ClassCD LIKE '90%'
  	)

ORDER BY [Owner], pp.mAssetCategory, pp.mScheduleName;
    
    
*/