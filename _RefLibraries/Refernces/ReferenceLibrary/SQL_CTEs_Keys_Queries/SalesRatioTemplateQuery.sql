-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/



WITH


CTE_Sales AS (
SELECT DISTINCT
t.lrsn
,t.AdjustedSalePrice AS SalePrice
,CAST(t.pxfer_date AS DATE) AS SaleDate
,TRIM(t.SaleDesc) AS SaleDescr
,TRIM(t.TfrType) AS TranxType
,TRIM(t.DocNum) AS DocNum -- Multiples will have the same DocNum

FROM transfer AS t -- ON t.lrsn for joins

WHERE t.status = 'A'
--AND pmd.AIN IN ('142762','135478','249334') -- Use to test cases only
AND t.AdjustedSalePrice <> '0'
AND t.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'
),

CTE_Assessed AS (
  SELECT 
    lrsn,
    --Assessed Values
    v.land_assess AS AssessedValue_Land_wEx,
    v.imp_assess AS AssessedValue_Imp,
    (v.imp_assess + v.land_assess) AS AssessedValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
    AND v.status = 'A'
),

CTE_ParcelMaster AS (
Select Distinct
lrsn
,TRIM(ain) AS AIN
,TRIM(pin) AS PIN
,pm.neighborhood AS GEO
,TRIM(pm.PropClassDescr) AS PCC
,LEFT(TRIM(pm.PropClassDescr), 3) AS PCC_Code
,TRIM(pm.CountyNumber) AS CountyNumber

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
),


CTE_PCC_TO_CAT AS (
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

--ORDER BY PCC_Code

)



SELECT
parcel.CountyNumber
,parcel.GEO
,parcel.PIN
,'' AS Valid_Sale_Check
,sale.SaleDate
,value.AssessedValue_Total
,sale.SalePrice
,'' AS ReferenceCode
--,parcel.PCC
--,parcel.PCC_Code
,cat.CAT
,'' AS School_District

FROM CTE_Sales AS sale

JOIN CTE_Assessed AS value
  ON sale.lrsn=value.lrsn
  AND value.RowNumber = '1'

JOIN CTE_ParcelMaster AS parcel
  ON sale.lrsn=parcel.lrsn

LEFT JOIN CTE_PCC_TO_CAT AS cat
  ON cat.PCC_Code = parcel.PCC_Code

ORDER BY GEO, SaleDate;


