SELECT 
 v.lrsn,
  LTRIM(RTRIM(parcel.pin)) AS [PIN], 
  LTRIM(RTRIM(parcel.ain)) AS [AIN], 
  parcel.neighborhood AS [GEO],
 --Certified Values
 v.land_market_val AS [Cert Land],
 v.imp_val AS [Cert Imp],
 (v.imp_val + v.land_market_val) AS [Cert Total Value],
 v.eff_year AS [Tax Year],
  v.last_update

  FROM valuation AS v
  Join KCv_PARCELMASTER1 AS parcel ON parcel.lrsn=v.lrsn
    AND parcel.EffStatus = 'A'

  WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
  AND v.status = 'A'
  AND v.last_update BETWEEN '2023-05-20' AND '2023-06-09'  
  --AND v.last_update BETWEEN '2023-06-10' AND '2023-06-16' 
  --AND v.last_update BETWEEN '2023-06-17' AND '2023-06-23' 
  --AND v.last_update BETWEEN '2023-06-24' AND '2023-06-26'