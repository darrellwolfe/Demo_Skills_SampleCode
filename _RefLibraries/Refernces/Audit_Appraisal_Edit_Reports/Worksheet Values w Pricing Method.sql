-- !preview conn=con

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
  p.ClassCd AS [PCC],
  p.PropClassDescr [PCC_Descr],
  CASE
    WHEN r.method = 'C' THEN 'Cost'
    WHEN r.method = 'I' THEN 'Income'
    WHEN r.method = 'O' THEN 'Override'
    ELSE 'Other Pricing Method'
  END AS [Pricing_Method],
  CASE
    WHEN r.method = 'C' THEN r.land_mkt_val_cost
    WHEN r.method = 'I' THEN r.land_mkt_val_inc
    ELSE NULL
  END AS [Land_Value],  
  CASE
    WHEN r.method = 'C' THEN r.cost_value
    WHEN r.method = 'I' THEN (r.income_value-r.land_mkt_val_inc)
    ELSE NULL
  END AS [Improvement_Value],
    CASE
    WHEN r.method = 'C' THEN (r.cost_value+r.land_mkt_val_cost)
    WHEN r.method = 'I' THEN r.income_value
    ELSE NULL
  END AS [Total_Value]
  
FROM reconciliation AS r
  JOIN TSBv_PARCELMASTER AS p ON r.lrsn = p.lrsn

WHERE p.EffStatus = 'A'
  AND p.neighborhood <> '0'
  AND r.status = 'W'
  
GROUP BY
  p.neighborhood,
  p.pin,
  p.AIN,
  p.ClassCd,
  p.PropClassDescr,
  r.method,
  r.land_mkt_val_cost,
  r.land_mkt_val_inc,
  r.cost_value,
  r.income_value
  
ORDER BY
  [Total_Value]