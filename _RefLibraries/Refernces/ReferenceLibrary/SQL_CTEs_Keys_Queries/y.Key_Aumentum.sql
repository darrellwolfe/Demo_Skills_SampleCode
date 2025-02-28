/*
AsTxDBProd
GRM_Main
*/


----------------------
--Aumentum Tests
---------------------



WITH 
  CTE_SumOverride AS (
    SELECT 
      lrsn,
      ain,
      SUM(OverrideAmount) AS [SumOverrideAmount]
    FROM TSBv_MODIFIERS
    WHERE PINStatus = 'A' AND ModifierStatus = 'A'
    GROUP BY lrsn, ain
  ),

  CTE_Cert AS (
    SELECT 
      lrsn,
      --Certified Values
      v.land_market_val AS [Cert Land],
      v.imp_val AS [Cert Imp],
      (v.imp_val + v.land_market_val) AS [Cert Total Value],
      v.eff_year AS [Tax Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
      AND v.status = 'A'
  ),

  CTE_Assessed AS (
    SELECT 
      lrsn,
      --Assessed Values
      v.land_assess AS [Assessed Land],
      v.imp_assess AS [Assessed Imp],
      (v.imp_assess + v.land_assess) AS [Assessed Total Value],
      v.eff_year AS [Tax Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
      AND v.status = 'A'
  )

SELECT 
  parcel.lrsn,
  LTRIM(RTRIM(parcel.pin)) AS [PIN], 
  LTRIM(RTRIM(parcel.ain)) AS [AIN], 
  parcel.neighborhood AS [GEO],
  parcel.Acres,
  parcel.ClassCD,
  --Certified Values
  crt.[Cert Land],
  crt.[Cert Imp],
  crt.[Cert Total Value],
  --Assessed Values
  asd.[Assessed Land],
  asd.[Assessed Imp],
  asd.[Assessed Total Value],
  --Minus All Exemptions
  so.[SumOverrideAmount],
  --Net Taxable
  CASE
    WHEN so.[SumOverrideAmount] > 0 THEN asd.[Assessed Total Value] - so.[SumOverrideAmount]
    ELSE asd.[Assessed Total Value]
  END AS [NetTaxable]
FROM KCv_PARCELMASTER1 AS parcel
LEFT JOIN CTE_Cert AS crt ON parcel.lrsn = crt.lrsn
LEFT JOIN CTE_Assessed AS asd ON parcel.lrsn = asd.lrsn
LEFT JOIN CTE_SumOverride AS so ON parcel.lrsn = so.lrsn
WHERE parcel.EffStatus = 'A'
ORDER BY [GEO], [PIN];




----------------------
--Aumentum Tests
----------------------

Select
bmv.RollCaste,
bmv.RollType,
bmv.ValueType,
--Join ValueType Table
vt.TranId,
vt.ShortDescr,
vt.Descr,
--
bmv.BillValueType,
bmv.ShowZeroValue,
bmv.Multiplier,
bmv.SectionNumber,
bmv.BillDocType


From BillValueMap AS bmv
Left Join ValueType AS vt ON bmv.ValueType=vt.Id

--Seems to be a Bill Key
Select * 
From BillValueMap

--!!!! ValueType < This is a key table defining ValueTypes in other tables

Select * 
From ValueType

Select *
From VTCalc_V

Select *
From val_detailKC_V

Select *
From TSBv_PARCELMASTER

Select *
From tsbv_NewConst--Empty table, wah wah wah

Select *
From TSBv_MODIFIERS


Select *
From

Select *
From

Select *
From

Select *
From

Select *
From

Select *
From

Select *
From

Select *
From

Select *
From


----------------
--Modifer Test
----------------
   SELECT 
      lrsn,
      ain,
      ModifierDescr,
      OverrideAmount

      FROM TSBv_MODIFIERS
    WHERE PINStatus = 'A' 
AND ModifierStatus = 'A'
AND ModifierDescr LIKE '602G Residential Improvements - Homeowners'
AND ExpirationYear > 2022
   


