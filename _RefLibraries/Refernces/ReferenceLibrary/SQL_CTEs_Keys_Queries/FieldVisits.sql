-- !preview conn=conn



--FIRST Year of Reval Cycle
DECLARE @FirstYearOfRevalCycle INT = 2023; 
--FIRST ACTUAL FUNCTIONAL Year of Reval Cycle
-- RY23 started 04/16/2022
-- 04/16/2022 -- 04/15/2027
DECLARE @FirstFunctionalYearOfRevalCycle INT = @FirstYearOfRevalCycle-1; 

-- Current Tax Year -- Change this to the current tax year
DECLARE @MemoIDYear1 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear2 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+1 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear3 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+2 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear4 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+3 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear5 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+4 AS VARCHAR(4)), 2) AS VARCHAR(4));

DECLARE @FunctionalYearFROM DATE = CAST(CAST(@FirstFunctionalYearOfRevalCycle AS VARCHAR) + '-04-16' AS DATE);
DECLARE @FunctionalYearTO DATE = CAST(CAST(@FirstFunctionalYearOfRevalCycle+5 AS VARCHAR) + '-04-15' AS DATE);


WITH

CTE_FieldVisits AS (
SELECT
    e.lrsn,
    -- e.extension,
    e.data_source_code,
    TRIM(e.data_collector) AS Appraiser_Fielded,
    CAST(e.collection_date AS DATE) AS FieldedDate

FROM extensions AS e

WHERE e.extension = 'L00'
AND e.status = 'A'
--AND e.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
AND e.collection_date BETWEEN @FunctionalYearFROM AND @FunctionalYearTO

)


Select *
From CTE_FieldVisits
--Where AppraisedDate > '2024-01-01'