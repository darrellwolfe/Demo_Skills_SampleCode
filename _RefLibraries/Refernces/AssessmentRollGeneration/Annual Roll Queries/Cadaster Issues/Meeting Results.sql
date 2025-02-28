-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
Select * From Improvements Where 2024
Join Improvements Where 2023

Val_Detail

*/


Select Distinct
r.lrsn
,r.status
,r.last_update
,r.date_cert
,r.method
,r.assess_imp
,r.assess_land
,r.land_price_date
,r.land_model
From reconciliation AS r
Where r.date_cert LIKE '2024%'
And r.last_update > '2024-05-06'
