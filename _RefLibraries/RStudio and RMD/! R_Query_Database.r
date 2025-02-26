install.packages("sqldf")
install.packages("Rtools")

library(sqldf)
library(DBI)

conn <- dbConnect(odbc::odbc(),
                 Driver = "SQL Server",
                 Server = "AsTxDBProd",
                 Database = "GRM_Main",
                 Trusted_Connection = "True")

tag_values <- dbGetQuery(conn, "WITH CTE_Tag_Tif_TaxAuth AS (
  SELECT DISTINCT
      tag.Id AS TAGId,
      TRIM(tag.Descr) AS TAG,
      tif.Id AS TIFId,
      TRIM(tif.Descr) AS TIF,
      ta.Id AS TaxAuthId,
      TRIM(ta.Descr) AS TaxAuthority
  FROM TAG AS tag
    --ON TRIM(tag.ShortDescr) = TRIM(cv.TAGShortDescr)
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
)

Select
cv.AssessmentYear,
cv.CadRollDescr,
--cv.RevObjId,
cv.TAGShortDescr,
SUM(cv.ValueAmount) AS [Certified_Value],
cv.ValueTypeShortDescr,
cv.ValueTypeDescr,
ttt.TIF,
ttt.TaxAuthId,
ttt.TaxAuthority


FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
LEFT JOIN CTE_Tag_Tif_TaxAuth AS ttt
  ON TRIM(ttt.TAG) = TRIM(cv.TAGShortDescr)
  --AND ttt.TAG IN ('010000','101000','010500','101500')
  
WHERE cv.AssessmentYear IN ('2023')
--,'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
AND cv.ValueTypeShortDescr = 'Total Value'
--AND cv.TAGShortDescr IN ('010000','101000','010500','101500')
-- Hauser TAGs 


GROUP BY
cv.AssessmentYear,
cv.CadRollDescr,
--cv.RevObjId,
cv.TAGShortDescr,
--cv.ValueAmount AS [Certified_Value],
cv.ValueTypeShortDescr,
cv.ValueTypeDescr,
ttt.TIF,
ttt.TaxAuthId,
ttt.TaxAuthority")

colnames(tag_values)
summarise(tag_values)
summary(tag_values)

sum(tag_values$Certified_Value, na.rm = TRUE)
max(tag_values$Certified_Value, na.rm = TRUE)
median(tag_values$Certified_Value, na.rm = TRUE)
mean(tag_values$Certified_Value, na.rm = TRUE)
min(tag_values$Certified_Value, na.rm = TRUE)
