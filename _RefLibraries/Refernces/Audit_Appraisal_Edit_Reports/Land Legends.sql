SELECT
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  p.neighborhood AS [GEO],
  CASE
    WHEN p.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 6003 THEN 'District_6'
    WHEN p.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 6001 THEN 'District_6'
    WHEN p.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 5003 THEN 'District_5'
    WHEN p.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 5001 THEN 'District_5'
    WHEN p.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 4000 THEN 'District_4'
    WHEN p.neighborhood >= 3000 THEN 'District_3'
    WHEN p.neighborhood >= 2000 THEN 'District_2'
    WHEN p.neighborhood >= 1021 THEN 'District_1'
    WHEN p.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 1001 THEN 'District_1'
    WHEN p.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 451 THEN 'Commercial'
    WHEN p.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN p.neighborhood >= 1 THEN 'Commercial'
    WHEN p.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District,
  TRIM(p.PropClassDescr) AS [ClassCD],
  p.LegalAcres,
  lh.TotalMktAcreage,
  ld.LDAcres,
  ld.ActualFrontage,
  ld.LandLineNumber,
  ld.LandType AS [LandType#],
  lt.land_type_desc AS [LandType_Descr],
  ctlcm.tbl_element_desc AS [LCM_Descr],
  ctsr.tbl_element_desc AS [LegendType_Descr],
  ld.BaseRate AS [BaseRate],
  ld.SoilIdent,
  lh.LandModelId,
  ctinf.tbl_element_desc AS [Land_Influence_Descr],
  CASE
    WHEN li.InfluenceType = '1' THEN 'Percent Adjustment'
    WHEN li.InfluenceType = '2' THEN 'Value Adjustment'
    ELSE NULL
  END AS [Influence_Type],
  CASE
    WHEN li.InfluenceType = '1' THEN FORMAT((CAST(li.InfluenceAmount AS DECIMAL (16,2))/100),'P0')
    WHEN li.InfluenceType = '2' THEN FORMAT(li.InfluenceAmount,'C0')
    ELSE NULL
  END AS [Influence_Amount],
  FORMAT(li.PriceAdjustment,'C0') AS [Adjustment_Value]
  
FROM TSBv_PARCELMASTER AS p
  JOIN LandHeader AS lh ON p.lrsn=lh.RevObjId
    AND lh.EffStatus='A'  
    AND lh.PostingSource = 'A' 
  FULL JOIN LandDetail AS ld ON lh.Id=ld.LandHeaderId AND lh.PostingSource = ld.PostingSource
    AND ld.EffStatus = 'A'
  FULL JOIN codes_table AS ctlcm ON ld.lcm=ctlcm.tbl_element 
    AND tbl_type_code='lcmshortdesc'
    AND ctlcm.code_status= 'A'
  FULL JOIN codes_table AS ctsr ON ld.SiteRating=ctsr.tbl_element AND ctsr.tbl_type_code='siterating'
    AND ctsr.code_status= 'A'
  JOIN land_types AS lt ON ld.LandType=lt.land_type
  FULL JOIN LandInfluence AS li ON li.ObjectId = ld.Id AND ld.PostingSource = li.PostingSource
    AND li.EffStatus = 'A'
  FULL JOIN codes_table AS ctinf ON li.InfluenceCode = ctinf.tbl_element AND ctinf.tbl_type_code = 'landinf'
    AND ctinf.code_status = 'A'
  
  
WHERE p.EffStatus='A' 
  AND p.neighborhood <> '0'
