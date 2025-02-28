



DECLARE @Year1 INT = '20220101';

DECLARE @Year2 INT = '20230101';


CTE_LandSize AS (

Select
Count(lrsn)
/*
Lrsn
,Property_class
,TRIM(Group_code) AS Group_code
,LEFT(TRIM(Group_code),2) AS State_Code
,Line_number
,Land_use_seq_no
,Acreage
,Eff_year
,Last_update_long
,Val_seq_no
,Status
*/

From LandSize
Where Status = 'A'
--And Eff_year IN (@Year1,@Year2)
And Eff_year = '20230101'
--And group_code IN ('01','02','03','04','05')
And group_code = '03'
)