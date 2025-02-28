/*
AsTxDBProd
GRM_Main
Current year is always the worksheet value, change year to current year
*/

-- Parcel Master;

SELECT 
parcel.lrsn,
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
parcel.neighborhood AS [GEO],
r.method AS [PriceMethod],
parcel.Acres,
r.land_mkt_val_cost AS [Worksheet_Land],
(r.income_value-r.land_mkt_val_cost) AS [Worksheet_Imp],
r.income_value AS [Worksheet Total]


FROM KCv_PARCELMASTER1 AS parcel
INNER JOIN reconciliation AS r ON parcel.lrsn = r.lrsn

WHERE parcel.EffStatus= 'A'
AND r.method='I' 
AND r.land_model='702023'

ORDER BY parcel.neighborhood, parcel.pin;

