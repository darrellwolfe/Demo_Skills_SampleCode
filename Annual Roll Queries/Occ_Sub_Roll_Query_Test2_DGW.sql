-- !preview conn=conn


WITH CAD_CTE AS (
    SELECT 
        V.LRSN,
        SUM(CASE
            WHEN A.group_code = '81' AND A.last_update = '2023-05-03' AND A.cost_value > 0 THEN A.cost_value
            ELSE 0
        END) AS EX_VALUE
    FROM 
        VALUATION AS V
    JOIN 
        ALLOCATIONS AS A ON A.lrsn = V.lrsn
    WHERE 
        V.CHANGE_REASON = '01'
        AND V.EFF_YEAR LIKE '%2023%'
        AND V.status = 'A'
    GROUP BY 
        V.LRSN
),

POST_CTE AS (
    SELECT 
        V.lrsn, 
        V.imp_val AS POSTED_VALUE
    FROM 
        VALUATION AS V
    WHERE 
        V.status = 'A' 
        AND V.eff_year LIKE '%2023%' 
        AND (V.change_reason = '01' OR V.change_reason = '43')
),

HOEX_CTE AS (
    SELECT DISTINCT MOD.LRSN
    FROM tsbv_modifiers AS MOD
    WHERE MODIFIERDESCR LIKE '%602G%' 
    AND BEGTAXYEAR = '2023' 
    AND MODIFIERSTATUS = 'A'
),



SELECT DISTINCT
    T.LRSN AS LRSN, 
    TRIM(T.pin) AS PIN, 
    TRIM(T.AIN) AS AIN, 
    T.neighborhood,
    POST_CTE.POSTED_VALUE,
    CAD_CTE.EX_VALUE,
    POST_CTE.POSTED_VALUE - CAD_CTE.EX_VALUE AS CARRYOVER_IMPVAL,
    COALESCE(V.imp_val, 0) - (COALESCE(POST_CTE.POSTED_VALUE, 0) - COALESCE(CAD_CTE.EX_VALUE, 0)) AS OCC_VAL,
    V.imp_val AS OCC_IMP_VAL,
    TRIM(M.MEMO_TEXT) AS MEMO_TEXT,
    V.EFF_YEAR,
    12 - DATEDIFF(MONTH, '20230101', CONVERT(DATE, STUFF(STUFF(V.EFF_YEAR, 5, 0, '-'), 8, 0, '-'))) AS MonthsSinceJan2023,
    CASE 
        WHEN HOEX_CTE.LRSN IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS HOEX_EXISTS
    
    
    
FROM 
    TSBV_PARCELMASTER AS T
LEFT JOIN  
    MEMOS AS M ON M.lrsn = T.lrsn
LEFT JOIN  
    VALUATION AS V ON V.LRSN = T.lrsn
LEFT JOIN 
    CAD_CTE ON CAD_CTE.LRSN = T.LRSN
LEFT JOIN 
    POST_CTE ON POST_CTE.LRSN = T.lrsn
LEFT JOIN 
    HOEX_CTE ON HOEX_CTE.LRSN = T.lrsn
WHERE 
    M.memo_id = 'NC23'
    AND M.memo_line_number = '2'
    AND M.memo_text LIKE '%POSTED%'
    AND V.CHANGE_REASON = '06'
    AND V.EFF_YEAR LIKE '%2023%'
    AND V.status = 'A';
