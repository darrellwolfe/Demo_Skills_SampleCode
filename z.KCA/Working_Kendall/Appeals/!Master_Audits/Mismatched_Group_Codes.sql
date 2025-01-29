
SELECT
    p.lrsn AS LRSN,
    TRIM(p.pin) AS PIN,
    TRIM(p.AIN) AS AIN,
    p.neighborhood AS GEO,
    p.ClassCd AS PCC,
    vd.group_code AS Group_Code,
    vd.extension AS Extension,
    vd.improvement_id AS Imp_ID,
    STRING_AGG(vd.group_code, ', ') OVER (PARTITION BY p.lrsn) AS All_Group_Codes
    

FROM
    TSBv_PARCELMASTER AS p
    JOIN val_detail AS vd ON p.lrsn = vd.lrsn
        AND vd.eff_year = '20240101'

WHERE
    p.EffStatus = 'A'

GROUP BY
    p.lrsn,
    p.pin,
    p.AIN,
    p.neighborhood,
    p.ClassCd,
    vd.group_code,
    vd.extension,
    vd.improvement_id

ORDER BY
    AIN
    ;
