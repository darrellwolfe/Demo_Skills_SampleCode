WITH cte_collection AS (
    SELECT
        KCv_PARCELMASTER1.neighborhood,
        COUNT(*) AS collection_count
    FROM
        GRM_Main.dbo.extensions
    INNER JOIN
        GRM_Main.dbo.KCv_PARCELMASTER1
        ON extensions.lrsn = KCv_PARCELMASTER1.lrsn
    WHERE
        extensions.extension = 'L00'
        AND KCv_PARCELMASTER1.EffStatus = 'A'
        AND (extensions.collection_date >= '2023-04-01 00:00:00'
        AND extensions.collection_date < '2024-04-1 00:00:00')
	AND extensions.status = 'A'
    GROUP BY
        KCv_PARCELMASTER1.neighborhood
),
cte_appraisal AS (
    SELECT
        KCv_PARCELMASTER1.neighborhood,
        COUNT(*) AS appraisal_count
    FROM
        GRM_Main.dbo.extensions
    INNER JOIN
        GRM_Main.dbo.KCv_PARCELMASTER1
        ON extensions.lrsn = KCv_PARCELMASTER1.lrsn
    WHERE
        extensions.extension = 'L00'
        AND KCv_PARCELMASTER1.EffStatus = 'A'
        AND (extensions.appraisal_date >= '2023-04-01 00:00:00'
        AND extensions.appraisal_date < '2024-04-01 00:00:01')
	AND extensions.status = 'A'
    GROUP BY
        KCv_PARCELMASTER1.neighborhood
)
SELECT
    COALESCE(cte_collection.neighborhood, p.neighborhood) AS neighborhood,
    cte_collection.collection_count,
    cte_appraisal.appraisal_count,
    COUNT(DISTINCT p.lrsn) AS [Total to Reval],
    COUNT(CASE WHEN m.Memo_ID = 'RY24'
                  AND m.Memo_Line_Number = 2
                  AND m.Memo_Text IS NOT NULL THEN 1 ELSE NULL END) AS [Reval sign off]
FROM
    cte_collection
FULL OUTER JOIN
    cte_appraisal ON cte_collection.neighborhood = cte_appraisal.neighborhood
FULL OUTER JOIN
    KCv_PARCELMASTER1 p ON cte_collection.neighborhood = p.neighborhood
LEFT JOIN
    memos m ON p.lrsn = m.lrsn
WHERE
    p.EffStatus = 'A'
    AND p.neighborhood IS NOT NULL
GROUP BY
    COALESCE(cte_collection.neighborhood, p.neighborhood),
    cte_collection.collection_count,
    cte_appraisal.appraisal_count;
