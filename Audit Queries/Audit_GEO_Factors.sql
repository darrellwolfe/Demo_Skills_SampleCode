
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

*/

SELECT 

nf.neighborhood AS [GEO],
nf.nei_rating AS [Rating],
nf.cost_or_market AS [Cost_Market],
nf.value_mod_default AS [DefaultType],
nf.value_mod_other AS [OtherType],
nf.res_model_serial AS [ModelYear],
nf.last_update_long AS [LastUpdated],
nf.UserID AS [UpdatedBy]

FROM neigh_res_impr as nf -- Nieghborhood Factor

WHERE nf.status='A'
AND nf.inactivate_date='99991231'
AND nf.res_model_serial='2023'
--Filter by desired year

ORDER BY nf.neighborhood;
