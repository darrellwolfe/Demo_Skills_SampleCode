DECLARE @TaxYear INT = 2024;
DECLARE @CurrentYear INT = 20240101;

SELECT DISTINCT
  TRIM(i.GeoCd) AS GEO,
  CASE
    WHEN i.GeoCd >= 9000 THEN 'Manufactured_Homes'
    WHEN i.GeoCd >= 6003 THEN 'District_6'
    WHEN i.GeoCd = 6002 THEN 'Manufactured_Homes'
    WHEN i.GeoCd = 6001 THEN 'District_6'
    WHEN i.GeoCd = 6000 THEN 'Manufactured_Homes'
    WHEN i.GeoCd >= 5003 THEN 'District_5'
    WHEN i.GeoCd = 5002 THEN 'Manufactured_Homes'
    WHEN i.GeoCd = 5001 THEN 'District_5'
    WHEN i.GeoCd = 5000 THEN 'Manufactured_Homes'
    WHEN i.GeoCd >= 4000 THEN 'District_4'
    WHEN i.GeoCd >= 3000 THEN 'District_3'
    WHEN i.GeoCd >= 2000 THEN 'District_2'
    WHEN i.GeoCd >= 1021 THEN 'District_1'
    WHEN i.GeoCd = 1020 THEN 'Manufactured_Homes'
    WHEN i.GeoCd >= 1001 THEN 'District_1'
    WHEN i.GeoCd = 1000 THEN 'Manufactured_Homes'
    WHEN i.GeoCd >= 451 THEN 'Commercial'
    WHEN i.GeoCd = 450 THEN 'Specialized_Cell_Towers'
    WHEN i.GeoCd >= 1 THEN 'Commercial'
    WHEN i.GeoCd = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District,
  i.RevObjId AS LRSN,
  TRIM(i.PIN) AS PIN,
  TRIM(i.AIN ) AS AIN,
  CAST(CAST(v.eff_year AS VARCHAR(8)) AS DATE) AS OccDate,
  FORMAT(c.ValueAmount,'n0') AS Cadaster_Value,
  c.TypeCode AS CadasterValueType,
  r.AssessmentYear,
  TRIM(c.ChgReasonDesc) AS ChangeReason

FROM CadRoll AS r
  JOIN CadLevel AS l ON r.Id = l.CadRollId
  JOIN CadInv AS i ON l.Id = i.CadLevelId
  JOIN tsbv_cadastre AS c ON c.CadRollId = r.Id
    AND c.CadInvId = i.Id
  JOIN ValueType AS vt ON vt.id = c.ValueType
    AND vt.ShortDescr LIKE '%Months%'
  JOIN valuation AS v ON i.RevObjId = v.lrsn
    AND v.eff_year > @CurrentYear
    AND v.status = 'A'

WHERE r.AssessmentYear IN (@TaxYear)
  --AND c.ChgReasonDesc = '06- Occupancy'
  --AND c.ChgReasonDesc = '38- Subsequent Assessment'

ORDER BY ChangeReason, District, PIN;