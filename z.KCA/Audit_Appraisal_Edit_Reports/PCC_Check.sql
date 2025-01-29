SELECT *
FROM (
SELECT DISTINCT
    TRIM(p.pin) AS PIN,
    TRIM(p.AIN) AS AIN,
    CASE
        WHEN LEFT(p.pin,1) BETWEEN '0' AND '9' THEN 'Rural'
        ELSE 'Urban'
    END AS RURAL_URBAN,
    CASE
        WHEN LEFT(p.pin,1) BETWEEN '0' AND '9' AND p.pin LIKE ('__N__W%') THEN 'Township-Range_Land'
        WHEN LEFT(p.pin,1) BETWEEN '0' AND '9' AND p.pin LIKE ('__N__E%') THEN 'Township-Range_Land'
        WHEN LEFT(p.pin, 1) BETWEEN '0' AND '9' AND p.pin LIKE '__N__[_EW]%' THEN 'Township-Range_Land'
        WHEN LEFT(p.pin,1) BETWEEN '0' AND '9' THEN 'Subdivision'
        ELSE NULL
    END AS RURAL_PIN_TYPE,
    CASE
        WHEN LEFT(p.pin, 1) BETWEEN 'A' AND 'Z' AND LEFT(p.pin, 5) LIKE '_0000' THEN 'Metes_Bounds'
        WHEN LEFT(p.pin, 1) BETWEEN 'A' AND 'Z' THEN 'Subdivision'
        ELSE NULL
    END AS URBAN_PIN_TYPE,
    p.Improvement_Status,
    CASE
        WHEN p.Improvement_Status = 'improved' AND p.ClassCd NOT IN ('336','339','343','435','438','441','442','451','525','526','527','534','537','541','546','548','550','555','565','667','681') THEN TRIM(p.PropClassDescr)
        WHEN p.Improvement_Status = 'unimproved' AND p.ClassCd NOT IN ('314','317','322','411','413','416','421','512','515','520','525','526','527','667','681') THEN TRIM(p.PropClassDescr)
        ELSE NULL
    END AS PCC_Check,
    CASE
        WHEN e.status = 'F' THEN 'FPR'
        ELSE 'Fix_ASAP'
    END AS FPR_Check

FROM TSBv_PARCELMASTER AS p
    FULL JOIN extensions AS e ON p.lrsn = e.lrsn
        AND e.status = 'F'

WHERE p.EffStatus = 'A'
    AND p.pin NOT LIKE 'E%'
    AND p.pin NOT LIKE 'UP%'
    AND p.pin NOT LIKE 'G%'
) subquery

WHERE PCC_Check IS NOT NULL

ORDER BY PCC_Check,
    PIN
;