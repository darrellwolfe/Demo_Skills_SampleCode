-- !preview conn=con


WITH 

cte_collection AS (
    SELECT
        pm.neighborhood,
        COUNT(*) AS collection_count
    FROM
        extensions AS e
    INNER JOIN
        KCv_PARCELMASTER1 AS pm
        ON e.lrsn = pm.lrsn
    WHERE
        e.extension = 'L00'
        AND pm.EffStatus = 'A'
        AND (e.collection_date >= '2023-04-01 00:00:00'
        AND e.collection_date < '2024-04-1 00:00:00')
	AND e.status = 'A'
    GROUP BY
        pm.neighborhood

),

cte_appraisal AS (
    SELECT
        pm.neighborhood,
        COUNT(*) AS appraisal_count
    FROM
        extensions AS e
    INNER JOIN
        KCv_PARCELMASTER1 AS pm
        ON e.lrsn = pm.lrsn
    WHERE
        e.extension = 'L00'
        AND pm.EffStatus = 'A'
        AND (e.appraisal_date >= '2023-04-01 00:00:00'
        AND e.appraisal_date < '2024-04-01 00:00:01')
	AND e.status = 'A'
    GROUP BY
        pm.neighborhood

)
SELECT
    COALESCE(c.neighborhood, p.neighborhood) AS neighborhood,
    c.collection_count,
    a.appraisal_count,
    COUNT(DISTINCT p.lrsn) AS [Total to Reval],
    COUNT(CASE WHEN m.Memo_ID = 'RY24'
                  AND m.Memo_Line_Number = 2
                  AND m.Memo_Text IS NOT NULL THEN 1 
                ELSE NULL 
          END) AS [Reval sign off]


FROM cte_collection AS c
FULL OUTER JOIN cte_appraisal AS a ON cte_collection.neighborhood = cte_appraisal.neighborhood
FULL OUTER JOIN KCv_PARCELMASTER1 AS p ON cte_collection.neighborhood = p.neighborhood
LEFT JOIN memos AS m ON p.lrsn = m.lrsn

WHERE p.EffStatus = 'A'
  AND p.neighborhood IS NOT NULL

GROUP BY
    COALESCE(cte_collection.neighborhood, p.neighborhood),
    cte_collection.collection_count,
    cte_appraisal.appraisal_count;