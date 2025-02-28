-- !preview conn=con

SELECT 
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
p.ClassCd AS [PCC],
p.DisplayName AS [Owner_Name],
TRIM(p.SitusAddress) AS [Situs_Address],
TRIM(p.SitusCity) AS [Situs_City],
p.neighborhood AS [GEO],
t.pxfer_date AS [Transfer_Date],
t.TfrType AS [Transfer_Type],
t.DocNum AS [Recorded_Doc_Number],
t.GrantorName AS [Grantor],
t.GranteeName AS [Grantee],
t.AdjustedSalePrice AS [Sales_Price],
t.SaleDesc AS [Sales_Description]

FROM TSBv_PARCELMASTER AS p
JOIN transfer AS t ON p.lrsn = t.lrsn

WHERE p.neighborhood < '999'
AND t.pxfer_date BETWEEN '2022-10-01' AND '2023-10-31'
AND t.status = 'A'
AND t.AdjustedSalePrice <> '0'

ORDER BY p.neighborhood
;