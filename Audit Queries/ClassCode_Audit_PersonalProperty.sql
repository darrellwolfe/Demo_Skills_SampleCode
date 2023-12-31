-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

GetRevObjByEffDate

function(@p_EffDate as nullable datetime) as table
= Source{[Schema="dbo",Item="GetRevObjByEffDate"]}[Data]
*/

DECLARE @Jan1ThisYear1 DATETIME;
SET @Jan1ThisYear1 = '2023-01-01 00:00:00';

DECLARE @Jan1ThisYear2 DATETIME;
SET @Jan1ThisYear2 = '2023-01-01 23:59:59';


WITH

CTE_PCC_to_System AS (
Select
tbl_type_code AS PCC
,tbl_element AS ClassCD
,tbl_element_desc AS ClassCD_Desc
,CodesToSysType AS ClassCD_SystemType

From codes_table
Where tbl_type_code LIKE '%PCC%'
And code_status = 'A'

--Order by tbl_element_desc
),


CTE_ClassCDChange AS (
SELECT
grobed.Id AS LRSN-- Id is RevObjId is lrsn
,grobed.BegEffDate
,grobed.TranId
,grobed.GeoCd
,grobed.ClassCd
--,grobed.ClassCd AS ClassCd_Today
,sys.ClassCD AS ClassCd_Jan1
,sys.ClassCD_Desc AS ClassCdDesc_Jan1


,TRIM(grobed.PIN) AS PIN
,TRIM(grobed.UnformattedPIN) AS UnformattedPIN
,TRIM(grobed.AIN) AS AIN
,ROW_NUMBER() OVER (PARTITION BY grobed.Id ORDER BY grobed.BegEffDate DESC) AS RowNumber

From RevObj AS grobed
LEFT JOIN CTE_PCC_to_System AS sys
  ON grobed.ClassCd = sys.ClassCD_SystemType


Where BegEffDate BETWEEN @Jan1ThisYear1 AND @Jan1ThisYear2

--Where BegEffDate = @Today

)


SELECT *
FROM CTE_ClassCDChange
--WHERE RowNumber > 1
--AND LRSN = 541934
WHERE LRSN = 541934





