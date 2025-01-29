-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

Select Distinct
vt.id
,vt.ShortDescr
,vt.Descr
From ValueType AS vt
   
Order By vt.ShortDescr
-- From tsbv_cadastre AS c 
   --On vt.id = c.ValueType
   --And vt.ShortDescr 
