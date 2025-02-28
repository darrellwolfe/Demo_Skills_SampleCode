/*
This subquery pulls only the most recent iteration for each Id, because for some reason there are often two ACTIVE headers, which makes no sense! 
*/

WITH CTE_DescrHeader AS (
    SELECT
        dh.Id,
        dh.BegEffDate,
        dh.TranId,
        dh.RevObjId,
        dh.DescrHeaderType,
        dh.DisplayDescr,
        ROW_NUMBER() OVER (PARTITION BY dh.Id ORDER BY dh.BegEffDate DESC) AS RowNum
    FROM DescrHeader AS dh
    WHERE dh.EffStatus = 'A'
)
SELECT
    Id,
    BegEffDate,
    TranId,
    RevObjId,
    DescrHeaderType,
    DisplayDescr
FROM CTE_DescrHeader
WHERE RowNum = 1;
