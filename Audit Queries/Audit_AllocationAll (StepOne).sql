-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
Allocations Check
Compare parcels with allocations against an allocations key
I can't figure out how to use SQL to pull in the key without Python Pandos installed, and IT won't give us that yet. 
So I'm using 
(1) Power Query to pull in the Key as "connection only".
(2) then SQL to pull in the Allocations with PINs, but loading it to "connection only".
Finally, (3) Inside Power Query, Merge these two as new, matching on PCC and ImpGroupCode, loading 

AsTxDBProd
GRM_Main
*/

SELECT 
parcel.lrsn,
TRIM(parcel.pin) AS PIN, 
TRIM(parcel.ain) AS AIN, 
parcel.neighborhood AS GEO,
TRIM(a.group_code) AS Imp_GroupCode,
a.property_class AS Property_ClassCode_PCC,
a.extension AS C_or_R_Record,
a.improvement_id AS ImpId,
CONVERT(VARCHAR, a.last_update, 101) AS LastUpdate

FROM KCv_PARCELMASTER1 AS parcel
JOIN allocations AS a ON parcel.lrsn=a.lrsn AND a.status='A'


WHERE parcel.EffStatus= 'A'
AND parcel.neighborhood <> 0
AND parcel.neighborhood IS NOT NULL
AND (TRIM(a.group_code) NOT LIKE '81%'
    AND TRIM(a.group_code) NOT LIKE '81L%'
    AND TRIM(a.group_code) NOT LIKE '98%'
    AND TRIM(a.group_code) NOT LIKE '99%')


-- We are auditing for 99 and 98 seperately
-- 81 and 81L are a special class to be handled sperately

ORDER BY parcel.neighborhood, parcel.pin;
