
/*
AsTxDBProd
GRM_Main

RURAL in URBAN BASED ON CRYSTAL FILTERS:
{KCv_PARCELMASTER1.neighborhood} in 1.00 to 9999.00 and
{KCv_PARCELMASTER1.EffStatus} = "A" and
not ({KCv_PARCELMASTER1.pin} startswith ["0", "47", "48", "49", "50", "51", "52", "53", "54"]) and
{allocations.group_code} in ["12", "13", "14", "15", "16", "17", "32", "34", "35", "36", "37", "38", "39"] and
{allocations.status} = "A"
*/

SELECT 
    parcel.lrsn,
    LTRIM(RTRIM(parcel.pin)) AS [PIN], 
    LTRIM(RTRIM(parcel.ain)) AS [AIN], 
    parcel.neighborhood AS [GEO],
    a.group_code AS [GroupCode],
    a.property_class AS [ClassCode],
    a.extension AS [Record],
    a.improvement_id AS [ImpId],
    CONVERT(VARCHAR, a.last_update, 101) AS [LastUpdate]
FROM KCv_PARCELMASTER1 AS parcel
JOIN allocations AS a ON parcel.lrsn = a.lrsn
WHERE parcel.EffStatus = 'A'
    AND a.status = 'A'
    AND NOT (parcel.pin LIKE '0%'
        OR parcel.pin LIKE '47%'
        OR parcel.pin LIKE '48%'
        OR parcel.pin LIKE '49%'
        OR parcel.pin LIKE '50%'
        OR parcel.pin LIKE '51%'
        OR parcel.pin LIKE '52%'
        OR parcel.pin LIKE '53%'
        OR parcel.pin LIKE '54%')
    AND a.group_code IN ('12','13','14','15','16','17','32','34','35','36','37','38','39')
    AND parcel.neighborhood <> 0
ORDER BY [GEO], [PIN];
