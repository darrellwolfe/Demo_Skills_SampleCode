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
    r.land_mkt_val_inc AS [Worksheet_Land],
    (r.income_value - r.land_mkt_val_cost) AS [Worksheet_Imp],
    r.income_value AS [Worksheet Total]
FROM KCv_PARCELMASTER1 AS parcel
INNER JOIN reconciliation AS r ON parcel.lrsn = r.lrsn
WHERE parcel.EffStatus = 'A'
AND r.status = 'W'
AND r.method = 'I' 
AND r.land_model = '702023'

UNION ALL

SELECT 
    parcel.lrsn,
    LTRIM(RTRIM(parcel.pin)) AS [PIN], 
    LTRIM(RTRIM(parcel.ain)) AS [AIN], 
    parcel.neighborhood AS [GEO],
    r.method AS [PriceMethod],
    parcel.Acres,
    r.land_mkt_val_cost AS [Worksheet_Land],
    r.cost_value AS [Worksheet_Imp],
    (r.cost_value + r.land_mkt_val_cost) AS [Worksheet_Total]
FROM KCv_PARCELMASTER1 AS parcel
INNER JOIN reconciliation AS r ON parcel.lrsn = r.lrsn
WHERE parcel.EffStatus = 'A'
AND r.status='W'
AND r.method = 'C' 
AND r.land_model = '702023'
ORDER BY GEO, PIN;
