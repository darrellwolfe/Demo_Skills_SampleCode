-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

res_floor.finish_living_area
rf.finish_living_area


rf.lrsn,
rf.br_count,
((rf.fix_2_count/2) + rf.fix_3_count + rf.fix_4_count + rf.fix_5_count) AS Test

CTE_BedBath

*/




--CTE_BedBath AS (
Select
dw.lrsn,
dw.bedrooms,
dw.full_baths,
dw.half_baths,
(dw.full_baths+(dw.half_baths/2)) AS Bath_Total

From dwellings AS dw
Where dw.status='A'
--And dw.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home and MH Examples
--),


