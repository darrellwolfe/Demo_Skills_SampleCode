-- !preview conn=con
/*
AsTxDBProd
GRM_Main

LAND LEGEND EDIT TOOL

*/

SELECT 
  p.lrsn AS [LRSN],
  p.neighborhood AS [GEO],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  TRIM(ld.LandType) AS [Land_Type],
  ld.lcm AS [Pricing_Method],
  CASE 
    WHEN TRIM(c.tbl_element_desc) = 'No View' THEN '1'
    WHEN TRIM(c.tbl_element_desc) = 'Average View' THEN '2'
    WHEN TRIM(c.tbl_element_desc) = 'Good View' THEN '3'
    WHEN TRIM(c.tbl_element_desc) = 'Excellent View' THEN '4'
    WHEN TRIM(c.tbl_element_desc) LIKE 'Legend %' THEN REPLACE (TRIM(c.tbl_element_desc), 'Legend ', '')
    ELSE TRIM(c.tbl_element_desc)
  END AS [Legend],
  TRIM(c.tbl_element_desc) AS [Legend_Desc],
  ld.BaseRate AS [Base_Rate]
  
FROM LandHeader AS lh
JOIN LandDetail AS ld on lh.Id = ld.LandHeaderId
  AND ld.EffStatus = 'A'
  AND ld.PostingSource = 'A'
JOIN TSBv_PARCELMASTER AS p ON lh.RevObjId = p.lrsn
  AND p.neighborhood BETWEEN '1' AND '999'
  AND p.EffStatus = 'A'
JOIN codes_table AS c ON ld.SiteRating = c.tbl_element
  AND c.tbl_type_code = 'siterating'
WHERE lh.EffStatus = 'A'
  AND lh.PostingSource = 'A'
  AND lh.LandModelId = '702023'
ORDER BY p.pin ASC
  