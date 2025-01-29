-- !preview conn=con

/*
AsTxDBProd
GRM_Main

199000
Green Ferry


*/
--------------------------------
--ParcelMaster
--------------------------------

Select Distinct
COUNT(pm.lrsn) AS [Parcel_Count],
LTRIM(RTRIM(pm.TAG)) AS [TAG]

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.TAG IN ('119000','119500')

Group By
pm.TAG

Order By 
Parcel_Count DESC;



