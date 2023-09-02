/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
parcel.lrsn,
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
CONCAT(LTRIM(RTRIM(parcel.ain)),',') AS [AIN_LookUp], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD],
a.group_code AS [Allocation_GroupCode],
a.property_class AS [Allocation_PropClassCode],
a.extension AS [Record],
a.improvement_id AS [ImpId],
ld.SoilIdent,
ld.ExcessLandFlag,
--Land Details
ld.LandLineNumber,
--Land Type
ld.LandType AS [LandType#],
lt.land_type_desc AS [LandType Descr],
--Land LCM
ld.lcm AS [LCM#],
ctlcm.tbl_element_desc AS [LCM Descr],
--Land Site Rating
ld.SiteRating AS [LegendType#],
ctsr.tbl_element_desc AS [LegendType Descr],
--Acres
parcel.Acres,
lh.TotalMktAcreage,
ld.LDAcres,
ld.ActualFrontage,

--Rates
ld.BaseRate AS [BaseRate]

--Primary Query
FROM KCv_PARCELMASTER1 AS parcel
JOIN allocations AS a ON parcel.lrsn=a.lrsn AND a.status='A'
--LEFT JOIN the Land Header and Details, but JOIN the elements of those tables to land
LEFT JOIN LandHeader AS lh ON parcel.lrsn=lh.RevObjId
JOIN LandDetail AS ld ON lh.Id=ld.LandHeaderId AND lh.PostingSource=ld.PostingSource AND lh.LandModelId=ld.LandModelId
JOIN codes_table AS ctlcm ON (ld.lcm=ctlcm.tbl_element AND tbl_type_code='lcmshortdesc')
JOIN codes_table AS ctsr ON (ld.SiteRating=ctsr.tbl_element AND ctsr.tbl_type_code='siterating')
JOIN land_types AS lt ON ld.LandType=lt.land_type



--Primary WHERE statements
WHERE parcel.EffStatus= 'A'
AND a.status='A'
--Remove for an identical search but for all allocations, not just 98--99s
AND a.group_code IN ('99','98')
AND lh.EffStatus='A'
--Change land model ID for current year
AND lh.LandModelId='702023'
AND ld.EffStatus='A'
AND ld.LandModelId='702023'
AND ctlcm.code_status= 'A'
AND ctsr.code_status= 'A'



ORDER BY [GEO], [PIN];

