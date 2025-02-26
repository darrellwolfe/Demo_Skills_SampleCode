SELECT DISTINCT
  p.lrsn AS LRSN,
  TRIM(p.pin) AS PIN, 
  TRIM(p.ain) AS AIN,
  p.neighborhood AS GEO,
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
  TRIM(p.ClassCD) AS PCC,
  a.group_code AS GroupCode,
  a.extension AS Record,
  a.improvement_id AS ImpID,
  p.Acres

FROM KCv_PARCELMASTER1 AS p
  JOIN allocations AS a ON p.lrsn=a.lrsn 
    AND a.status='A'

WHERE p.EffStatus= 'A'
  AND a.group_code IN ('99','98')
  AND a.improvement_id <> 'B'

ORDER BY GEO, PIN;