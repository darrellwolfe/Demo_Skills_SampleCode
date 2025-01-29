-- !preview conn=conn

SELECT DISTINCT
  tag.ShortDescr
  ,tif.BegEffYear
  ,tif.ShortDescr
  ,tif.Descr
  ,tif.StartYear
  ,tif.EndYear
  ,tif.BaseValueYear
  ,tif.ExpirationDate
  ,tif.BaseRateYear
  
FROM TAG AS tag
  JOIN TAGTIF AS tt ON tag.Id = tt.TAGId
  JOIN TIF AS tif ON tt.TIFId = tif.Id
  
WHERE tt.EffStatus = 'A'

ORDER BY tif.ShortDescr
