-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

Select *
From Permits AS p
Join TSBv_PARCELMASTER AS pm
  ON p.lrsn=pm.lrsn 
  --AND pm.EffStatus = 'A'

Where permit_ref IN ('BLDR-22-611','BLDR-22-613')