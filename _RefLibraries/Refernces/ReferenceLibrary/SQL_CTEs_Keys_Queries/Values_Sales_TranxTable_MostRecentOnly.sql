/*
AsTxDBProd
GRM_Main
*/

WITH SalesMostRecent AS (

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
tr.pxfer_date,
tr.AdjustedSalePrice,
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
--Looking for only most recent in final query
ROW_NUMBER() OVER(PARTITION BY parcel.lrsn ORDER BY tr.pxfer_date DESC) AS RowNumber

FROM KCv_PARCELMASTER1 AS parcel
JOIN transfer AS tr ON parcel.lrsn=tr.lrsn

WHERE parcel.EffStatus= 'A'
)

SELECT *
FROM SalesMostRecent
WHERE RowNumber='1'
--Looking for only most recent in final query

ORDER BY [GEO],[PIN];



/*

Smaller

CTE_SalePrice AS (
  Select
  lrsn,
  pxfer_date,
  AdjustedSalePrice,
  ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY pxfer_date DESC) AS RowNum

  From transfer
  Where AdjustedSalePrice <> '0'
  Group by lrsn,AdjustedSalePrice,pxfer_date;
)







*/