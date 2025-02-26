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
--All TimberAg for Mail Merge
------------------------------

SELECT DISTINCT
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD],
--Allocations
a.group_code AS [GroupCode],
impgroup.tbl_element_desc AS [ImpGroup],
--Memo
LTRIM(RTRIM(m.memo_text)) AS [Memos],
--Acres
parcel.Acres,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
--Additional
'' AS [AdditionalDetails>>],

--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
--Mailing
LTRIM(RTRIM(parcel.AttentionLine)) AS [Attn],
LTRIM(RTRIM(parcel.MailingAddress)) AS [MailingAddress],
LTRIM(RTRIM(parcel.MailingCityStZip)) AS [Mailing CSZ],
--Other
LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
LTRIM(RTRIM(parcel.DisplayDescr)) AS [LegalDescription],
LTRIM(RTRIM(parcel.SecTwnRng)) AS [SecTwnRng]


FROM KCv_PARCELMASTER1 AS parcel

--Land Header
JOIN LandHeader AS lh ON lh.RevObjId=parcel.lrsn 
  AND lh.EffStatus= 'A' 
  AND lh.LastUpdate > '2023-01-01'
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
  AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')

--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

--allocations
LEFT JOIN allocations AS a ON parcel.lrsn=a.lrsn 
  AND a.status='A' 
  --AND a.group_code IN ('06','07')
  AND a.last_update > '2023-01-01'
  
  --Join codes_table to allocations
  LEFT JOIN codes_table AS impgroup ON a.group_code=impgroup.tbl_element 
    AND code_status='A'
    AND tbl_type_code IN ('impgroup')

--memos
LEFT JOIN memos AS m ON parcel.lrsn=m.lrsn 
  AND m.memo_id='T' 
  AND m.memo_line_number > 1
  AND (m.memo_text LIKE '%/23'
      OR m.memo_text LIKE '%/24')



WHERE parcel.EffStatus= 'A'
  AND lh.LandModelId='702023'
  AND ld.LandModelId='702023'
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'


GROUP BY
parcel.lrsn,
parcel.ain,
parcel.pin,
parcel.neighborhood,
a.group_code,
m.memo_text,
parcel.Acres,
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
parcel.ClassCD,
impgroup.tbl_element_desc,
parcel.DisplayName,
parcel.AttentionLine,
parcel.SitusAddress,
parcel.SitusCity,
parcel.MailingAddress,
parcel.MailingCityStZip,
parcel.TAG,
parcel.DisplayDescr,
parcel.SecTwnRng


ORDER BY [GEO],[PIN], [GroupCode],ld.LandType;