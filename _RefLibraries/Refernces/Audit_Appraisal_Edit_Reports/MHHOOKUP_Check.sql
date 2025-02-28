SELECT DISTINCT
    TRIM(p.pin) AS PIN,
    TRIM(p.AIN) AS AIN,
    p.neighborhood AS GEO,
    TRIM(vd.group_code) AS Group_Code,
    vd.extension AS Extension,
    vd.improvement_id AS Imp_ID,
    vd.imp_type AS Imp_Type

    
FROM TSBv_PARCELMASTER AS p
    JOIN val_detail AS vd ON vd.lrsn = p.lrsn


WHERE p.EffStatus = 'A'
    AND vd.status = 'A'
    AND vd.eff_year = '20240101'
    AND vd.imp_type = 'MHHOOKUP'

ORDER BY
    GEO,
    AIN