-- !preview conn=con

  SELECT
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  p.neighborhood AS [GEO],
  TRIM(p.PropClassDescr) AS [PCC],
  p.LegalAcres AS [Legal_Acres],
  FORMAT(p.WorkValue_Land,'C0') AS [Current_Land_Value],
  FORMAT(CAST(p.WorkValue_Land AS DECIMAL(18, 2))/NULLIF((CAST(p.LegalAcres AS DECIMAL (18,4))*43560),0),'C') AS [Land_Square_Foot_Value],
  a.extension AS [Ext.],
  a.improvement_id AS [Imp_ID],
  i.imp_type AS [Imp_Type],
  i.year_built AS [Year_Built],
  i.eff_year_built AS [Eff_Year_Built],
  i.year_remodeled AS [Year_Remodeled],
  i.condition AS [Condition],
  ct.tbl_element_desc AS [Grade],
  a.method AS [Pricing Method],
  FORMAT(
  CASE
    WHEN a.method = 'C' THEN a.cost_value
    WHEN a.method = 'I' THEN a.income_value
  ELSE NULL
  END,'C0') AS [Current_Imp_Value],
  FORMAT(i.imp_size, '#,###') AS [Square_Feet],
  FORMAT(
  CASE
    WHEN a.method = 'C' THEN CAST(a.cost_value AS DECIMAL(18, 2)) / NULLIF(i.imp_size, 0)
    WHEN a.method = 'I' THEN CAST(a.income_value AS DECIMAL(18, 2)) / NULLIF(i.imp_size, 0)
    ELSE NULL
    END,'C') AS [Improved_Square_Foot_Value]

FROM allocations AS a
  JOIN extensions AS e ON a.lrsn = e.lrsn
  JOIN improvements AS i ON i.lrsn=a.lrsn
    AND i.extension = e.extension
    AND i.extension=a.extension 
    AND i.improvement_id=a.improvement_id
    AND i.status = 'A'
  JOIN codes_table AS ct on i.grade = ct.tbl_element
    AND ct.tbl_type_code = 'grades'
  JOIN TSBv_PARCELMASTER AS p ON a.lrsn = p.lrsn
    AND p.EffStatus = 'A'
    AND p.neighborhood < '1000'
  JOIN valuation AS v ON i.lrsn = v.lrsn
    AND v.status = 'A'
    AND v.eff_year = '20230101'

WHERE a.status = 'A'
  AND e.status = 'A'

ORDER BY p.AIN