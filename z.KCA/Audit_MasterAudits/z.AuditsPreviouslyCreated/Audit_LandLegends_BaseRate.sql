-- !preview conn=con

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
  pm.lrsn,
  TRIM(pm.pin) AS [PIN],
  TRIM(pm.pin) AS [PIN],

  TRIM(pm.AIN) AS [AIN],
  pm.neighborhood AS [GEO],
  TRIM(pm.NeighborHoodName) AS [GEO_Name],
  TRIM(pm.PropClassDescr) AS [ClassCD],
  ex.extension AS [Land_Imp],
  --Acres
  pm.LegalAcres,
  lh.TotalMktAcreage,
  ld.LDAcres,
  ld.ActualFrontage,
  --Land Details
  ld.LandLineNumber,
  --Land Type
  ld.LandType AS [LandType#],
  lt.land_type_desc AS [LandType_Descr],
  --Land LCM
  ld.lcm AS [LCM#],
  ctlcm.tbl_element_desc AS [LCM_Descr],
  --Land Site Rating
  ld.SiteRating AS [LegendType#],
  ctsr.tbl_element_desc AS [LegendType_Descr],
  --Rates
  ld.BaseRate AS [BaseRate],
  ld.SoilIdent,
  ld.ExcessLandFlag,
  --Other Information
  TRIM(pm.TAG) AS [TAG],
  TRIM(pm.DisplayName) AS [Owner],
  TRIM(pm.SitusAddress) AS [SitusAddress],
  TRIM(pm.SitusCity) AS [SitusCity],
  lh.NbhdWhenPriced,
  lh.LastUpdate,
  lh.LandModelId

  
  
  FROM TSBv_PARCELMASTER AS pm
  LEFT JOIN LandHeader AS lh ON pm.lrsn=lh.RevObjId
    AND lh.EffStatus='A'
  LEFT JOIN LandDetail AS ld ON lh.Id=ld.LandHeaderId AND lh.LandModelId=ld.LandModelId
    AND ld.EffStatus='A'
  LEFT JOIN codes_table AS ctlcm ON (ld.lcm=ctlcm.tbl_element AND tbl_type_code='lcmshortdesc')
    AND ctlcm.code_status= 'A'
  LEFT JOIN codes_table AS ctsr ON (ld.SiteRating=ctsr.tbl_element AND ctsr.tbl_type_code='siterating')
    AND ctsr.code_status= 'A'
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  LEFT JOIN extensions AS ex ON (pm.lrsn=ex.lrsn AND ex.extension LIKE 'L%')
  
  
  WHERE pm.EffStatus='A' 
  -- AND pm.neighborhood  BETWEEN '2000' AND '2999'
  
ORDER BY
GEO, PIN, LandType#, LCM#;
