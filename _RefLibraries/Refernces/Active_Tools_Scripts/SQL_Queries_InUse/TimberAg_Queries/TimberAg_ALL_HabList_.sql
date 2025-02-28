-- !preview conn=con

/*
AsTxDBProd
GRM_Main

Multiple Queries, check them all before selecting

Timber AG Only:   
AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')


--Codes impgroup (aka Group Codes, aka group_code)
Select
tbl_element,
tbl_element_desc
From codes_table
Where code_status='A'
AND tbl_type_code IN ('impgroup')

*/


------------------------------
--Habitat Query
------------------------------

SELECT DISTINCT
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
--Allocations
a.group_code AS [GroupCode],
--Memo
LTRIM(RTRIM(m.memo_text)) AS [Memos],
--Acres
parcel.Acres,
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity]

FROM KCv_PARCELMASTER1 AS parcel
--allocations
JOIN allocations AS a ON parcel.lrsn=a.lrsn 
  AND a.status='A' 
  AND a.group_code IN ('06','07') 
  AND a.last_update > '2023-01-01'
--memos
LEFT JOIN memos AS m ON parcel.lrsn=m.lrsn 
  AND m.memo_id='T' 
  AND m.memo_line_number > 1
  AND (m.memo_text LIKE 'EAR%H'
      OR m.memo_text LIKE 'GKH%H'
      OR m.memo_text LIKE 'CS%H'
      )

WHERE parcel.EffStatus= 'A'
AND parcel.Acres >= '5'
-- The following is a list of large companies that Timber doesn't bother
AND (parcel.DisplayName NOT LIKE 'STIMSON LUMBER CO%'
AND parcel.DisplayName NOT LIKE 'MOLPUS%'
AND parcel.DisplayName NOT LIKE 'JACKSON TIMB%'
AND parcel.DisplayName NOT LIKE 'NANDDIC CRYSTAL%'
AND parcel.DisplayName NOT LIKE 'JAMESTOWN FANDEST%'
AND parcel.DisplayName NOT LIKE 'CARMONA TRISTAR%'
AND parcel.DisplayName NOT LIKE 'HANCOCK TIMER%'
AND parcel.DisplayName NOT LIKE 'JOHN HANCOCK LIFE%'
AND parcel.DisplayName NOT LIKE 'BOSTON TIMBER%'
AND parcel.DisplayName NOT LIKE 'SYSTEM GLOBAL TIMB%'
AND parcel.DisplayName NOT LIKE 'GOLDEN POND TIMB%'
AND parcel.DisplayName NOT LIKE 'MANUELIFE%'
AND parcel.DisplayName NOT LIKE 'BENNETT LUMBER%'
AND parcel.DisplayName NOT LIKE 'BUELL BROTHERS%'
AND parcel.DisplayName NOT LIKE 'F & G TIMBER%'
AND parcel.DisplayName NOT LIKE 'POTLATCH%'
AND parcel.DisplayName NOT LIKE 'IFG%'
AND parcel.DisplayName NOT LIKE 'INLAND EMPIRE%'
AND parcel.DisplayName NOT LIKE 'INLAND FANDEST%'
AND parcel.DisplayName NOT LIKE 'JT HOLDINGS%'
AND parcel.DisplayName NOT LIKE 'KOOTENAI LAND%'
AND parcel.DisplayName NOT LIKE 'KOOTENAI PROPERTIES%'
AND parcel.DisplayName NOT LIKE 'KROETCH%'
AND parcel.DisplayName NOT LIKE 'MAGNUSON PROP%'
AND parcel.DisplayName NOT LIKE 'MAGNUSON MICA BAY%'
AND parcel.DisplayName NOT LIKE 'MICA BAY LAND DEV%'
AND parcel.DisplayName NOT LIKE 'PRIEST RIVER LAND%'
AND parcel.DisplayName NOT LIKE 'RILEY CREEK LUMB%')


GROUP BY
parcel.lrsn,
parcel.ain,
parcel.pin,
parcel.neighborhood,
a.group_code,
m.memo_text,
parcel.Acres,
parcel.ClassCD,
parcel.DisplayName,
parcel.SitusAddress,
parcel.SitusCity

ORDER BY [GEO],[PIN];












