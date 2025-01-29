-- !preview conn=con

SELECT
  p.AIN,
  p.pin,
  p.neighborhood,
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
  t.pxfer_date,
  t.AdjustedSalePrice,
  p.WorkValue_Impv,
  CASE
    WHEN t.AdjustedSalePrice <> '0' THEN CAST(p.WorkValue_Impv AS DECIMAL)/CAST(t.AdjustedSalePrice AS DECIMAL)
    ELSE NULL
  END AS [RATIO],
  t.TfrType,
  i.imp_type,
  i.imp_size,
  i.grade,
  i.condition,
  i.year_built,
  i.eff_year_built,
  d.mkt_house_type
  

FROM TSBv_PARCELMASTER as p
JOIN transfer AS t ON p.lrsn=t.lrsn
JOIN improvements AS i ON t.lrsn=i.lrsn
JOIN dwellings AS d ON t.lrsn=d.lrsn

WHERE p.EffStatus = 'A'
AND p.neighborhood IN ('9118','1000','1020','5000','5002','6000','6002')
AND t.status = 'A'
AND t.pxfer_date >= '2022-11-01'
AND t.pxfer_date <= '2023-12-31'
AND i.imp_type = 'DWELL'
AND i.status = 'A'
AND d.status = 'A'


ORDER BY 
p.pin