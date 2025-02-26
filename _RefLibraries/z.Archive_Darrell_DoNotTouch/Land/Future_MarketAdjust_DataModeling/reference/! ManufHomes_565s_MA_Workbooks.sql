-- !preview conn=conn


/*
AsTxDBProd
GRM_Main
*/


Declare @Year int = 2024; -- Input THIS year here
--DECLARE @TaxYear INT;
--SET @TaxYear = YEAR(GETDATE());

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here


Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2024-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

Declare @PrimaryTransferDateFROM date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateTO date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @PrimaryTransferDateFROM DATE = '2024-01-01';
--Declare @PrimaryTransferDateTO DATE = '2024-12-31';
--pxfer_date
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20240101';
--Declare @CertValueDateTO INT = '20241231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231


Declare @LandModelId varchar(6) = '70' + Cast(@Year as varchar); -- Generates '702023' for the previous year
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    --AND lh.LandModelId= @LandModelId
    --AND ld.LandModelId= @LandModelId 

WITH

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
-- # District SubClass
,CASE
    --Commercial # Income properties use regular template, for now. 
    --  May build something. Set up just in case. DGW 08/02/2023.
      WHEN pm.neighborhood BETWEEN '1' AND '27' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '28' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pm.neighborhood BETWEEN '29' AND '41' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '41' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '42' THEN 'Section42_Workbooks'
      WHEN pm.neighborhood = '43' THEN 'Comm_Sales'
      WHEN pm.neighborhood = '44' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pm.neighborhood BETWEEN '45' AND '99' THEN 'Comm_Sales'
      WHEN pm.neighborhood BETWEEN '100' AND '199' THEN 'Comm_Waterfront'
      WHEN pm.neighborhood BETWEEN '200' AND '899' THEN 'Comm_Sales'
    --D1
      WHEN pm.neighborhood IN ('1008','1010','1410','1420','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('1998','1999') THEN 'Res_MultiFamily'
    --D2
      WHEN pm.neighborhood IN ('2105','2115','2125','2135','2145','2155') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('2996','2997','2998','2999') THEN 'Res_MultiFamily'
    --D3
      WHEN pm.neighborhood IN ('3502','3503','3504','3505','3506') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('3998','3999') THEN 'Res_MultiFamily'
    --D4
      WHEN pm.neighborhood IN ('4201','4202','4203','4204','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pm.neighborhood IN ('4833','4840','4997','4998','4999') THEN 'Res_MultiFamily'
    --D5
      WHEN pm.neighborhood IN ('5001','5004','5009','5010','5012','5015','5018','5020','5021','5024','5030','5033','5036','5039',
                                '5042','5045','5048','5051','5053','5054','5056','5057','5060','5063','5066','5069','5072','5075','5078',
                                '5081','5750','5753','5756','5759','5762','5765','5850','5853','5856') THEN 'Res_Waterfront'
      -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D5 as of 08/02/2023
    --D6
      WHEN pm.neighborhood BETWEEN '6100' AND '6123' THEN 'Res_Waterfront'
      -- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D6 as of 08/02/2023
    -- MH Sales Worksheet Type
      WHEN pm.neighborhood = '1000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '1000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'

      WHEN pm.neighborhood = '1020' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '1020' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '5000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '5002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      
      
      WHEN pm.neighborhood = '6000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         
      
      WHEN pm.neighborhood = '6002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'  
      
      WHEN pm.neighborhood = '9103' AND (pm.ClassCD = 565 OR pm.ClassCD = 548) THEN 'MH_Sales'
      WHEN pm.neighborhood = '9103' AND (pm.ClassCD <> 565 OR pm.ClassCD <> 548) THEN 'MH_FloatRes_Sales'
--      WHEN pm.neighborhood = '9103' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

      WHEN pm.neighborhood >= '9000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
      WHEN pm.neighborhood >= '9000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'    
      
      WHEN pm.neighborhood = '9999' AND pm.pin LIKE 'M%' THEN 'MH_Sales_InResGeos'
      WHEN pm.neighborhood >= '9999' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_SalesInResGeos'  
    --Else
      ELSE 'Res_Sales'
  END AS District_SubClass
-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description

,CASE 
  WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
  WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
  WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
  WHEN pm.ClassCD = '667' THEN 'Operating_Property'
  WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
  WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
  ELSE 'Unasigned_or_OldInactiveParcel'
END AS Property_Class_Category

,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip

,TRIM(pm.AttentionLine) AS AttentionLine
,TRIM(pm.MailingAddress) AS MailingAddress
,TRIM(pm.AddlAddrLine) AS AddlAddrLine
,TRIM(pm.MailingCityStZip) AS MailingCityStZip
,TRIM(pm.MailingCity) AS MailingCity
,TRIM(pm.MailingState) AS MailingState
,TRIM(pm.MailingZip) AS MailingZip
,TRIM(pm.CountyNumber) AS CountyNumber

,CASE
  WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
  ELSE NULL
END AS County_Name

,pm.LegalAcres
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),


------------------------------------
-- Notes
------------------------------------

CTE_NotesSalesAnalysis AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Sales_Notes
FROM memos

WHERE status = 'A'
AND memo_id IN ('SA', 'SAMH')
AND memo_line_number <> '1'
AND last_update >= @MemoLastUpdatedNoEarlierThan

/*
AND (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn
),

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------

CTE_NotesConfidential AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Conf_Notes
FROM memos

WHERE status = 'A'
AND memo_id IN ('NOTE','MHPP')
AND memo_line_number <> '1'
AND last_update >= @MemoLastUpdatedNoEarlierThan

/*
AND (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn

),

-------------------------------------
--CTE_TransferSales
-------------------------------------
CTE_TransferSales AS (
SELECT DISTINCT
--  pmd.[GEO_Name],
  t.lrsn,
  t.status,
--Transfer Table Sale Details
  t.AdjustedSalePrice AS SalePrice,
  CAST(t.pxfer_date AS DATE) AS SaleDate,
  TRIM(t.SaleDesc) AS SaleDescr,
  TRIM(t.TfrType) AS TranxType,
  TRIM(t.DocNum) AS DocNumber -- Multiples will have the same DocNum
FROM transfer AS t -- ON t.lrsn for joins
WHERE t.status = 'A'
  AND t.AdjustedSalePrice <> '0'
  AND t.pxfer_date BETWEEN @PrimaryTransferDateFROM AND @PrimaryTransferDateTO
  --AND t.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'
),

-------------------------------------
--CTE_CertValues
-------------------------------------
CTE_CertValues AS (
  SELECT 
    v.lrsn,
    --Certified Values
    v.land_market_val AS Cert_Land,
    v.imp_val AS Cert_Imp,
    (v.imp_val + v.land_market_val) AS Cert_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  --WHERE v.eff_year BETWEEN 20230101 AND 20231231
  WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO

  
--Change to desired year
    AND v.status = 'A'
),



CTE_Improvements_MH AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------
  Select Distinct
  --Extensions Table
  e.lrsn,
  e.extension,
  e.ext_description,
  e.data_collector,
  e.collection_date,
  e.appraiser,
  e.appraisal_date,
  
  --Improvements Table
    --codes_table 
    --AND park.tbl_type_code='grades'
  i.imp_type,
  --i.imp_size,
  i.year_built,
  i.eff_year_built,
  i.year_remodeled,
  i.condition,
  i.grade AS [GradeCode], -- is this a code that needs a key?
  grades.tbl_element_desc AS [GradeType],
  
  -- Residential Dwellings dw
    --codes_table
    -- AND htyp.tbl_type_code='htyp'  
  dw.mkt_house_type AS [HouseType#],
  htyp.tbl_element_desc AS [HouseTypeName],
  dw.mkt_rdf AS [RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation
  
  --Commercial
  cu.use_code,
  
  --manuf_housing
      --codes_table 
      --AND make.tbl_type_code='mhmake'
      --AND model.tbl_type_code='mhmodel'    
      --AND park.tbl_type_code='mhpark'
  mh.mh_make AS [MHMake#],
  make.tbl_element_desc AS [MH_Make],
  mh.mh_model AS [MHModel#],
  model.tbl_element_desc AS [MH_Model],
  mh.mh_serial_num AS [VIN],
  mh.mhpark_code,
  park.tbl_element_desc AS [MH_Park]
  
  --Extensions always comes first
  FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
    -- AND e.status = 'A' -- Filter if joining this to another query
  JOIN improvements AS i ON e.lrsn=i.lrsn 
        AND e.extension=i.extension
        AND i.status='A'
        AND i.improvement_id IN ('M','C','D')
      --need codes to get the grade name, vs just the grade code#
      LEFT JOIN codes_table AS grades 
      ON i.grade = grades.tbl_element
        AND grades.tbl_type_code='grades'
        AND grades.code_status = 'A'   
        
  --manuf_housing, comm_bldg, dwellings all must be after e and i
  
  --COMMERCIAL      
  LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
        AND i.extension=cb.extension
        AND cb.status='A'
      LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
        AND cb.extension = cu.extension
        AND cu.status='A'
        
  --RESIDENTIAL DWELLINGS
  LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
        AND dw.status='A'
        AND i.extension=dw.extension
    LEFT JOIN codes_table AS htyp 
    ON dw.mkt_house_type = htyp.tbl_element 
      AND htyp.tbl_type_code='htyp'  
      AND htyp.code_status = 'A'

       
  --MANUFACTERED HOUSING
  LEFT JOIN manuf_housing AS mh 
    ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
    LEFT JOIN codes_table AS make 
    ON mh.mh_make=make.tbl_element 
      AND make.tbl_type_code='mhmake'
      AND make.code_status = 'A'
    LEFT JOIN codes_table AS model 
    ON mh.mh_model=model.tbl_element 
      AND model.tbl_type_code='mhmodel'
      AND model.code_status = 'A'
    LEFT JOIN codes_table AS park 
    ON mh.mhpark_code=park.tbl_element 
      AND park.tbl_type_code='mhpark'
      AND park.code_status = 'A'   
      
  WHERE e.status = 'A'
  AND i.improvement_id IN ('M')

),



-----------------------
--CTE_MH SF
-----------------------

CTE_MH_SF AS (
Select
lrsn,
SUM(imp_size) AS MH_SF

From improvements AS i
Where status = 'A'
And improvement_id IN ('M','D') 
Group By lrsn
),

CTE_Float_SF AS (
Select Distinct
rf.lrsn,
SUM(rf.finish_living_area) AS Float_SF
--rf.floor_key

  FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
    -- AND e.status = 'A' -- Filter if joining this to another query
  JOIN improvements AS i ON e.lrsn=i.lrsn 
        AND e.extension=i.extension
        AND i.status='A'
        AND i.improvement_id IN ('M','C','D')
      --need codes to get the grade name, vs just the grade code#
      LEFT JOIN codes_table AS grades 
        ON i.grade = grades.tbl_element
        AND grades.tbl_type_code='grades'
        AND grades.code_status = 'A'   

  JOIN res_floor AS rf
  ON rf.lrsn=e.lrsn
  AND rf.extension=e.extension
  AND rf.dwelling_number=i.dwelling_number
  AND rf.status = 'A'

WHERE e.status = 'A'
--And rf.lrsn IN ('77068','76627','76661') -- Float Home Examples
--And rf.lrsn IN ('77068')
--,'76627','76661') -- Float Home Examples

Group By rf.lrsn

),

CTE_Total_MH_Float_SF AS (
SELECT DISTINCT
pmd.lrsn,
CASE
  WHEN mhsf.MH_SF IS NULL THEN 0
  ELSE mhsf.MH_SF
END AS MH_SF,
CASE
  WHEN flsf.Float_SF IS NULL THEN 0
  ELSE flsf.Float_SF
END AS Float_SF

FROM CTE_ParcelMaster AS pmd 
--LEFT JOIN CTE_TransferSales AS tr -- ON tr.lrsn for joins
  --ON tr.lrsn=pmd.lrsn

  LEFT JOIN CTE_MH_SF AS mhsf
    ON mhsf.lrsn=pmd.lrsn

-- CTE_Float_SF
  LEFT JOIN CTE_Float_SF AS flsf
    ON flsf.lrsn=pmd.lrsn
-- flsf.Float_SF

),

CTE_BedBath AS (
Select
dw.lrsn,
dw.Bedrooms,
dw.Full_Baths,
dw.Half_Baths,
((CAST(dw.full_baths AS DECIMAL (3,1))) + ( (CAST(dw.half_baths AS DECIMAL (3,1))) / 2)) AS Bath_Total

From dwellings AS dw
Where dw.status='A'
--And dw.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home and MH Examples
),

CTE_MH_Float_Value AS (
Select Distinct
a.lrsn,
SUM(a.cost_value) AS MH_Float_Value

From allocations AS a
Where a.status='A'
AND a.improvement_id IN ('M','C','D')--And extension NOT LIKE 'L%'
AND a.extension NOT LIKE 'L%'

--AND a.improvement_id NOT IN ('M','C','D')--And extension NOT LIKE 'L%'
--And a.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home Examples
--And a.lrsn IN ('77068')

Group By a.lrsn
),


CTE_Other_Improve_Value AS (
Select Distinct
a.lrsn,
SUM(a.cost_value) AS Other_Improv_Value

From allocations AS a
Where a.status='A'
--AND a.improvement_id IN ('M','C','D')--And extension NOT LIKE 'L%'
AND a.improvement_id NOT IN ('M','C','D')--And extension NOT LIKE 'L%'
AND a.extension NOT LIKE 'L%'

--And a.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home Examples
--And a.lrsn IN ('77068')

Group By a.lrsn
)






SELECT DISTINCT
pmd.District
,pmd.District_SubClass
,pmd.GEO
--,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,CONCAT(pmd.SitusAddress, ' ', pmd.SitusCity) AS SitusAddress

,pmd.Property_Class_Description
,pmd.ClassCD
--,pmd.Property_Class_Category
--,pmd.TAG
--,mh.lrsn
--,mh.extension
--,mh.ext_description
--,mh.data_collector
--,mh.collection_date
--,mh.appraiser
--,mh.appraisal_date
,mh.imp_type
,mh.year_built
,mh.eff_year_built
,mh.year_remodeled
,mh.condition
--,mh.GradeCode
,mh.GradeType
--,mh.HouseType#
,mh.HouseTypeName
,mh.RDF
--,mh.use_code
--,mh.MHMake#
,mh.MH_Make
--,mh.MHModel#
,mh.MH_Model
,mh.VIN
--,mh.mhpark_code
,mh.MH_Park
,mhsf.MH_SF
-- mhsf.Float_SF,
-- (mhsf.MH_SF + mhsf.Float_SF) AS Total_SF,
,bb.Bedrooms
,bb.Full_Baths
,bb.Half_Baths
,bb.Bath_Total

,mhval.MH_Float_Value AS MH_Value
,otherval.Other_Improv_Value
,pmd.WorkValue_Impv AS WorksheetImpValue

--Certified Values 2023
--,cv.Cert_Land
,cv.Cert_Imp
,cv .Cert_Total

--,ts.status
,ts.SalePrice
,ts.SaleDate
,ts.SaleDescr
,ts.TranxType
,ts.DocNumber

,nsa.Sales_Notes
,nc.Conf_Notes

From CTE_ParcelMaster AS pmd
--  ON xxxx.lrsn = pmd.lrsn

Join CTE_Improvements_MH AS mh
  On pmd.lrsn = mh.lrsn

Join CTE_TransferSales AS ts
  On pmd.lrsn = ts.lrsn


Left Join CTE_CertValues  AS cv
  On pmd.lrsn = cv.lrsn

Left Join CTE_NotesSalesAnalysis  AS nsa
  On pmd.lrsn = nsa.lrsn
  
  
Left Join CTE_NotesConfidential AS nc
  On pmd.lrsn = nc.lrsn

-- CTE_MH_SF + CTE_Float_SF = CTE_Total_MH_Float_SF
Left Join CTE_Total_MH_Float_SF AS mhsf
  On pmd.lrsn = mhsf.lrsn

-- CTE_MH_SF + CTE_Float_SF = CTE_Total_MH_Float_SF
Left Join CTE_BedBath AS bb
  On pmd.lrsn = bb.lrsn
  --bb.bedrooms,
  --bb.full_baths,
  --bb.half_baths,
  --bb.Bath_Total
  
--  On pmd.lrsn = 

-- CTE_MH_Float_Value
LEFT JOIN CTE_MH_Float_Value AS mhval
  On pmd.lrsn = mhval.lrsn
--  mhval.MH_Float_Value

-- CTE_Other_Improve_Value
LEFT JOIN CTE_Other_Improve_Value AS otherval
  On pmd.lrsn = otherval.lrsn
--otherval.Other_Improv_Value

--WHERE GEO = '9303'










