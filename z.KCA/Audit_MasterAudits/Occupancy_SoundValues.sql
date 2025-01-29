DECLARE @CURRENTYEAR AS int = CONCAT((YEAR(GETDATE())),'0101')
;

SELECT
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
  END AS [District], 
  p.neighborhood AS [GEO],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  CASE
    WHEN i.sound_value_code = '-1' THEN 'Pricing Error'
    WHEN i.sound_value_code = '1' THEN 'Base Rate'
    WHEN i.sound_value_code = '2' THEN 'Adjusted Rate'
    WHEN i.sound_value_code = '3' THEN 'Replacement Rate'
    WHEN i.sound_value_code = '4' THEN 'True Tax'
    WHEN i.sound_value_code = '5' THEN 'No Value'
    WHEN i.sound_value_code = '6' THEN 'Override'
    ELSE NULL
    END AS [Sound_Value_Code],
  e.extension AS [Extension],
  i.improvement_id AS [Imp_ID],
  i.imp_type AS [Imp_Type]
  
FROM TSBv_PARCELMASTER AS p
  JOIN extensions AS e ON p.lrsn = e.lrsn
  JOIN improvements AS i on p.lrsn=i.lrsn AND i.extension = e.extension
  JOIN valuation AS v ON p.lrsn = v.lrsn
      AND v.eff_year > @CURRENTYEAR
      AND v.status = 'A'

WHERE p.EffStatus='A'
  AND e.status = 'A'
  AND i.status='A'
  AND i.sound_value_code <>'0'
  AND e.extension LIKE 'C%'
  
ORDER BY
  i.sound_value_code,
  p.neighborhood,
  p.AIN