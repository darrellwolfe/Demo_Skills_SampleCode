/*
AsTxDBProd
GRM_Main


--Change to Plat desired:
AND parcel.pin LIKE 'PL774%'

--Change land model to the desired year, usually current year, but will filter out any that have not been priced yet (due to being new)
AND lh.LandModelId='702023'

-- Or search by GEO range
AND parcel.neighborhood  BETWEEN '2000' AND '2999'


*/

SELECT DISTINCT
--Demographics
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD],
ex.extension AS [Land_Imp],
--Acres
parcel.Acres,
lh.TotalMktAcreage,
ld.LDAcres,
ld.ActualFrontage,
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
--Rates
ld.BaseRate AS [BaseRate],
ld.SoilIdent,
ld.ExcessLandFlag,
--Other Information
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
lh.NbhdWhenPriced,
lh.LastUpdate,
lh.LandModelId,
LTRIM(RTRIM(parcel.TAG)) AS [TAG],
LTRIM(RTRIM(parcel.DisplayDescr)) AS [LegalDescription]


FROM KCv_PARCELMASTER1 AS parcel
LEFT JOIN LandHeader AS lh ON parcel.lrsn=lh.RevObjId
LEFT JOIN LandDetail AS ld ON lh.Id=ld.LandHeaderId AND lh.PostingSource=ld.PostingSource AND lh.LandModelId=ld.LandModelId
LEFT JOIN codes_table AS ctlcm ON (ld.lcm=ctlcm.tbl_element AND tbl_type_code='lcmshortdesc')
LEFT JOIN codes_table AS ctsr ON (ld.SiteRating=ctsr.tbl_element AND ctsr.tbl_type_code='siterating')
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
LEFT JOIN extensions AS ex ON (parcel.lrsn=ex.lrsn AND ex.extension LIKE 'L%')


WHERE parcel.EffStatus='A' 
AND lh.EffStatus='A'
AND ld.EffStatus='A'
AND ctlcm.code_status= 'A'
AND ctsr.code_status= 'A'
AND parcel.neighborhood  BETWEEN '2000' AND '2999'


ORDER BY
[GEO],
[PIN],
parcel.lrsn,[AIN],[ClassCD],[Land_Imp],parcel.Acres,lh.TotalMktAcreage,ld.LDAcres,ld.ActualFrontage,
ld.LandLineNumber,[LandType#],[LandType Descr],[LCM#],[LCM Descr],[LegendType#],[LegendType Descr],[BaseRate],ld.SoilIdent,ld.ExcessLandFlag,[Owner],[SitusAddress],[SitusCity],lh.NbhdWhenPriced,lh.LastUpdate,lh.LandModelId,[TAG],[LegalDescription];

