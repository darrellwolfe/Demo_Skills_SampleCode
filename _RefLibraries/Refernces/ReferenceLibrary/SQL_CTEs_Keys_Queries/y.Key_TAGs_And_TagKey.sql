


--Value Types

SELECT DISTINCT
vt.Id
, vt.ShortDescr
, vt.Descr

FROM ValueType AS vt
  --on vt.id = c.ValueType

ORDER BY vt.ShortDescr



---- TAGs

  SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ta.Id AS TaxAuthId,
  TRIM(ta.Descr) AS TaxAuthority
  --TAG Table
  FROM TAG AS tag
  --TAGTIF Key
  LEFT JOIN TAGTIF 
    ON TAG.Id=TAGTIF.TAGId 
    AND TAGTIF.EffStatus = 'A'
  --TIF Table
  LEFT JOIN TIF AS tif 
    ON TAGTIF.TIFId=TIF.Id 
    AND TIF.EffStatus  = 'A'
  --TAGTaxAuthority Key
  LEFT JOIN TAGTaxAuthority 
    ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
  --TaxAuthority Table
  LEFT JOIN TaxAuthority AS ta 
    ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
  --CTE_ JOIN, only want TAGs in this TaxAuth
  
  WHERE tag.EffStatus = 'A'
  
  
  
---- Key
  
SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ta.Id AS TaxAuthId,
  TRIM(ta.Descr) AS TaxAuthority,
  -- Add a CASE statement for tag categorization
  CASE
    WHEN TRIM(tag.Descr) LIKE '%%%500' THEN 'No fire, no FC, no watershed. OP ONLY. 001-500'
    WHEN TRIM(tag.Descr) LIKE '%%%600' THEN 'No FC, no watershed, but incl fire. OP ONLY. 001-600'
    WHEN TRIM(tag.Descr) LIKE '%%%700' THEN 'No FC, no watershed. PP ONLY'
    WHEN TRIM(tag.Descr) LIKE '%%%0%%' THEN 'All Tax Authorities 001-000'
    ELSE 'Uncategorized'
  END AS TagCategory
-- rest of your query remains unchanged
FROM TAG AS tag
LEFT JOIN TAGTIF 
  ON TAG.Id=TAGTIF.TAGId 
  AND TAGTIF.EffStatus = 'A'
LEFT JOIN TIF AS tif 
  ON TAGTIF.TIFId=TIF.Id 
  AND TIF.EffStatus  = 'A'
LEFT JOIN TAGTaxAuthority 
  ON TAG.Id=TAGTaxAuthority.TAGId 
  AND TAGTaxAuthority.EffStatus = 'A'
LEFT JOIN TaxAuthority AS ta 
  ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
  AND ta.EffStatus = 'A'
WHERE tag.EffStatus = 'A'
--AND tag.Descr LIKE '%%%500'