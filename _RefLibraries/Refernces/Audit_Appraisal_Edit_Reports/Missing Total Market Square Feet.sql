-- !preview conn=con

SELECT DISTINCT 
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
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
p.neighborhood,
p.SitusAddress AS [Situs_Adress],
ld.LandType AS [Land_Type],
ld.lcm AS [Pricing_Method],
ld.LDAcres AS [Legal_Acres],
ld.SqrFeet,
lh.TotalSqrFeet,
ld.BaseRate

FROM LandHeader as lh
JOIN LandDetail as ld ON lh.Id=ld.LandHeaderId
JOIN TSBv_PARCELMASTER AS p ON lh.RevObjId = p.lrsn

WHERE lh.EffStatus='A'
AND lh.PostingSource='A'
AND ld.EffStatus='A'
AND ld.PostingSource = 'A'
AND ld.SqrFeet = '0'
AND ld.lcm = '30'
AND p.EffStatus = 'A'