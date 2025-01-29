
-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

declare @db varchar(12)
if not exists (select * from preferences where userid = 'system' and prefsection = 'config' and prefentry = 'integration' and prefvalue = 'records')
set @db='proval'
else
set @db='grm'

if (@db='proval')
*/

/*
SELECT 	PB.lrsn, R.method as ReconMethod, A.method as allocationMethod, A.group_code, A.cost_value, PB.status, PB.parcel_flags,
	R.status as ReconStatus, PB.parcel_id, PB.county_number, PB.neighborhood, PB.tax_bill_id, PB.Property_Class

From PARCEL_BASE PB 

LEFT OUTER JOIN reconciliation R 
  ON 	PB.lrsn=R.lrsn
INNER JOIN allocations A 
  ON 	R.lrsn=A.lrsn
  and 	A.status='A'

WHERE  	PB.parcel_flags=21 
AND 	(
	R.method='C' AND A.method='C' OR R.method='M' AND A.method='C' OR R.method='R' 
	AND A.method='O' OR R.method='I' AND A.group_code>'29' AND A.method='I' OR R.method='I' 
	AND A.group_code<'30' AND A.method='C' OR R.method='S' AND A.group_code>'29' 
	AND A.method='S' OR R.method='S' AND A.group_code<'30' AND A.method='C' OR R.method='O' 
	AND A.method='O'
	) 
AND 	R.status='W' 
AND 	(
	PB.parcel_id LIKE 'LR%' OR PB.parcel_id LIKE 'MH%' OR PB.parcel_id LIKE 'RP%' 
	OR PB.parcel_id LIKE 'SC%'
	) 
AND  	PB.status='A'
AND 	PB.neighborhood<9999999 
AND 	A.status='A'

ORDER BY PB.neighborhood, PB.parcel_id

else
*/

SELECT 	PB.lrsn, R.method as ReconMethod, A.method as allocationMethod, A.group_code, A.cost_value, PB.status, PB.parcel_flags
	, R.status as ReconStatus, PB.parcel_id, PB.county_number, PB.neighborhood, PB.tax_bill_id, PM.ClassCd as Property_Class
FROM   	TSBv_PARCELMASTER PM
INNER JOIN PARCEL_BASE PB 
ON 	PB.lrsn=PM.lrsn
LEFT OUTER JOIN reconciliation R 
ON 	PB.lrsn=R.lrsn
INNER JOIN allocations A 
ON 	R.lrsn=A.lrsn
and 	A.status='A'
WHERE  	PB.parcel_flags=21 
AND 	(
	R.method='C' AND A.method='C' OR R.method='M' AND A.method='C' OR R.method='R' 
	AND A.method='O' OR R.method='I' AND A.group_code>'29' AND A.method='I' OR R.method='I' 
	AND A.group_code<'30' AND A.method='C' OR R.method='S' AND A.group_code>'29' 
	AND A.method='S' OR R.method='S' AND A.group_code<'30' AND A.method='C' OR R.method='O' 
	AND A.method='O'
	) 
AND 	R.status='W' 
AND 	(
	PB.parcel_id LIKE 'LR%' OR PB.parcel_id LIKE 'MH%' OR PB.parcel_id LIKE 'RP%' 
	OR PB.parcel_id LIKE 'SC%'
	) 
AND  	PM.effstatus='A'
AND 	PB.neighborhood<9999999 
AND 	A.status='A'
ORDER BY PB.neighborhood, PB.parcel_id
