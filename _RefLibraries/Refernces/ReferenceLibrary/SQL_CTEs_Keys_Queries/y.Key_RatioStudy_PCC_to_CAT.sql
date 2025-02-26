-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/



SELECT DISTINCT
pcc.tbl_element AS PCC_Code
, TRIM(pcc.tbl_element_desc) AS PCC_Description
, CASE
    WHEN TRIM(pcc.tbl_element) = '314' THEN '14'
    WHEN TRIM(pcc.tbl_element) = '317' THEN '17'
    WHEN TRIM(pcc.tbl_element) = '322' THEN '22'
    WHEN TRIM(pcc.tbl_element) = '411' THEN '11'
    WHEN TRIM(pcc.tbl_element) = '413' THEN '13'
    WHEN TRIM(pcc.tbl_element) = '416' THEN '16'
    WHEN TRIM(pcc.tbl_element) = '421' THEN '21'
    WHEN TRIM(pcc.tbl_element) = '451' THEN '51'
    WHEN TRIM(pcc.tbl_element) = '512' THEN '12'
    WHEN TRIM(pcc.tbl_element) = '515' THEN '15'
    WHEN TRIM(pcc.tbl_element) = '520' THEN '20'
    WHEN TRIM(pcc.tbl_element) = '525' THEN '25'
    WHEN TRIM(pcc.tbl_element) = '526' THEN '26'
    WHEN TRIM(pcc.tbl_element) = '527' THEN '27'
    WHEN TRIM(pcc.tbl_element) = '546' THEN '46'
    WHEN TRIM(pcc.tbl_element) = '550' THEN '50'
    WHEN TRIM(pcc.tbl_element) = '549' THEN '49'
    WHEN TRIM(pcc.tbl_element) = '555' THEN '55'
    WHEN TRIM(pcc.tbl_element) = '565' THEN '65'
    WHEN TRIM(pcc.tbl_element) = '336' THEN '1436'
    WHEN TRIM(pcc.tbl_element) = '339' THEN '1739'
    WHEN TRIM(pcc.tbl_element) = '343' THEN '2243'
    WHEN TRIM(pcc.tbl_element) = '441' THEN '2141'
    WHEN TRIM(pcc.tbl_element) = '435' THEN '1335'
    WHEN TRIM(pcc.tbl_element) = '438' THEN '1638'
    WHEN TRIM(pcc.tbl_element) = '442' THEN '2142'
    WHEN TRIM(pcc.tbl_element) = '534' THEN '1234'
    WHEN TRIM(pcc.tbl_element) = '537' THEN '1537'
    WHEN TRIM(pcc.tbl_element) = '541' THEN '2041'
    WHEN TRIM(pcc.tbl_element) = '548' THEN '2048'
    ELSE NULL
END AS CAT

FROM codes_table AS pcc 
--ON pcc.tbl_element=TRIM(pcc.tbl_element_desc)

WHERE pcc.code_status='A'
  AND pcc.tbl_type_code = 'pcc'

ORDER BY PCC_Code




/*

  SELECT DISTINCT
pcc.tbl_element_desc
, impgroup.tbl_element_desc AS Imp_GroupCode_Desc
, CASE
      WHEN a.property_class = 314 THEN 14
      WHEN a.property_class = 317 THEN 17
      WHEN a.property_class = 322 THEN 22
      WHEN a.property_class = 411 THEN 11
      WHEN a.property_class = 413 THEN 13
      WHEN a.property_class = 416 THEN 16
      WHEN a.property_class = 421 THEN 21
      WHEN a.property_class = 451 THEN 51
      WHEN a.property_class = 512 THEN 12
      WHEN a.property_class = 515 THEN 15
      WHEN a.property_class = 520 THEN 20
      WHEN a.property_class = 525 THEN 25
      WHEN a.property_class = 526 THEN 26
      WHEN a.property_class = 527 THEN 27
      WHEN a.property_class = 546 THEN 46
      WHEN a.property_class = 550 THEN 50
      WHEN a.property_class = 549 THEN 49
      WHEN a.property_class = 555 THEN 55
      WHEN a.property_class = 565 THEN 65
      WHEN a.property_class = 336 THEN 1436
      WHEN a.property_class = 339 THEN 1739
      WHEN a.property_class = 343 THEN 2243
      WHEN a.property_class = 441 THEN 2141
      WHEN a.property_class = 435 THEN 1335
      WHEN a.property_class = 438 THEN 1638
      WHEN a.property_class = 442 THEN 2142
      WHEN a.property_class = 534 THEN 1234
      WHEN a.property_class = 537 THEN 1537
      WHEN a.property_class = 541 THEN 2041
      WHEN a.property_class = 548 THEN 2848
       ELSE NULL
END AS CAT


FROM Allocations AS a
LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.property_class
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'pcc'
    
WHERE a.status = 'A'
  AND a.cost_value > 0


    
*/