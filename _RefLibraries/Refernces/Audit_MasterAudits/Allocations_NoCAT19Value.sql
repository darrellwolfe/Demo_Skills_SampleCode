SELECT 
    TRIM(p.AIN) AS AIN,
    a.group_code,
    a.cost_value

FROM TSBv_PARCELMASTER as p 
    JOIN allocations AS a ON p.lrsn = a.lrsn
        AND a.[status] = 'A'
        AND a.group_code = '19'
        AND a.cost_value <> '0'

WHERE p.EffStatus = 'A'