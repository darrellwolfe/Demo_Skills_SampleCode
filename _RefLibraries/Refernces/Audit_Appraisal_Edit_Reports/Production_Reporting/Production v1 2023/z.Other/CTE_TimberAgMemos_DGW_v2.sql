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

WITH

CTE_TimberMemos AS (
Select Distinct
pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,m.lrsn
--,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,m.memo_id
,LEFT(m.memo_text,15) AS SignOff
--,REPLACE (LEFT(m.memo_text,15),',','') AS SignOff
--,RIGHT(REPLACE (LEFT(m.memo_text,9),',','') ,1) AS LastLetter
--,REPLACE (LEFT(m.memo_text,9),',','') AS SignOff
--,LEFT(m.memo_text,9) AS SignOff

/*
CS-10/23A, Spli
CS-2/23S Split
CS-2/23A, Remov
CS-4/23A P/A 0
CS-3/23A, Proce
PF-09/23C = 9
PF-04/24T
CS-3/23S
PF-05/23T
*/




,m.memo_text
,m.last_update
--,m.memo_line_number
--,m.status

From memos AS m
Join TSBv_PARCELMASTER AS pm
  On pm.lrsn = m.lrsn
  And pm.EffStatus = 'A'

Where m.status = 'A'
  And m.memo_id IN ('AR','T','Z')
  And m.memo_line_number <> 1
  AND (m.memo_text LIKE 'CS-%/' + '['+ @DECADE + ']'+ '[' + @YearFrom +'-'+ @YearTo + ']' + '%' 
    OR m.memo_text LIKE 'PF-%/' + '['+ @DECADE + ']'+ '[' + @YearFrom +'-'+ @YearTo + ']' + '%')
)






Select Distinct
tm.*

/*
tm.GEO
,tm.GEO_Name
,tm.lrsn
,tm.PIN
,tm.AIN
,tm.memo_id
,tm.SignOff
,tm.LastLetter
,tm.memo_text
,tm.last_update
*/
--,tm.memo_line_number
--,tm.status
From CTE_TimberMemos AS tm


Order By GEO, PIN;


