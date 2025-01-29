
DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @CurrentDate DATE = GETDATE();

SELECT 
--Property Data
TRIM(vwb.ParcelNo) AS [PIN],
UPPER(TRIM(vwb.BaseNo)) AS [REFERENCE_#],
bcfval.cMoney AS [ProjectCost],
bcfsf.cDbl AS [ProjectSF],
CAST(b.IssueDt AS DATE) AS IssueDt,
CASE
    WHEN GETDATE() < DATEFROMPARTS(YEAR(GETDATE()), 10, 1)
        THEN DATEFROMPARTS(YEAR(GETDATE()), 10, 1)
    ELSE DATEFROMPARTS(YEAR(GETDATE()) + 1, 10, 1)
END AS CallBack,

'' AS inactivedate,
CASE
--'' AS cert_for_occ,
  WHEN CAST(b.FinalDt AS DATE) IS NULL THEN NULL
  ELSE CAST(b.FinalDt AS DATE)
END AS cert_for_occ,

--TRIM(vwb.FullDescription) AS [PermitDesc],
  CASE 
    WHEN vwb.RcType = 'COMMERCIAL BUILDING' AND CHARINDEX('TOWER', vwb.RcSubType) > 0 
      THEN CONCAT('CTWR_REVIEW',' - ',UPPER(TRIM(vwb.Address1)),' - ',UPPER(TRIM(vwb.FullDescription)))

    WHEN vwb.RcSubType = 'NEW ONE FAMILY DWELLING' THEN CONCAT(UPPER(TRIM(vwb.Address1)),' - NEW SFR - ',UPPER(TRIM(vwb.FullDescription)))

    WHEN UPPER(TRIM(vwb.FullDescription)) IS NULL THEN CONCAT(UPPER(TRIM(vwb.Address1)),' - ',vwb.RcSubType,' - ',vwb.RcType,' - ',(TRIM(vwb.FullDescription)))

    ELSE CONCAT(UPPER(TRIM(vwb.Address1)),' - ',UPPER(TRIM(vwb.FullDescription)),' - ',vwb.RcSubType,' - ',vwb.RcType)
  END AS PermitDesc,

--'REPLACE_WITH_KEY_#' AS permit_type,
CASE
    -- Specific RcType matches
    WHEN vwb.RcType = 'MECHANICAL' THEN 9
    --WHEN vwb.RcType = 'DEMOLITION' THEN 6
    WHEN CHARINDEX('REROOF', UPPER(TRIM(vwb.FullDescription))) > 0 THEN 9
    WHEN CHARINDEX('RE-ROOF', UPPER(TRIM(vwb.FullDescription))) > 0 THEN 9
    WHEN CHARINDEX('RE ROOF', UPPER(TRIM(vwb.FullDescription))) > 0 THEN 9
    WHEN CHARINDEX('R & R ENTIRE ROOF', UPPER(TRIM(vwb.FullDescription))) > 0 THEN 9
    WHEN CHARINDEX('R & R ROOF', UPPER(TRIM(vwb.FullDescription))) > 0 THEN 9
    WHEN CHARINDEX('REMOVE AND REPLACE EXISTING ROOF', UPPER(TRIM(vwb.FullDescription))) > 0 THEN 9
    WHEN CHARINDEX('SHINGLES', UPPER(TRIM(vwb.FullDescription))) > 0 THEN 9

    WHEN vwb.RcType = 'MANUFACTURED HOME' THEN 99
    WHEN vwb.RcType = 'SWIMMING POOL' THEN 3
    WHEN vwb.RcType = 'FLOODPLAIN DEVELOPMENT PERMIT' THEN 14
    WHEN vwb.RcType = 'STORM REPAIR' THEN 3

    WHEN (CHARINDEX('SFD', UPPER(TRIM(vwb.FullDescription))) > 0 OR
        CHARINDEX('SFR', UPPER(TRIM(vwb.FullDescription))) > 0 )
    AND (CHARINDEX('EXISTING', UPPER(TRIM(vwb.FullDescription))) = 0 AND
        CHARINDEX('DEMO', UPPER(TRIM(vwb.FullDescription))) = 0)
      THEN 1

    WHEN (vwb.RcType = 'DEMOLITION' OR
         CHARINDEX('DEMO', UPPER(TRIM(vwb.FullDescription))) > 0 OR
         CHARINDEX('FIRE DAMAGE', UPPER(TRIM(vwb.FullDescription))) > 0 OR
         CHARINDEX('FIRE REPAIR', UPPER(TRIM(vwb.FullDescription))) > 0 OR
      vwb.RcType = 'DEMOLITION' )
    AND (CHARINDEX('PARTIAL', UPPER(TRIM(vwb.FullDescription))) > 0 OR
        CHARINDEX('INTERNAL', UPPER(TRIM(vwb.FullDescription))) > 0)
      THEN 3

    WHEN (vwb.RcType = 'DEMOLITION' OR
         CHARINDEX('DEMO', UPPER(TRIM(vwb.FullDescription))) > 0 OR
         CHARINDEX('FIRE DAMAGE', UPPER(TRIM(vwb.FullDescription))) > 0 OR
         CHARINDEX('FIRE REPAIR', UPPER(TRIM(vwb.FullDescription))) > 0 OR
      vwb.RcType = 'DEMOLITION' )
    AND (CHARINDEX('PARTIAL', UPPER(TRIM(vwb.FullDescription))) = 0 OR
        CHARINDEX('INTERNAL', UPPER(TRIM(vwb.FullDescription))) = 0)
      THEN 6


    -- Grouping for RESIDENTIAL BUILDING
    WHEN vwb.RcType = 'RESIDENTIAL BUILDING' AND (
        CHARINDEX('ACCESSORY LIVING UNIT', vwb.RcSubType) > 0 OR
        CHARINDEX('DWELLING', vwb.RcSubType) > 0 OR
        CHARINDEX('TEMPORARY HARDSHIP UNIT', vwb.RcSubType) > 0 OR
        CHARINDEX('NEW ONE FAMILY DWELLING', vwb.RcSubType) > 0 
    ) THEN 1

    WHEN vwb.RcType = 'RESIDENTIAL BUILDING' AND (
        CHARINDEX('ACCESSORY STRUCTURE', vwb.RcSubType) > 0 OR
        CHARINDEX('AG EXEMPT', vwb.RcSubType) > 0 OR
        CHARINDEX('HANGAR', vwb.RcSubType) > 0
    ) THEN 4

    WHEN vwb.RcType = 'RESIDENTIAL BUILDING' AND (
        CHARINDEX('ADDITION/ALTERATION', vwb.RcSubType) > 0 OR
        CHARINDEX('DECK/PORCH', vwb.RcSubType) > 0 OR
        CHARINDEX('BUILDING EXTERIOR', vwb.RcSubType) > 0
    ) THEN 3

    WHEN vwb.RcType = 'RESIDENTIAL BUILDING' AND (
        CHARINDEX('TEMPORARY', vwb.RcSubType) > 0  OR
        CHARINDEX('RESIDENTIAL TOWER', vwb.RcSubType) > 0 
    ) THEN 5

    -- Grouping for COMMERCIAL BUILDING
    WHEN vwb.RcType = 'COMMERCIAL BUILDING' AND (
        CHARINDEX('NEW', vwb.RcSubType) > 0 OR
        CHARINDEX('HANGAR', vwb.RcSubType) > 0 OR
        CHARINDEX('STRUCTURE', vwb.RcSubType) > 0 OR
        CHARINDEX('MISC', vwb.RcSubType) > 0
    ) THEN 2

    WHEN vwb.RcType = 'COMMERCIAL BUILDING' AND (
        CHARINDEX('ADDITION/ALTERATION', vwb.RcSubType) > 0 OR
        CHARINDEX('CHANGE OF USE', vwb.RcSubType) > 0 OR
        CHARINDEX('TENANT IMPROVEMENT', vwb.RcSubType) > 0
    ) THEN 3

    WHEN vwb.RcType = 'COMMERCIAL BUILDING' AND CHARINDEX('TOWER', vwb.RcSubType) > 0 THEN 15
    WHEN vwb.RcType = 'COMMERCIAL BUILDING' AND CHARINDEX('BUILDING EXTERIOR', vwb.RcSubType) > 0 THEN 9

    -- Other conditions using RcType or RcSubType
    WHEN CHARINDEX('TRAM', vwb.RcType) > 0 THEN 14
    WHEN CHARINDEX('RETAINING WALL', vwb.RcType) > 0 THEN 9
    WHEN CHARINDEX('ADDITION/ALTERATION', vwb.RcSubType) > 0 THEN 3
    WHEN CHARINDEX('DECK/PORCH', vwb.RcSubType) > 0 THEN 3
    WHEN CHARINDEX('GARAGE/CARPORT', vwb.RcSubType) > 0 THEN 4
    WHEN CHARINDEX('HANGAR', vwb.RcSubType) > 0 THEN 4


    ELSE 0
END AS PERMITYPE,

'iMS' AS permit_source,
'' AS phone_number,
'' AS permit_char3,
'A' AS status_code,
'' AS permit_char20b,
'0' AS permit_int2,
'0' AS permit_int3,
'0' AS permit_int4,
'' AS permservice,
'' AS permit_fee,


'>' AS AdditionalData,
TRIM(vwb.RcType) AS [RcType],
TRIM(vwb.RcSubtype) AS [RcSubType],
TRIM(vwb.AIN) AS [AIN],
UPPER(TRIM(vwb.Address1)) AS [Address1],
TRIM(vwb.Address2) AS [Address2],
TRIM(vwb.City) AS [City],
TRIM(vwb.Variant) AS [Variant],
TRIM(vwb.Milestone) AS [ViewMilestone],
b.MilestoneID,
TRIM(b.Milestone) AS [BaseMilestone],
CAST(b.ExpireDt AS DATE) AS ExpireDt,
CAST(b.FinalDt AS DATE) AS FinalDt,
CAST(b.IssueDt AS DATE) AS UpdateDt,
CAST(@CurrentDate AS DATE) AS DateOfDataPull,

b.Progress,
--Employee?
vwb.FullName,
vwb.CreateBy,
--Owner Contact
vwb.Owner,
vwb.Applicant,
vwb.Contractor,
--Lat-Long
vwb.Longitude,
vwb.Latitude,
Concat(b.lat, ',', b.lon) As GoogleMapsFormatedLatLongs


FROM Vw_Base_KC AS vwb 
JOIN Base AS b ON vwb.ID=b.ID
  AND b.IssueDt > DATEFROMPARTS(YEAR(GETDATE()) - 3, 1, 1)

LEFT JOIN vw_BaseCustomFields AS bcfval ON vwb.ID=bcfval.BaseID AND bcfval.fieldname='PROJECT VALUATION'
LEFT JOIN vw_BaseCustomFields AS bcfsf ON vwb.ID=bcfsf.BaseID AND bcfsf.fieldname='PROJECT SQ FT'


WHERE (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')

AND b.IssueDt > DATEFROMPARTS(YEAR(GETDATE()) - 3, 1, 1)

AND vwb.Milestone <> 'CANCELLED'
AND vwb.Milestone <> 'WITHDRAWN'
AND vwb.BaseNo NOT LIKE 'SDP%'
AND vwb.FullDescription NOT LIKE '%LINE%'
AND vwb.RcType IS NOT NULL
AND vwb.RcType <> 'SIGN'
AND vwb.RcType <> 'SITE DISTURBANCE'
AND vwb.RcType <> 'FENCE'
AND vwb.RcType <> 'APPEAL'
AND vwb.RcType <> 'COMPREHENSIVE%'
AND vwb.RcType <> 'FLOOD DEV%'
AND vwb.RcType <> 'OFFICE FEES'
AND vwb.RcSubtype <> 'CHANGE OF USE'
AND vwb.RcType <> 'LOCATION'
AND vwb.RcType <> 'RETAINING WALL'


ORDER BY [IssueDt] DESC, [City], [RcType];

-- !preview conn=conn

/*
--GRM Database
AsTxDBProd
GRM_Main

--iMS Database, County Permits
Permits-Prod
iMS

--In iMS, their version of a codes_table is called: vw_BaseCustomFields
PROJECT VALUATION
PROJECT SQ FT
*/
