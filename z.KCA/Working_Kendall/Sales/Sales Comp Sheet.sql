-- !preview conn=con
WITH
CTE_CommUse AS (
  SELECT DISTINCT
    cu.lrsn,
    cu.css_use,
    TRIM(utc.use_description) AS use_description

  FROM comm_uses AS cu
  JOIN use_type_codes AS utc ON cu.css_use = utc.css_use

  WHERE cu.status = 'A'
),

CTE_Use AS (
  SELECT DISTINCT
    cteu.lrsn, 
    STRING_AGG(cteu.use_description, ', ') AS [alluses]

  FROM CTE_CommUse AS cteu
  GROUP BY 
    cteu.lrsn
)

SELECT DISTINCT
    parcel.lrsn,
    TRIM(parcel.pin) AS [PIN],
    TRIM(parcel.ain) AS [AIN],
    t.pxfer_date AS [Sale Date],
    t.AdjustedSalePrice AS [Sales Price],
    parcel.LegalAcres AS [Acres],
    SUM(cb.total_area) OVER (PARTITION BY parcel.lrsn) AS [Bldg SF],
    CAST((parcel.LegalAcres * 43560) AS INT) AS [Land SF],
    parcel.WorkValue_Land AS [Land Value],
    parcel.WorkValue_Impv AS [Improvement Value],
    parcel.WorkValue_Total AS [Total Assessed Value],
    (parcel.WorkValue_Total/CAST((t.AdjustedSalePrice)AS DECIMAL)*100) AS [Ratio],
    CASE
      WHEN parcel.WorkValue_Impv = '0' THEN (t.AdjustedSalePrice/CAST((parcel.LegalAcres * 43560) AS DECIMAL))
      ELSE NULL
    END AS [Sale Price Per Land SF Value],
    CASE
      WHEN parcel.WorkValue_Impv <> '0' THEN (t.AdjustedSalePrice/CAST((SUM(cb.total_area) OVER (PARTITION BY parcel.lrsn))AS DECIMAL))
      ELSE NULL
    END AS [Sale Price Per Bldg SF Value],
    TRIM(parcel.SitusAddress) AS [Situs Address],
    CASE
      WHEN parcel.WorkValue_Impv = '0' THEN 'Land'
      ELSE cute.alluses 
      END AS [Use],
    TRIM(parcel.PropClassDescr) AS [PCC],
    t.TfrType AS [Transfer Type]
    
FROM TSBv_PARCELMASTER AS parcel
JOIN transfer AS t ON parcel.lrsn = t.lrsn
AND t.pxfer_date > '2022-01-01'
AND t.pxfer_date < '2023-01-01'
AND t.AdjustedSalePrice <> '0'
LEFT JOIN comm_bldg AS cb ON parcel.lrsn = cb.lrsn
AND cb.status = 'A'
LEFT JOIN CTE_Use AS cute ON cute.lrsn = parcel.lrsn

WHERE parcel.neighborhood = '38'
  AND parcel.EffStatus = 'A'