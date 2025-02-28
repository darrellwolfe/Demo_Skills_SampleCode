
/*
AsTxDBProd
GRM_Main
*/


WITH 
CTE_CertValuesEnd AS (

  SELECT 
      v.lrsn,
      v.land_market_val AS [Cert Land],
      v.imp_val AS [Cert Imp],
      (v.imp_val + v.land_market_val) AS [Cert Total Value],
      v.valuation_comment AS [Val Comment],
      v.eff_year AS [Tax Year],
      v.last_update AS [Last_Updated],
  ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update 
  --ASC) AS RowNum
  DESC) AS RowNum
  
  FROM valuation AS v
  
  WHERE v.status = 'A'
    AND v.eff_year BETWEEN 20230101 AND 20231231
    --Change dates for desired year
    --AND  v.lrsn= '4943' --Used as Test
  ),

CTE_CertValuesStart AS (

  SELECT 
      v.lrsn,
      v.land_market_val AS [Cert Land],
      v.imp_val AS [Cert Imp],
      (v.imp_val + v.land_market_val) AS [Cert Total Value],
      v.valuation_comment AS [Val Comment],
      v.eff_year AS [Tax Year],
      v.last_update AS [Last_Updated],
  ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update 
  ASC) AS RowNum
  --DESC) AS RowNum
  
  FROM valuation AS v
  
  WHERE v.status = 'A'
    AND v.eff_year BETWEEN 20230101 AND 20231231
    --Change dates for desired year
    --AND  v.lrsn= '4943' --Used as Test
  )


SELECT DISTINCT
--Account Details
parcel.lrsn,
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner],
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
CONCAT(LTRIM(RTRIM(parcel.ain)),',') AS [AIN_LookUp],
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
--Permit Data
LTRIM(RTRIM(p.permit_ref)) AS [REFERENCE#],
LTRIM(RTRIM(p.permit_desc)) AS [DESCRIPTION],
LTRIM(RTRIM(c.tbl_element_desc)) AS [PERMIT_TYPE],
p.filing_date AS [FILING DATE],
f.field_out AS [WORK ASSIGNED DATE],
f.field_in AS [WORK DUE DATE],

f.need_to_visit AS [NEED TO VISIT], 
LTRIM(RTRIM(f.field_person)) AS [APPRAISER],
f.date_completed AS [COMPLETED DATE],

--NOTES, CONCAT allows one line of notes instead of duplicate rows
m2.memo_id AS [MEMO ID],
LTRIM(RTRIM(m3.memo_text)) AS [MemoText],
LTRIM(RTRIM(p.permit_source)) AS [PERMIT SOURCE],
--Acres
parcel.Acres,
--End SELECT

CAST(b4.[Cert Land] AS DECIMAL(10, 2)) AS [Land Before],
CAST(b4.[Cert Imp] AS DECIMAL(10, 2)) AS [Imp Before],
CAST(b4.[Cert Total Value] AS DECIMAL(10, 2)) AS [Total Before],
b4.[Last_Updated] AS [Start],

CAST(af.[Cert Land] AS DECIMAL(10, 2)) AS [Land After],
CAST(af.[Cert Imp] AS DECIMAL(10, 2)) AS [Imp After],
CAST(af.[Cert Total Value] AS DECIMAL(10, 2)) AS [Total After],
af.[Last_Updated] AS [End],

CAST((af.[Cert Total Value] - b4.[Cert Total Value]) AS DECIMAL(10, 2)) AS [Difference$],

CASE
  WHEN (af.[Cert Total Value] / b4.[Cert Total Value]) = 1 THEN
    '0'
    
  WHEN b4.[Cert Total Value] != 0 THEN 
    CAST(af.[Cert Total Value] AS DECIMAL(10, 2)) / CAST(b4.[Cert Total Value] AS DECIMAL(10, 2))
  
  ELSE
    '999999' -- or any other value you'd like to return when there is a divide by zero
END AS [Difference%]


  
FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
     AND p.filing_date LIKE '%2023%'
 JOIN field_visit AS f ON p.field_number=f.field_number
     AND f.seq_no = 0 -- attempts to remove duplicates when additional field visits are added
     --AND f.field_out IS NOT NULL -- attempts to remove duplicates when additional field visits are added

JOIN codes_table AS c ON c.tbl_element=p.permit_type 
  AND c.tbl_type_code= 'permits'
  AND c.tbl_element_desc = 'Assessment Review'
  
LEFT JOIN memos AS m2 ON parcel.lrsn=m2.lrsn 
  AND m2.memo_id = 'AR' 
  AND m2.memo_line_number = '1'

LEFT JOIN memos AS m3 ON parcel.lrsn=m3.lrsn 
  AND m3.memo_id = 'AR'
  AND m3.memo_line_number = '2'
  AND m3.memo_text LIKE '%23%'
  AND (m3.memo_text LIKE '%DAS%'
      OR m3.memo_text LIKE '%DGW%'  
      OR m3.memo_text LIKE '%KMM%')

--CTEs
LEFT JOIN CTE_CertValuesStart AS b4 ON b4.lrsn=parcel.lrsn
  AND b4.RowNum='1'
LEFT JOIN CTE_CertValuesEnd AS af ON af.lrsn=parcel.lrsn
  AND af.RowNum='1'

WHERE parcel.EffStatus= 'A'
  --AND p.status= 'A' -- Exclude to see everything for the dataset, and not just actives
  AND c.code_status= 'A'

/*
If Filter Needed Use:

  --Open/Uncompleted
  AND NOT (f.need_to_visit='N'
  AND f.field_person IS NOT NULL
  AND f.date_completed IS NOT NULL
      )
  --Only Completed    
  AND (f.need_to_visit='N'
  AND f.field_person IS NOT NULL
  AND f.date_completed IS NOT NULL
      )
*/    

ORDER BY [GEO], [PIN], [REFERENCE#];


/*

  SELECT 
      v.lrsn
      v.land_market_val AS [Cert Land],
      v.imp_val AS [Cert Imp],
      (v.imp_val + v.land_market_val) AS [Cert Total Value],
      v.valuation_comment AS [Val Comment],
      v.eff_year AS [Tax Year],
      v.last_update AS [Last_Updated],
  ROW_NUMBER() OVER (PARTITION BY parcel.lrsn ORDER BY v.last_update 
  --ASC) AS RowNum
  DESC) AS RowNum
  
  FROM valuation AS v
  
  WHERE v.status = 'A'
    AND v.eff_year BETWEEN 20230101 AND 20231231
*/