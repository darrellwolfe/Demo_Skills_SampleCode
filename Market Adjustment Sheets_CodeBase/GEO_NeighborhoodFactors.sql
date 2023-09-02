-- !preview conn=con

/*
AsTxDBProd
GRM_Main
Geo Factor Reports
Crystal Settings
{neigh_res_impr.inactivate_date} = 99991231 and
{neigh_res_impr.res_model_serial} = 2023 and
{neigh_res_impr.neighborhood} = {?Geos} and
{neigh_res_impr.status} = "A"
Table: neigh_res_impr

CASE>
While "0" is ingored by the database and treated as 100%, the Excel workbooks cannot do that.
We CAST 0 as 1.00 or 100 to accurately reflect what is  happening in ProVal
*/


--------------------------------
--GEO_Factors
--------------------------------

SELECT 

nf.neighborhood AS [GEO],
nf.nei_rating AS [Rating],
nf.cost_or_market AS [Cost_Market],

--For MA Worksheets
CASE
  WHEN nf.value_mod_default = 0
  THEN 1.00
  ELSE CAST(nf.value_mod_default AS DECIMAL(10,2)) / 100 
END AS [Worksheet_DefaultType],
--For MA Worksheets
CASE
  WHEN nf.value_mod_other = 0
  THEN 1.00
  ELSE CAST(nf.value_mod_other AS DECIMAL(10,2)) / 100 
END AS [Worksheet_OtherType],
--For Database
CASE
  WHEN nf.value_mod_default = 0
  THEN 100
  ELSE nf.value_mod_default
END AS [Database_DefaultType],
--For Database
CASE
  WHEN nf.value_mod_other  = 0
  THEN 100
  ELSE nf.value_mod_other 
END AS [Database_OtherType],

nf.res_model_serial AS [ModelYear],
nf.last_update_long AS [LastUpdated],
nf.UserID AS [UpdatedBy]

FROM neigh_res_impr as nf -- Nieghborhood Factor

WHERE nf.status='A'
AND nf.inactivate_date='99991231'
AND nf.res_model_serial='2023'
--Filter by desired year

ORDER BY nf.neighborhood;