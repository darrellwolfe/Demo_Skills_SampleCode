-- !preview conn=con

WITH CTE_Grade_Codes AS (
SELECT 
  ct.tbl_type_code,
  ct.tbl_element,
  ct.tbl_element_desc

FROM codes_table AS ct

WHERE ct.code_status = 'A'
AND ct.tbl_type_code = 'grades'
),

CTE_House_Type AS (
SELECT 
  ct.tbl_type_code,
  ct.tbl_element,
  ct.tbl_element_desc

FROM codes_table AS ct

WHERE ct.code_status = 'A'
AND ct.tbl_type_code = 'htyp'
)

SELECT
  p.lrsn,
  TRIM(p.AIN) AS [AIN],
  TRIM(p.pin) AS [PIN],
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
  p.neighborhood AS [GEO],
  p.ClassCd AS [PCC],
  p.LegalAcres AS [Legal_Acres],
  i.extension,
  i.imp_type AS [Imp_Type],
  cht.tbl_element_desc AS [House_Type],
  cgc.tbl_element_desc AS [Grade],
  i.condition AS [Condition],
  i.year_built AS [Year_Built],
  i.eff_year_built AS [Eff_Year]

FROM TSBv_PARCELMASTER AS p
JOIN dwellings AS d ON p.lrsn=d.lrsn  
JOIN improvements AS i ON p.lrsn=i.lrsn AND d.extension=i.extension
JOIN CTE_Grade_Codes AS cgc ON i.grade=cgc.tbl_element
JOIN CTE_House_Type AS cht on d.mkt_house_type=cht.tbl_element

WHERE p.EffStatus = 'A'
AND i.status = 'A'
AND d.status = 'A'
AND (i.imp_type = 'DWELL'
  or i.imp_type = 'MHOME')
