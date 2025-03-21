

SELECT DISTINCT
  TRIM(vwb.RcType) AS [RcType]
,  TRIM(vwb.RcSubtype) AS [RcSubType]
--,  TRIM(vwb.FullDescription) AS [PermitDesc]
,UPPER(TRIM(vwb.FullDescription)) AS PermitDescAlone

,CASE
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
END AS PERMITYPE

, UPPER(TRIM(vwb.Address1)) AS [SitusAddress]

,CASE 
  WHEN vwb.RcType = 'COMMERCIAL BUILDING' AND CHARINDEX('TOWER', vwb.RcSubType) > 0 
    THEN CONCAT('CTWR_REVIEW',' - ',UPPER(TRIM(vwb.Address1)),' - ',UPPER(TRIM(vwb.FullDescription)))

  WHEN vwb.RcSubType = 'NEW ONE FAMILY DWELLING' THEN CONCAT(UPPER(TRIM(vwb.Address1)),' - NEW SFR - ',UPPER(TRIM(vwb.FullDescription)))

  WHEN UPPER(TRIM(vwb.FullDescription)) IS NULL THEN CONCAT(UPPER(TRIM(vwb.Address1)),' - ',vwb.RcSubType,' - ',vwb.RcType,' - ',(TRIM(vwb.FullDescription)))

    ELSE CONCAT(UPPER(TRIM(vwb.Address1)),' - ',UPPER(TRIM(vwb.FullDescription)),' - ',vwb.RcSubType,' - ',vwb.RcType)
  END AS PermitDesc

FROM Vw_Base_KC AS vwb 
JOIN Base AS b ON vwb.ID=b.ID
LEFT JOIN vw_BaseCustomFields AS bcfval ON vwb.ID=bcfval.BaseID AND bcfval.fieldname='PROJECT VALUATION'
LEFT JOIN vw_BaseCustomFields AS bcfsf ON vwb.ID=bcfsf.BaseID AND bcfsf.fieldname='PROJECT SQ FT'


WHERE vwb.RcType IS NOT NULL
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



AND vwb.Milestone <> 'CANCELLED'
AND vwb.Milestone <> 'WITHDRAWN'
AND vwb.BaseNo NOT LIKE 'SDP%'
AND UPPER(TRIM(vwb.FullDescription)) NOT LIKE '%LINE%'
--AND (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')
AND b.IssueDt > DATEFROMPARTS(YEAR(GETDATE()) - 3, 1, 1)

ORDER BY PERMITYPE, RcType, RcSubtype;





/*

--GRM Database
AsTxDBProd
GRM_Main

--iMS Database, County Permits
Permits-Prod
iMS

--In iMS, their version of a codes_table is called: vw_BaseCustomFields
--PROJECT VALUATION
--PROJECT SQ FT
*/