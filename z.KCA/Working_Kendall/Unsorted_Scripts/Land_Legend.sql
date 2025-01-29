-- !preview conn=con
WITH PricingMethod AS (
  SELECT *
  FROM codes_table
  WHERE codes_table.tbl_type_code = 'lcmshortdesc'
  ),

ActiveAllocations AS (
  SELECT *
  FROM allocations AS a
  WHERE a.lrsn = '75715'
    AND a.extension = 'L00'
    AND a.status = 'A'
)

SELECT DISTINCT
  aa.extension,
  aa.land_line_number,
  aa.last_update,
  
  p.neighborhood AS [GEO],
  p.lrsn,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  e.extension,
  ld.ExtValue,
  ld.LandType,
  lt.land_type_desc,
  ld.lcm,
  pm.tbl_element_desc,
  ld.SiteRating,
  CASE
    WHEN ld.SiteRating LIKE '1D' THEN 'No View' 
    WHEN ld.SiteRating LIKE '1F' THEN 'Average View' 
    WHEN ld.SiteRating LIKE '1P' THEN 'Good View' 
    WHEN ld.SiteRating LIKE '1S' THEN 'Excellent View' 
    WHEN ld.SiteRating LIKE '2D' THEN 'Legend 1' 
    WHEN ld.SiteRating LIKE '2F' THEN 'Legend 2' 
    WHEN ld.SiteRating LIKE '2P' THEN 'Legend 3' 
    WHEN ld.SiteRating LIKE '2S' THEN 'Legend 4' 
    WHEN ld.SiteRating LIKE '3D' THEN 'Legend 5' 
    WHEN ld.SiteRating LIKE '3F' THEN 'Legend 6' 
    WHEN ld.SiteRating LIKE '3P' THEN 'Legend 7' 
    WHEN ld.SiteRating LIKE '3S' THEN 'Legend 8' 
    WHEN ld.SiteRating LIKE '4D' THEN 'Legend 9' 
    WHEN ld.SiteRating LIKE '4F' THEN 'Legend 10' 
    WHEN ld.SiteRating LIKE '4P' THEN 'Legend 11' 
    WHEN ld.SiteRating LIKE '4S' THEN 'Legend 12' 
    WHEN ld.SiteRating LIKE '5A' THEN 'Legend 13' 
    WHEN ld.SiteRating LIKE 'CS' THEN 'Legend 14' 
    WHEN ld.SiteRating LIKE 'DA' THEN 'Legend 15' 
    WHEN ld.SiteRating LIKE 'DB' THEN 'Legend 16' 
    WHEN ld.SiteRating LIKE 'GA' THEN 'Legend 17' 
    WHEN ld.SiteRating LIKE 'GB' THEN 'Legend 18' 
    WHEN ld.SiteRating LIKE 'GC' THEN 'Legend 19' 
    WHEN ld.SiteRating LIKE '7' THEN 'Legend 20' 
    WHEN ld.SiteRating LIKE '8' THEN 'Legend 21' 
    ELSE ld.SiteRating
    END AS [SiteRating],
  ld.LDAcres,
  ld.BaseRate

FROM TSBv_PARCELMASTER as p
JOIN extensions AS e ON p.lrsn=e.lrsn
  AND e.extension = 'L00'
JOIN LandDetail AS ld ON ld.Id=p.lrsn
  AND ld.LandModelId = '702023'
JOIN PricingMethod AS pm ON ld.lcm=pm.tbl_element
JOIN land_types AS lt ON lt.land_type = ld.LandType
JOIN ActiveAllocations AS aa ON aa.lrsn = p.lrsn


WHERE p.lrsn = '75715'
--p.neighborhood IN ('1','2')
--,'15','16','17','33')
  AND p.EffStatus = 'A'

;
  
