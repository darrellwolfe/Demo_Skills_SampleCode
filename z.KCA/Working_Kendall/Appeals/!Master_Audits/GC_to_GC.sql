WITH CTE_CONCAT_GCs AS (
    SELECT 
        p.lrsn AS LRSN,
        TRIM(p.ClassCd) AS PCC,
        STRING_AGG(vd.group_code,',') AS GCs
        
    FROM TSBv_PARCELMASTER AS p
        JOIN val_detail AS vd ON p.lrsn = vd.lrsn

    GROUP BY 
        LRSN, 
        PCC
)
SELECT 
    ccg.LRSN,
    ccg.PCC,
    ccg.GCs,
    CASE
        WHEN ccg.PCC = 421 AND CHARINDEX(81, ccg.GCs) > 0 
            OR CHARINDEX(19, ccg.GCs) > 0
             THEN 'BAD'
        ELSE 'OK'
    END AS ValidationMessage
FROM 
    CTE_CONCAT_GCs AS ccg
WHERE 
    ValidationMessage = 'BAD'
