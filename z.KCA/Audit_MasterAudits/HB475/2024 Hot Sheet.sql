/*
AsTxDBProd
GRM_Main
*/
-- !preview conn=con

SELECT
parcel.neighborhood,
  CASE
    WHEN parcel.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN parcel.neighborhood >= 6003 THEN 'District_6'
    WHEN parcel.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN parcel.neighborhood = 6001 THEN 'District_6'
    WHEN parcel.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN parcel.neighborhood >= 5003 THEN 'District_5'
    WHEN parcel.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN parcel.neighborhood = 5001 THEN 'District_5'
    WHEN parcel.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN parcel.neighborhood >= 4000 THEN 'District_4'
    WHEN parcel.neighborhood >= 3000 THEN 'District_3'
    WHEN parcel.neighborhood >= 2000 THEN 'District_2'
    WHEN parcel.neighborhood >= 1021 THEN 'District_1'
    WHEN parcel.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN parcel.neighborhood >= 1001 THEN 'District_1'
    WHEN parcel.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN parcel.neighborhood >= 451 THEN 'Commercial'
    WHEN parcel.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN parcel.neighborhood >= 1 THEN 'Commercial'
    WHEN parcel.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District,
TRIM(parcel.ain) AS [AIN],
TRIM(parcel.pin) AS [PIN], 
parcel.SitusAddress,
    CASE
      WHEN m.memo_line_number = '1' THEN m.memo_text
      ELSE NULL
    END AS MemoLine1,
    CASE
      WHEN m.memo_line_number = '2' THEN m.memo_text
      ELSE NULL
    END AS MemoLine2

FROM TSBv_PARCELMASTER as parcel
JOIN memos AS m ON parcel.lrsn=m.lrsn

WHERE parcel.EffStatus= 'A'
AND m.memo_id= 'NC24'
;