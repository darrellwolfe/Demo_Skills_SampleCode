-- !preview conn=con
/*
AsTxDBProd
GRM_Main
LTRIM(RTRIM())
*/

SELECT DISTINCT
  parcel.neighborhood,
  LTRIM(RTRIM(parcel.AIN)) AS [AIN],
  LTRIM(RTRIM(parcel.pin)) AS [PIN],
  p.permit_ref AS [Permit No.],
  p.permit_type,
  MONTH(p.inactivedate) AS [Month],
  p.inactivedate,
  fv.field_person,
  fv.date_completed
FROM TSBv_PARCELMASTER as parcel
  JOIN permits AS p on parcel.lrsn = p.lrsn
    AND p.status = 'I'
    AND p.inactivedate >= '2023-01-01'
    AND p.inactivedate <= '2023-12-31'
  JOIN field_visit AS fv ON p.field_number = fv.field_number
    AND fv.date_completed IS NOT NULL
WHERE parcel.EffStatus = 'A'
  AND parcel.neighborhood >= '1'
  AND parcel.neighborhood <= '999'
    OR parcel.neighborhood = '1000'
    OR parcel.neighborhood = '1020'
    OR parcel.neighborhood = '5000'
    OR parcel.neighborhood = '5002'
    OR parcel.neighborhood = '6000'
    OR parcel.neighborhood = '6002'
    OR parcel.neighborhood >= '9000'
    
;