-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

/*
Select Distinct
patype
,areaunit
From parcelarea
Order by patype, areaunit
*/

Select * From systype
--Where Id IN (101050,101051,1307067,1307073)
Where Id IN (100800,100801,1307034,7307035,200027,2000028)




