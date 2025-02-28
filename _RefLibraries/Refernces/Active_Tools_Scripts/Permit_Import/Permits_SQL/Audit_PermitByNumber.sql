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

Where permit_ref IN ('RES22-1273')