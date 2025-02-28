SELECT 
    parcel.lrsn,
    LTRIM(RTRIM(parcel.pin)) AS [PIN], 
    LTRIM(RTRIM(parcel.ain)) AS [AIN], 
    parcel.neighborhood AS [GEO],
    parcel.Acres,
    parcel.ClassCD,
    v.land_market_val AS [Cert Land],
    v.imp_val AS [Cert Imp],
    (v.imp_val + v.land_market_val) AS [Cert Total Value],
    v.valuation_comment AS [Val Comment],
    v.eff_year AS [Tax Year],
    v.last_update AS [Last Update]
    
FROM KCv_PARCELMASTER1 AS parcel
INNER JOIN valuation AS v ON parcel.lrsn = v.lrsn
WHERE parcel.EffStatus = 'A'
AND v.status = 'A'
AND v.eff_year BETWEEN 20220101 AND 20221231

ORDER BY v.last_update;
