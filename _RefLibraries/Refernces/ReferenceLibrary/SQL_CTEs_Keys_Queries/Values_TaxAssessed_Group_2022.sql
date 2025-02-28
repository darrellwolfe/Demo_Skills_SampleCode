/*
AsTxDBProd
GRM_Main

To filter by year, add/change 2022, 2023 as follows
AND v.eff_yea BETWEEN 20220101 AND 20221231;
AND v.eff_yea BETWEEN 20230101 AND 20231231;

*/

SELECT 
    parcel.lrsn,
    LTRIM(RTRIM(parcel.pin)) AS [PIN], 
    LTRIM(RTRIM(parcel.ain)) AS [AIN], 
    parcel.neighborhood AS [GEO],
    parcel.Acres,
    parcel.ClassCD,
    v.land_assess AS [Assessed Land],
    v.imp_assess AS [Assessed Imp],
    (v.imp_assess + v.land_assess) AS [Assessed Total Value],
    v.valuation_comment AS [Val Comment],
    v.eff_year AS [Tax Year],
    MAX(v.last_update) AS [Last Update]
FROM KCv_PARCELMASTER1 AS parcel
INNER JOIN valuation AS v ON parcel.lrsn = v.lrsn
WHERE parcel.EffStatus = 'A'
AND v.status = 'A'
AND v.eff_year BETWEEN 20220101 AND 20221231
GROUP BY parcel.lrsn, LTRIM(RTRIM(parcel.pin)), LTRIM(RTRIM(parcel.ain)), parcel.neighborhood, parcel.Acres, parcel.ClassCD, v.land_assess, v.imp_assess, v.valuation_comment, v.eff_year
ORDER BY GEO, PIN;
