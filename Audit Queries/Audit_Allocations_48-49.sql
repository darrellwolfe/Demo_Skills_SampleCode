/*
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
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(a.group_code)) AS [Imp GroupCode],
LTRIM(RTRIM(a.property_class)) AS [Property ClassCode (PCC)],
a.extension AS [Record],
a.improvement_id AS [ImpId],
CONVERT(VARCHAR, a.last_update, 101) AS [LastUpdate],
    v.land_market_val AS [Cert Land],
    v.imp_val AS [Cert Imp],
    (v.imp_val + v.land_market_val) AS [Cert Total Value],
    v.valuation_comment AS [Val Comment],
    v.eff_year AS [Tax Year],
    v.last_update AS [Last_Updated]



FROM KCv_PARCELMASTER1 AS parcel
JOIN allocations AS a ON parcel.lrsn=a.lrsn 
  AND a.status='A'
  AND (LTRIM(RTRIM(a.group_code)) NOT LIKE '81%'
      AND LTRIM(RTRIM(a.group_code)) NOT LIKE '81L%'
      AND LTRIM(RTRIM(a.group_code)) NOT LIKE '98%'
      AND LTRIM(RTRIM(a.group_code)) NOT LIKE '99%')
  
  AND (LTRIM(RTRIM(a.group_code)) LIKE '49%'
      OR LTRIM(RTRIM(a.group_code)) LIKE '48%'
      )

LEFT JOIN valuation AS v ON parcel.lrsn = v.lrsn
  AND v.status = 'A'
  AND v.eff_year BETWEEN 20230101 AND 20231231


WHERE parcel.EffStatus= 'A'
  AND parcel.neighborhood <> 0
  AND parcel.neighborhood IS NOT NULL



-- We are auditing for 99 and 98 seperately
-- 81 and 81L are a special class to be handled sperately

ORDER BY parcel.neighborhood, parcel.pin;
