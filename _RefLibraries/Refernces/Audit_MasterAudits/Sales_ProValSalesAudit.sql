SELECT DISTINCT
  TRIM(p.pin) AS PIN,
  TRIM(p.AIN) AS AIN,
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
  TRIM(p.SitusAddress) AS SitusAddress,
  SUBSTRING(CAST(t.pxfer_date AS VARCHAR),1,3) AS Transfer_Month,
  RIGHT(CAST(t.pxfer_date AS DATE), 2) AS Transfer_Day,
  LEFT(CAST(t.pxfer_date AS DATE), 4) AS Transfer_Year,
  FORMAT(t.pxfer_date, 'MM/dd/yyyy') AS Transfer_Date,
  t.AdjustedSalePrice AS Sales_Price,
  t.GranteeName AS Grantee,
  t.GrantorName AS Grantor

FROM TSBv_PARCELMASTER AS p
  JOIN transfer AS t ON p.lrsn = t.lrsn
  
WHERE t.pxfer_date >= '2024-01-01'
  AND t.AdjustedSalePrice > '0'