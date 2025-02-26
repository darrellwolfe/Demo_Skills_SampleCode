-- !preview conn=con
/*
-- Auditor_EastSideDistParcels
AsTxDBProd
GRM_Main
*/
/*
TaxAuthirtyId | TaxAuthority
228 | 228-EASTSIDE HIGHWAY #3                                         
228 | 228-EASTSIDE HWY                                                
1084 | 228-EASTSIDE HIGHWAY #3-CDA                                     
1086 | 228-EASTSIDE HIGHWAY #3-FERNAN                                  
1088 | 228-EASTSIDE HIGHWAY #3-HARRISN  

250 | 250-EAST SIDE FIRE                                              
250 | 250-EAST SIDE FIRE DIST     

--Fernan
204 | 204-CITY FERNAN LAKE                                            
204 | 204-CITY OF FERNAN                                              
204 | 204-FERNAN                                                      
1086 | 228-EASTSIDE HIGHWAY #3-FERNAN 

--Harrison
205 | 205-CITY HARRISON                                               
205 | 205-CITY OF HARRISON                                            
205 | 205-HARRISON              
--CDA
202 | 202-CITY CDA      
*/

--DECLARE @Year INT = 2023;  -- Change this value to 2022 or 2024 as desired


WITH 

CTE_EastSideHwy AS (

SELECT DISTINCT
  ta.Id AS TaxAuthorityId,
  --ta.Descr AS TaxAuthority
  CASE
    WHEN ta.Id = '228' THEN '228-EASTSIDE HIGHWAY #3'
    WHEN ta.Id = '1084' THEN '228-EASTSIDE HIGHWAY #3-CDA'
    WHEN ta.Id = '1086' THEN '228-EASTSIDE HIGHWAY #3-FERNAN'
    WHEN ta.Id = '1088' THEN '228-EASTSIDE HIGHWAY #3-HARRISN'
  --  WHEN ta.Id = '250' THEN '250-EAST SIDE FIRE DIST'
  --  WHEN ta.Id = '202' THEN '202-CITY CDA'
  --  WHEN ta.Id = '205' THEN '205-CITY OF HARRISON'
  --  WHEN ta.Id = '204' THEN '204-CITY OF FERNAN LAKE'
    
    ELSE 'Review TaxAuthority Id'
  END AS TaxAuthorityName
  
  FROM TaxAuthority AS ta
  
  WHERE ta.Descr LIKE '%East%'
  AND ta.Id IN ('228','1084','1086','1088')
;
),

CTE_AssessedValuesWithTAG AS (
  SELECT 
        v.lrsn,
        TRIM(pm.TAG) AS TAG,
        --Assessed Values
        v.land_assess AS [Assessed Land],
        v.imp_assess AS [Assessed Imp],
CONVERT(BIGINT, (v.imp_assess + v.land_assess)) AS [Assessed Total Value],
        v.eff_year AS [Tax Year],
        ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn=v.lrsn
  WHERE v.eff_year BETWEEN 20230101 AND 20232131 
  --WHERE v.eff_year BETWEEN (@Year * 10000 + 101) AND (@Year * 10000 + 1231)  -- Calculating start and end dates of the year
  AND v.status = 'A'
  ;
),

CTE_TAG_TA_TIF_Key AS (
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
  ;
)


SELECT DISTINCT
east.TaxAuthorityId,
east.TaxAuthorityName,
tagkey.TAG,
CONVERT(BIGINT, SUM(value.[Assessed Total Value])) AS TagValue

--CTE TAG TA TIFs Key
FROM CTE_EastSideHwy AS east
--CTE East Side Highway
JOIN CTE_TAG_TA_TIF_Key AS tagkey
  ON east.TaxAuthorityId = tagkey.TaxAuthId
--CTE CERT Values
JOIN CTE_AssessedValuesWithTAG AS value
  ON value.TAG = tagkey.TAG
  AND value.RowNumber = 1

GROUP BY
east.TaxAuthorityId,
east.TaxAuthorityName,
tagkey.TAG