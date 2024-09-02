-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

--------------------------------------------

--Start of Five Year Reval Cycle 2023-2027
DECLARE @TaxYear VARCHAR(4) = 2023;

DECLARE @startYearSuffix VARCHAR(2) = RIGHT(@TaxYear, 2);
DECLARE @endYearSuffix VARCHAR(2) = RIGHT(@TaxYear + 4, 2);
--DECLARE @startYearSuffix VARCHAR(2) = '23';
--DECLARE @endYearSuffix VARCHAR(2) = '27';

DECLARE @DECADE VARCHAR(1) = LEFT(@startYearSuffix,1);
DECLARE @YearFrom VARCHAR(1) = RIGHT(@startYearSuffix,1);
DECLARE @YearTo VARCHAR(1) = RIGHT(@endYearSuffix,1);


WITH CTE_TimberMemos AS (
    SELECT DISTINCT
        pm.neighborhood AS GEO,
        TRIM(pm.NeighborHoodName) AS GEO_Name,
        m.lrsn,
        TRIM(pm.pin) AS PIN,
        TRIM(pm.AIN) AS AIN,
        m.memo_id,
        TRIM(m.memo_text) AS memo_text,
        m.last_update
    FROM
        memos AS m
    JOIN
        TSBv_PARCELMASTER AS pm ON pm.lrsn = m.lrsn
    AND
        pm.EffStatus = 'A'
    WHERE
        m.status = 'A'
    AND
        m.memo_id IN ('AR', 'T', 'Z')
    AND
        m.memo_line_number <> 1
    AND (
        m.memo_text LIKE 'CS-%/' + '[' + @DECADE + ']' + '[' + @YearFrom + '-' + @YearTo + ']%'
        OR m.memo_text LIKE 'PF-%/' + '[' + @DECADE + ']' + '[' + @YearFrom + '-' + @YearTo + ']%'
    )
), 

ExtractedData AS (
  SELECT
  lrsn
  --,PATINDEX('%[0-9]/[0-9][0-9]%', memo_text) As DateStartIndex
  ,PATINDEX('%/[0-9][0-9]%', memo_text) As YearStartIndex
  --,PATINDEX('% %', memo_text) As SpaceStartIndex
  -- CS-3/24S
  -- PF-05/24AG, Art Thayer POA for Estate of Audrey L. Thayer.
  ,TRIM(
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(SUBSTRING(memo_text,PATINDEX('%-%', memo_text)+1,2)
              ,',','')
              ,'&','')
              ,'-','')
              ,'/','')
        )  AS Month

  ,TRIM(
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(SUBSTRING(memo_text,PATINDEX('%/[0-9][0-9]%', memo_text)+1,2)
              ,',','')
              ,'&','')
              ,'-','')
              ,'/','')
        )  AS Year

  ,TRIM(
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(SUBSTRING(memo_text,PATINDEX('%/[0-9][0-9]%', memo_text)+3,2)
              ,',','')
              ,'&','')
              ,'-','')
              ,'/','')
        )  AS TimberCodeClass
  ,memo_text

  FROM
    CTE_TimberMemos
)

Select Distinct
--CAST(ed.Year AS INT) AS Year
tm.GEO
,tm.GEO_Name
,tm.lrsn
,tm.PIN
,tm.AIN

,CASE
  WHEN ed.TimberCodeClass LIKE 'H' THEN 'Habitat'
  WHEN ed.TimberCodeClass LIKE 'I' THEN 'Index'
  WHEN ed.TimberCodeClass LIKE 'TA'
    OR ed.TimberCodeClass LIKE 'AG' THEN 'Mixed Timber/Ag'
  WHEN ed.TimberCodeClass LIKE 'T' THEN 'Timber'
  WHEN ed.TimberCodeClass LIKE 'A'
    OR ed.TimberCodeClass LIKE 'AG' THEN 'Ag'
  WHEN ed.TimberCodeClass LIKE 'S' THEN 'Mapping'
  WHEN ed.TimberCodeClass LIKE 'C' THEN 'Compliance'
  WHEN ed.TimberCodeClass LIKE 'DQ'
    OR ed.TimberCodeClass LIKE 'D' THEN 'Deferred Quote'
  WHEN ed.TimberCodeClass LIKE 'Y' THEN 'Yield'
  WHEN ed.TimberCodeClass LIKE 'TP' THEN 'Timber Plan'
  WHEN tm.memo_text LIKE '%AGDEC%' THEN 'Ag Declaration'
  ELSE 'Misc.'
 END AS 'TimberMemoCategory'
 
,CASE
  WHEN LEFT(tm.memo_text,2) = 'PF' THEN 'Pat Fitzwater'
  WHEN LEFT(tm.memo_text,2) = 'CS' THEN 'Colton Smith'
  ELSE 'Review'
 END AS 'User'
--,ed.Month
--,ed.Year
--,CONCAT('20',ed.Year) AS FullYear
--,CAST(CONCAT(CAST(ed.Month AS INT),'/','20',CAST(ed.Year AS INT)) AS DATE) AS MemoDate
,CAST(CONCAT(
    '20', RIGHT('0' + CAST(ed.Year AS VARCHAR), 2), '-',  -- Ensures the year is two digits
    RIGHT('0' + CAST(ed.Month AS VARCHAR), 2), '-',        -- Ensures the month is two digits
    '01'                                                   -- Adds a fixed day (01)
    ) AS DATE) AS DATE
/*
,YEAR(CONCAT(
    '20', RIGHT('0' + CAST(ed.Year AS VARCHAR), 2), '-',  -- Ensures the year is two digits
    RIGHT('0' + CAST(ed.Month AS VARCHAR), 2), '-',        -- Ensures the month is two digits
    '01'                                                   -- Adds a fixed day (01)
    )) AS YEAR
,MONTH(CONCAT(
    '20', RIGHT('0' + CAST(ed.Year AS VARCHAR), 2), '-',  -- Ensures the year is two digits
    RIGHT('0' + CAST(ed.Month AS VARCHAR), 2), '-',        -- Ensures the month is two digits
    '01'                                                   -- Adds a fixed day (01)
    )) AS MONTH
,DATENAME(CONCAT(
    '20', RIGHT('0' + CAST(ed.Year AS VARCHAR), 2), '-',  -- Ensures the year is two digits
    RIGHT('0' + CAST(ed.Month AS VARCHAR), 2), '-',        -- Ensures the month is two digits
    '01'                                                   -- Adds a fixed day (01)
    )) AS MONTHNAME
*/
,tm.memo_id
,ed.TimberCodeClass
,ed.YearStartIndex
,tm.memo_text
,tm.last_update

From CTE_TimberMemos AS tm
Join ExtractedData AS ed
  On tm.lrsn = ed.lrsn
  And tm.memo_text = ed.memo_text

--Where CAST(ed.Year AS INT) BETWEEN @YearFrom AND @YearTo

Where ed.Year BETWEEN @startYearSuffix AND @endYearSuffix

Order by GEO, PIN;