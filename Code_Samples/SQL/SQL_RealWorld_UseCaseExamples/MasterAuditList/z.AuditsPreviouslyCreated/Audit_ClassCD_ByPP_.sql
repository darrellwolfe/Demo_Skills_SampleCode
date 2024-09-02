
/*
Invoke (twice):
fx GetRevObjByEffDate
01/01/2023
05/01/2023
Merge with this:
*/



SELECT 
  parcel.lrsn,
  LTRIM(RTRIM(parcel.pin)) AS [PIN], 
  LTRIM(RTRIM(parcel.ain)) AS [AIN], 
  LTRIM(RTRIM(a.property_class)),
a.last_update

FROM KCv_PARCELMASTER1 AS parcel
INNER JOIN allocations AS a ON parcel.lrsn=a.lrsn

WHERE parcel.EffStatus= 'A'
AND parcel.pin LIKE 'E%'
AND a.last_update > DATEFROMPARTS(2023,1,1)
AND a.property_class IN (20,21,22,30,32,60,70)
    
ORDER BY parcel.pin;
