SELECT 
    p.lrsn,
    p.pin,
    p.AIN,
    p.ClassCd,
    CASE
        WHEN r.land_use_value <> '0' THEN 'Imp Ag'
        WHEN p.ClassCd IN ('565','548','546') THEN 'Imp MH'
        WHEN p.ClassCd IN ('336','339','343','435','438','441','442','451','527') THEN 'Imp Comm/Ind'
        WHEN p.ClassCd IN ('534','537','541','550') THEN 'Imp Res'
        WHEN p.Improvement_Status = 'improved' THEN 'Imp Other' 
        ELSE NULL
    END AS 'Parcel Sorting'

FROM TSBv_PARCELMASTER AS p
    JOIN reconciliation AS r ON p.lrsn = r.lrsn
        AND r.date_cert = '0'

WHERE p.neighborhood > '0'
    AND p.EffStatus = 'A'
