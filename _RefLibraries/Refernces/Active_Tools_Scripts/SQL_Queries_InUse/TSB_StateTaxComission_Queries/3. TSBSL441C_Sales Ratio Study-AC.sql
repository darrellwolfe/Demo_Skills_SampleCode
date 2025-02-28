-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

Declare @Year int = 2024; -- Input THIS year here
Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here

--EXACT DASHES '2023-01-01'
Declare @SalesFromDate date = CAST(CAST(@Year-1 as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @SalesFromDate DATE = '2023-10-01';
--From date requested by State Tax Commission Rep

Declare @SalesToDate date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); 
--Declare @SalesToDate DATE = '2024-12-31';
--To date requested by State Tax Commission Rep

Declare @LastCertifiedStart varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
--Declare @LastCertifiedStart INT = '20240101';
--01/01 of most recent Assessed Values

Declare @LastCertifiedEnd varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @LastCertifiedEnd INT = '20241231';
--12/31 of most recent Assessed Values

Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year-1 as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2022-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022


WITH 

CTE_ImpGroupCodeKey AS (
SELECT 
c.tbl_type_code AS CodeType
,c.tbl_element AS GroupCode_KC
,LEFT(c.tbl_element,2) AS GroupCode_STC
,c.tbl_element_desc AS CodeDescription
,CASE 
    WHEN c.tbl_element_desc LIKE '%EXEMPT%' THEN 'Exempt_Property'
    WHEN c.tbl_element_desc LIKE '%OPERATING%' THEN 'Operating_Property'
    WHEN c.tbl_element_desc LIKE '%QIE%' THEN 'Qualified_Improvement_Expenditure'
    WHEN c.tbl_element LIKE '%P%' THEN 'Business_Personal_Property'
    WHEN LEFT(c.tbl_element,2) IN ('98','99') THEN 'Non-Allocated_Error'
    WHEN LEFT(c.tbl_element,2) IN ('25') THEN 'Common_Area'
    WHEN LEFT(c.tbl_element,2) IN ('81') THEN 'Exempt_Property'
    WHEN LEFT(c.tbl_element,2) IN ('19') THEN 'RightOfWay_ROW_Cat19'
    WHEN LEFT(c.tbl_element,2) IN ('45') THEN 'Operating_Property'
    
    WHEN LEFT(c.tbl_element,2) IN ('01','03','04','05','06','07','08','09','10','11','31','32','33') THEN 'Timber_Ag'
    WHEN LEFT(c.tbl_element,2) IN ('12','15','20','26','30','32','34','37','41') THEN 'Residential'
    WHEN LEFT(c.tbl_element,2) IN ('13','16','21','27','35','38','42') THEN 'Commercial'
    WHEN LEFT(c.tbl_element,2) IN ('14','17','22','36','39','43') THEN 'Industrial'
    WHEN LEFT(c.tbl_element,2) IN ('49','50','51') THEN 'Leased_Land'
    WHEN LEFT(c.tbl_element,2) IN ('46','47','48','55','65') THEN 'Mobile_Home'
    ELSE 'Other'
  END AS Category

,CASE
  WHEN LEFT(c.tbl_element,2) IN ('01','03','04','05','06','07','09','10',
                                '11','12','13','14','15','16','17','18',
                                '19','20','21','22','25','26','27','81') THEN 'State_Land'
  ELSE NULL
END AS State_Land

,CASE
  WHEN LEFT(c.tbl_element,2) BETWEEN '56' AND '72' THEN 'State_Imp'
  WHEN LEFT(c.tbl_element,2) IN ('25','26','30','32','34','35','36','37',
                                '38','39','41','42','43','46','47',
                                '48','49','50','51','55','65','81') THEN 'State_Imp'
  ELSE NULL
END AS State_Imp


FROM codes_table AS c
WHERE c.code_status = 'A' 
AND c.tbl_type_code = 'impgroup'

),

CTE_SalesInformation AS (
Select 
TRIM(t.CountyNumber) AS CountyNumber
,TRIM(t.TAG) AS TAG
,t.lrsn
,TRIM(t.PIN) AS PIN
,TRIM(t.AIN) AS AIN
,TRIM(t.PropClassDescr) AS PropClassDescr
,t.SaleDate
,t.AdjSalesPrice
,t.DocNumber
,TRIM(t.SaleType) AS SaleType
,TRIM(t.LocalRatioShortDescr) AS LocalRatioShortDescr
,TRIM(t.LocalAnalysisDescr) AS LocalAnalysisDescr
,TRIM(t.SOARatioShortDescr) AS SOARatioShortDescr

From TSBv_Transfers AS t
Where t.AdjSalesPrice > 1
And t.SaleDate BETWEEN @SalesFromDate AND @SalesToDate
----VARIABLE DATE

),

CTE_ValDetail_Land AS (
Select
vd.lrsn
,vd.last_update_long
,vd.val_seq_no
,vd.eff_year
,vd.group_code AS GC_KC
,LEFT(vd.group_code,2) AS GC_State
,igc.CodeDescription
,igc.Category
,igc.State_Land
,igc.State_Imp
,vd.value
,ROW_NUMBER() OVER (PARTITION BY vd.lrsn ORDER BY vd.last_update_long DESC) AS RowNum

From val_detail AS vd

Join CTE_ImpGroupCodeKey AS igc
  On vd.group_code = igc.GroupCode_KC
  And igc.Category IN ('Residential','Commercial','Industrial','Mobile_Home','Leased_Land')
  
Where vd.status = 'A'
And vd.eff_year = @LastCertifiedStart
----VARIABLE DATE
And vd.extension IN ('L00')
    And vd.improvement_id IN ('')
    And vd.group_code <> '19'
    
--And (vd.extension IN ('L00')
  --  And vd.improvement_id IN ('')) 
--OR (vd.extension IN ('R01','C01')
  --  And vd.improvement_id IN ('D','M','C'))
),

CTE_ValDetail_Improvement AS (
Select
vd.lrsn
,vd.last_update_long
,vd.val_seq_no
,vd.eff_year
,vd.group_code AS GC_KC
,LEFT(vd.group_code,2) AS GC_State
,igc.CodeDescription
,igc.Category
,igc.State_Land
,igc.State_Imp
,vd.value
,ROW_NUMBER() OVER (PARTITION BY vd.lrsn ORDER BY vd.last_update_long DESC) AS RowNum

From val_detail AS vd

Join CTE_ImpGroupCodeKey AS igc
  On vd.group_code = igc.GroupCode_KC
  And igc.Category IN ('Residential','Commercial','Industrial','Mobile_Home','Leased_Land')

Where vd.status = 'A'
And vd.eff_year = @LastCertifiedStart
----VARIABLE DATE

And vd.extension IN ('R01','C01')
    And vd.improvement_id IN ('D','M','C')
    And vd.group_code <> '19'
--And (vd.extension IN ('L00')
  --  And vd.improvement_id IN ('')) 
--OR (vd.extension IN ('R01','C01')
  --  And vd.improvement_id IN ('D','M','C'))
),

CTE_Cert AS (
  SELECT 
    lrsn,
    --Certified Values
    v.land_market_val AS CertValue_Land_NoEx,
    v.imp_val AS CertValue_Imp,
    (v.imp_val + v.land_market_val) AS CertValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNum
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @LastCertifiedStart AND @LastCertifiedEnd
--Change to desired year
    AND v.status = 'A'
),

CTE_MultiSale_Cert AS (
Select 
t.lrsn
,SUM(cert.CertValue_Total) AS MultiSale_Cert
,t.DocNumber

From TSBv_Transfers AS t
Join CTE_Cert AS cert
  On t.lrsn = cert.lrsn
  And cert.RowNum = 1
Where t.AdjSalesPrice > 1
And t.SaleDate BETWEEN @SalesFromDate AND @SalesToDate
----VARIABLE DATE
Group By t.lrsn, t.DocNumber

),

CTE_Assessed AS (
  SELECT 
    lrsn,
    --Assessed Values
    v.land_assess AS AssessedValue_Land_wEx,
    v.imp_assess AS AssessedValue_Imp,
    (v.imp_assess + v.land_assess) AS AssessedValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNum
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @LastCertifiedStart AND @LastCertifiedEnd
--Change to desired year
    AND v.status = 'A'
),

CTE_MultiSale_Assessed AS (
Select 
t.lrsn
,SUM(assd.AssessedValue_Total) AS MultiSale_Assessed
,t.DocNumber

From TSBv_Transfers AS t

Join CTE_Assessed AS assd
  On t.lrsn = assd.lrsn
  And assd.RowNum = 1
Where t.AdjSalesPrice > 1
And t.SaleDate BETWEEN @SalesFromDate AND @SalesToDate
----VARIABLE DATE
Group By t.lrsn, t.DocNumber

),



CTE_SalesMemos AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, '.') AS SalesMemos

FROM (SELECT
        lrsn,
        memo_text
      FROM memos
    
    WHERE status = 'A'
    AND memo_id IN ('SA', 'SAMH')
    AND memo_line_number > 1
    AND (memo_text LIKE '%' + RIGHT(CONVERT(VARCHAR, @Year), 2) + '%'
      OR memo_text LIKE '%' + RIGHT(CONVERT(VARCHAR, @Year - 1), 2) + '%')

    --AND last_update >= @MemoLastUpdatedNoEarlierThan
    ) AS Subquery
  GROUP BY lrsn
),


CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
Select Distinct
CASE
    WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 6003 THEN 'District_6'
    WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood = 6001 THEN 'District_6'
    WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 5003 THEN 'District_5'
    WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood = 5001 THEN 'District_5'
    WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 4000 THEN 'District_4'
    WHEN pm.neighborhood >= 3000 THEN 'District_3'
    WHEN pm.neighborhood >= 2000 THEN 'District_2'
    WHEN pm.neighborhood >= 1021 THEN 'District_1'
    WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 1001 THEN 'District_1'
    WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 451 THEN 'Commercial'
    WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN pm.neighborhood >= 1 THEN 'Commercial'
    WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
END AS District
,CASE
    WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 6003 THEN 'Residential'
    WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood = 6001 THEN 'Residential'
    WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 5003 THEN 'Residential'
    WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood = 5001 THEN 'Residential'
    WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 4000 THEN 'Residential'
    WHEN pm.neighborhood >= 3000 THEN 'Residential'
    WHEN pm.neighborhood >= 2000 THEN 'Residential'
    WHEN pm.neighborhood >= 1021 THEN 'Residential'
    WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 1001 THEN 'Residential'
    WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 451 THEN 'Commercial'
    WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN pm.neighborhood >= 1 THEN 'Commercial'
    WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
END AS PropertyType
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
, pm.lrsn
,  pm.Improvement_Status -- <Improved vs Vacant

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
),


CTE_SalesReview AS (
--Sales_Ratio_Study_Query_Change_Dates_In_SQL
----Combined Ratio Study Query

SELECT DISTINCT
--Property Data
si.CountyNumber
,pmd.PropertyType
,pmd.District
,pmd.GEO_Name
,pmd.GEO
,pmd.Improvement_Status
,si.TAG
,si.lrsn
,si.PIN
,si.AIN
--Sale and Assessed Value Data
,si.DocNumber
,CAST(si.SaleDate AS DATE) AS SaleDate
,si.AdjSalesPrice
,assd.AssessedValue_Total
,msassd.MultiSale_Assessed
,CASE
  WHEN assd.AssessedValue_Total = msassd.MultiSale_Assessed THEN ''
  ELSE 'Possible_MultiSale'
END AS MultiSaleCheck_DocNum
--If the sum of all assessed values for any given DocNumber 
--  do not equal the indicidual AIN assessed value
--   Likely a MultiSale
,cert.CertValue_Total
,mscert.MultiSale_Cert
--GroupCode Data
,vdl.GC_State AS GroupCode_Land
,vdi.GC_State AS GroupCode_Imp
,CONCAT(vdl.GC_State ,vdi.GC_State) AS StateCategory
,si.PropClassDescr
--Additional Data
,si.SaleType
,si.LocalAnalysisDescr
,si.LocalRatioShortDescr
,si.SOARatioShortDescr
,sm.SalesMemos

From CTE_SalesInformation AS si
Join CTE_ParcelMaster AS pmd
  On si.lrsn = pmd.lrsn
  --And pmd.GEO <> 0

Left Join CTE_ValDetail_Land AS vdl
  On vdl.lrsn = si.lrsn
  And vdl.RowNum = 1

Left Join CTE_ValDetail_Improvement AS vdi
  On si.lrsn = vdi.lrsn
  And vdi.RowNum = 1


Left Join CTE_MultiSale_Assessed  AS msassd
  On msassd.lrsn = si.lrsn

Left Join CTE_MultiSale_Cert  AS mscert
  On mscert.lrsn = si.lrsn


Left Join CTE_Cert AS cert
  On si.lrsn = cert.lrsn
  And cert.RowNum = 1

Left Join CTE_Assessed AS assd
  On si.lrsn = assd.lrsn
  And assd.RowNum = 1

Left Join CTE_SalesMemos AS sm
  On si.lrsn = sm.lrsn
)
  
  
Select 
sr.*
From CTE_SalesReview AS sr

Where sr.StateCategory IS NOT NULL
And sr.StateCategory <> 0
-- All situations in which this is blank means that 
--  the available allocaitons are not in state approved cats for Sales Ratio study
--Where si.AIN = '195481' -- As test AIN

Order By District, GEO, PIN;

