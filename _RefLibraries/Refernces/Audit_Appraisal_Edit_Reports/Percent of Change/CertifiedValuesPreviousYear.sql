-- !preview conn=con

DECLARE @Certified_Year INT = '20230101';

SELECT
  MAX(v.last_update) AS [Last_Update],
  p.lrsn AS [LRSN],
  TRIM(p.pin) AS [PIN], 
  TRIM(p.ain) AS [AIN], 
  p.neighborhood AS [GEO],
  p.DisplayName AS [Owner_Name],
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
  p.LegalAcres AS [Legal_Acres],
  TRIM(p.PropClassDescr) AS [PCC],
  CASE
      WHEN p.CostingMethod = 'C' THEN 'Cost'
      WHEN p.CostingMethod = 'I' THEN 'Income'
      ELSE 'Other'
  END AS [Pricing_Method],
  FORMAT(v.land_market_val,'C0') AS [Certified_Land],
  FORMAT(v.imp_val,'C0') AS [Certified_Imp],
  FORMAT(v.imp_val + v.land_market_val,'C0') AS [Certified_Total_Value]

FROM TSBv_PARCELMASTER AS p
  JOIN valuation AS v ON p.lrsn = v.lrsn
  JOIN memos AS m ON m.lrsn = p.lrsn

WHERE p.neighborhood <> '0'
  AND p.PropClassDescr NOT LIKE '667%'
  AND p.EffStatus = 'A'
  AND v.status = 'A'
  AND v.eff_year = @Certified_Year
  AND (m.memo_id = 'NC23'
    OR m.memo_id = 'NC24')

GROUP BY 
  p.AIN,
  p.lrsn,
  p.pin,
  p.DisplayName,
  p.neighborhood,
  p.LegalAcres,
  p.PropClassDescr,
  p.CostingMethod,
  v.land_market_val,
  v.imp_val,
  v.lrsn
  HAVING MAX(v.last_update) = (
    SELECT MAX(v2.last_update)
    FROM valuation AS v2
    WHERE v2.lrsn = v.lrsn
    AND v2.eff_year = @Certified_Year
    AND v2.status = 'A')
;