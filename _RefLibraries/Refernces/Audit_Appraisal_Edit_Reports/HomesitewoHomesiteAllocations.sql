SELECT DISTINCT
    p.lrsn AS LRSN,
    TRIM(p.pin) AS PIN,
    TRIM(p.AIN) AS AIN,
    p.neighborhood AS GEO,
    p.ClassCd AS PCC,
    ld.LandLineNumber AS Land_Line_Number,
    a.group_code AS Group_Code

FROM TSBv_PARCELMASTER AS p
    JOIN LandHeader AS lh ON p.lrsn = lh.RevObjId
        AND lh.EffStatus = 'A'
    JOIN LandDetail AS ld ON ld.LandHeaderId = lh.Id
        AND ld.LandType = '9'
        AND ld.EffStatus = 'A'
        AND ld.BegEffDate > '2024-01-01'
    JOIN allocations AS a ON a.lrsn = p.lrsn AND ld.LandLineNumber = a.land_line_number
        AND a.status = 'A'

WHERE p.EffStatus = 'A'
    AND a.group_code NOT IN ('26LH','81L','10','10H','12','12H','15','15H','20','20H')
    AND p.ClassCd <> '441'
    
ORDER BY AIN