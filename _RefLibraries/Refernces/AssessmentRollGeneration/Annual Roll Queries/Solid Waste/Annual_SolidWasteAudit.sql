-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

WITH 
SAV AS (
    SELECT DISTINCT 
        P.AIN, 
        P.LRSN, 
        RO.Id AS RO_Id,
        SAVH.Id AS SAVH_Id,
        SAVD.Id AS SAVD_Id,
        SAVH.BEGEFFYEAR,
        SAVH.EFFSTATUS,
        SAVH.SAId
    FROM RevObj AS RO
    JOIN SAvalueHeader AS SAVH ON RO.Id = SAVH.RevObjId
    JOIN SAVALUEDETAIL AS SAVD ON SAVH.Id = SAVD.SAValueHeaderId
    JOIN TSBV_PARCELMASTER AS P ON SAVH.REVOBJID = P.lrsn
    WHERE 
        (SAVD.Effstatus = 'A' AND SAVH.SAId = '15' AND SAVH.EffStatus = 'A' AND SAVH.BegEffYear = '2022')
        OR 
        (SAVH.SAId = '38' AND SAVD.EffStatus = 'A' AND SAVH.EffStatus = 'A' AND SAVH.BegEffYear = '2022')
),
Dwell AS ( 
    SELECT E.*,I.improvement_id
    FROM TSBv_ParcelMaster AS kcv
    JOIN extensions AS e ON kcv.lrsn = e.lrsn
      AND e.status = 'A'
      AND e.ext_description <> 'CONDO'
    JOIN improvements AS i ON e.lrsn = i.lrsn 
      AND e.extension = i.extension
      AND i.status = 'A'
      AND (i.improvement_id = 'M' OR i.improvement_id = 'D' OR i.improvement_id = 'C')
    LEFT JOIN dwellings AS dw ON i.lrsn = dw.lrsn
      AND dw.status = 'A'
      AND i.extension = dw.extension
      WHERE kcv.EffStatus = 'A'
),
AllocationSum AS (
    SELECT LRSN
    FROM Allocations
    WHERE extension LIKE '%R%'
      AND status = 'A'
    GROUP BY LRSN
    HAVING SUM(cost_value) > 0
)
SELECT 
    D.lrsn, D.improvement_id,
    P.*
FROM Dwell AS D
LEFT JOIN SAV AS S ON D.LRSN = S.LRSN
JOIN TSBV_PARCELMASTER AS P ON P.lrsn = D.LRSN
JOIN AllocationSum AS A ON A.LRSN = D.LRSN
WHERE S.LRSN IS NULL;
