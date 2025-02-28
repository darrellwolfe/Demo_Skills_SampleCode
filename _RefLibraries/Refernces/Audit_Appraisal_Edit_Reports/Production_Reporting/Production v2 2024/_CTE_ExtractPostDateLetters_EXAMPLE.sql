-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
LTRIM(RTRIM())
*/

-- Existing query setup from CTE_TimberAgMemos_DGW_v1.sql

WITH ExtractedData AS (
    SELECT
        ColumnName,
        PATINDEX('%[0-9]/[0-9][0-9]%', ColumnName) AS DateStartIndex
    FROM
        YourTableName
), ProcessedData AS (
    SELECT
        ColumnName,
        DateStartIndex,
        SUBSTRING(ColumnName, 
                  DateStartIndex + LEN(SUBSTRING(ColumnName, DateStartIndex, PATINDEX('%[^0-9/]%', SUBSTRING(ColumnName, DateStartIndex, LEN(ColumnName))) + 1)) - 1,
                  PATINDEX('%[^A-Z]%', SUBSTRING(ColumnName, DateStartIndex + LEN(SUBSTRING(ColumnName, DateStartIndex, PATINDEX('%[^0-9/]%', SUBSTRING(ColumnName, DateStartIndex, LEN(ColumnName))) + 1)) - 1, LEN(ColumnName))) - 1) AS PostDateLetters
    FROM
        ExtractedData
)
SELECT
    ColumnName,
    LTRIM(RTRIM(PostDateLetters)) AS PostDateLetters
FROM
    ProcessedData
WHERE
    DateStartIndex > 0;
