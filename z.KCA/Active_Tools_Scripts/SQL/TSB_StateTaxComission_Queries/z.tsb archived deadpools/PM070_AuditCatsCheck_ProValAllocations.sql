-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

Select *
From Allocations

Where status = 'H'
And eff_year = '20230101'
And group_code IN ('01','02','03','04','05')


*/


DECLARE @eff_year INT = '20230101'

Select
a.group_code
,Count(a.lrsn) AS Count


/*
a.lrsn
,a.extension
,a.group_code
,a.property_class
,a.eff_year
,a.cost_value
,a.market_value
,a.recon_value
*/
FROM Allocations AS a
LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'impgroup'

Where a.eff_year = @eff_year
And a.status = 'H'
And a.group_code IN ('01','02','03','04','05')
Group By a.group_code



