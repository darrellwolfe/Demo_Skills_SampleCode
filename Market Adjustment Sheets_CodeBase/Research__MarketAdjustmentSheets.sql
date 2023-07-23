
/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/



-------query-------

/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/



-------------------------------------
-- CTEs will drive this report and combine in the main query
-------------------------------------
WITH

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------

CTE_MarketAdjustmentNotes AS (
  Select Distinct
    m1.lrsn,
    LTRIM(RTRIM(CONCAT(
    m2.memo_text,
    '.', 
    m3.memo_text,
    '.', 
    m4.memo_text,
    '.', 
    m5.memo_text,
    '.', 
    m6.memo_text,
    '.', 
    m7.memo_text
    ))) AS [MarketAdjustmentNotes]

  From memos AS m1
  LEFT JOIN memos AS m2 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '2'
    AND m2.status = 'A'
  LEFT JOIN memos AS m3 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '3'
    AND m3.status = 'A'
  LEFT JOIN memos AS m4 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '4'
    AND m4.status = 'A'
  LEFT JOIN memos AS m5 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '5'
    AND m5.status = 'A'
  LEFT JOIN memos AS m6 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '6'
    AND m6.status = 'A'
  LEFT JOIN memos AS m7 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '7'
    AND m7.status = 'A'
  --------------------------
  -- SA Sales Analysis, SAMH Sales Analyis MH (Mobile Home) are seperate Memo Headers in ProVal
  --------------------------
  Where m1.memo_id IN ('SA','SAMH')
  AND m1.status = 'A'
),



-------------------------------------
--CTE_Improvements_Residential
-------------------------------------
CTE_Improvements_Residential AS (
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
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType],

-- Residential Dwellings dw
  --codes_table
  -- AND htyp.tbl_type_code='htyp'  
dw.mkt_house_type,
htyp.tbl_element_desc AS [HouseTypeName],
dw.mkt_rdf AS [RDF] -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation


--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
     
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'

--Conditions
WHERE e.status = 'A'
AND i.improvement_id IN ('D','M')
AND (e.ext_description LIKE '%H1%'
  OR e.ext_description LIKE '%H-1%'
  OR e.ext_description LIKE '%NREV%'
  )
--Order by e.lrsn
),

-------------------------------------
--CTE_Improvements_Commercial
-------------------------------------
CTE_Improvements_Commercial AS (
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
--Commercial
cu.use_code,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType]


/*
--manuf_housing
    --codes_table 
    --AND make.tbl_type_code='mhmake'
    --AND model.tbl_type_code='mhmodel'    
    --AND park.tbl_type_code='mhpark'
mh.mh_make,
make.tbl_element_desc AS [MH_Make],
mh.mh_model,
model.tbl_element_desc AS [MH_Model],
mh.mh_serial_num AS [VIN],
mh.mhpark_code,
park.tbl_element_desc AS [MH_Park]
*/
--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status='A'
/*
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
*/

WHERE e.status = 'A'
AND i.improvement_id IN ('C')
--AND mh.mh_make IS NOT NULL
--,'D','M')
/*
AND (e.ext_description LIKE '%H1%'
  OR e.ext_description LIKE '%H-1%'
  OR e.ext_description LIKE '%NREV%'
  )
*/
),

-------------------------------------
--CTE_Improvements_MF
-------------------------------------
CTE_Improvements_MF AS (
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
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType],

-- Residential Dwellings dw
  --codes_table
  -- AND htyp.tbl_type_code='htyp'  
dw.mkt_house_type,
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
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
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
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
     
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
    
WHERE e.status = 'A'
AND i.improvement_id IN ('M')

--Order by e.lrsn
),

-------------------------------------
--CTE_ParcelMasterData
-------------------------------------
CTE_ParcelMasterData AS (
Select Distinct
pm.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC_ClassCD],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
pm.LegalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

),

-------------------------------------
--CTE_CertValues2023
-------------------------------------
  CTE_CertValues2023 AS (
    SELECT 
      v.lrsn,
      --Certified Values
      v.land_market_val AS [Cert_Land_2023],
      v.imp_val AS [Cert_Imp_2023],
      (v.imp_val + v.land_market_val) AS [Cert_Total_2023],
      v.eff_year AS [Tax_Year_2023],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
      AND v.status = 'A'
  ),
  
-------------------------------------
-- CTE_Cat19Waste
-------------------------------------
CTE_Cat19Waste AS (
SELECT
lh.RevObjId AS [lrsn],
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
ld.LDAcres AS [Cat19Waste]

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'
--Change land model id for current year
  AND lh.LandModelId='702023'
  AND ld.LandModelId='702023'
--Looking for:
  AND ld.LandType IN ('82')
  
),

-------------------------------------
-- CTE_LandDetails
-------------------------------------

CTE_LandDetails AS (
SELECT
lh.RevObjId AS [lrsn],
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
ld.LDAcres,
ld.ActualFrontage,
ld.DepthFactor,
ld.SoilProdFactor,
ld.SmallAcreFactor

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'
--Change land model id for current year
  AND lh.LandModelId='702023'
  AND ld.LandModelId='702023'
--Looking for:
  --AND ld.LandType IN ('82')
)






-------------------------------------
-- End of CTEs ???? Maybe ???
-------------------------------------


-------------------------------------
--Start of Primary Qeury, Driven by Transfer Table
--FROM Transfer table, JOIN CTEs
-------------------------------------
SELECT DISTINCT

t.lrsn,

pmd.[PIN],
pmd.[AIN],
pmd.[GEO],
pmd.[GEO_Name],
pmd.[PCC_ClassCD],
pmd.[SitusAddress],
pmd.[SitusCity],
pmd.LegalAcres,
pmd.Improvement_Status,

t.pxfer_date AS [SaleDate],
t.AdjustedSalePrice AS [SalePrice],
t.SaleDesc,
t.TfrType,
t.DocNum, -- Multiples will have the same DocNum


res.year_built,
res.eff_year_built,
res.year_remodeled,
res.condition,
res.[GradeCode], -- is this a code that needs a key?
res.[GradeType],
res.mkt_house_type,
res.[HouseTypeName],
res.[RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation

comm.use_code,
comm.year_built,
comm.eff_year_built,
comm.year_remodeled,
comm.condition,
comm.[GradeCode], -- is this a code that needs a key?
comm.[GradeType],


mf.imp_type,
mf.year_built,
mf.eff_year_built,
mf.year_remodeled,
mf.condition,
mf.[GradeCode], -- is this a code that needs a key?
mf.[GradeType],
mf.mkt_house_type,
mf.[HouseTypeName],
mf.[RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation
mf.use_code,
mf.[MHMake#],
mf.[MH_Make],
mf.[MHModel#],
mf.[MH_Model],
mf.[VIN],
mf.mhpark_code,
mf.[MH_Park],

c19.[Cat19Waste],

cv23.[Cert_Land_2023],
cv23.[Cert_Imp_2023],
cv23.[Cert_Total_2023],




notes.[MarketAdjustmentNotes]


FROM transfer AS t -- ON t.lrsn for joins
--CTEs
LEFT JOIN
CTE_ParcelMasterData AS pmd ON t.lrsn=pmd.lrsn

LEFT JOIN
CTE_MarketAdjustmentNotes AS notes ON t.lrsn=notes.lrsn

LEFT JOIN
CTE_Improvements_Residential AS res ON t.lrsn=res.lrsn

LEFT JOIN
CTE_Improvements_Commercial AS comm ON t.lrsn=comm.lrsn

LEFT JOIN
CTE_Improvements_MF AS mf ON t.lrsn=mf.lrsn

LEFT JOIN
CTE_CertValues2023 AS cv23 ON t.lrsn=cv23.lrsn
  AND cv23.RowNumber = '1'

LEFT JOIN
CTE_Cat19Waste AS c19 ON t.lrsn=c19.lrsn

LEFT JOIN
CTE_LandDetails AS cld ON t.lrsn=cld.lrsn



-------------------------------------
--WHERE Conditions for t only
-------------------------------------
WHERE t.status = 'A'
AND t.AdjustedSalePrice <> '0'
AND t.pxfer_date BETWEEN '2022-01-01' AND '2023-12-31'
-------------------------------------
--
-------------------------------------


-------------------------------------
--
-------------------------------------


-------------------------------------
--
-------------------------------------


-------------------------------------
--
-------------------------------------


-------------------------------------
--
-------------------------------------


-------------------------------------
--
-------------------------------------

-------------------------------------
-- Darrell Wolfe, Dyson Savage, Kendall Mallery, "The Hive"
-------------------------------------
















----------------------------------RESEARCH BELOW--------------------------------------


SELECT DISTINCT
t.lrsn,
t.pxfer_date AS [SaleDate],
t.AdjustedSalePrice AS [SalePrice],
t.SaleDesc,
t.TfrType,
t.DocNum -- Multiples will have the same DocNum

FROM transfer AS t -- ON t.lrsn for joins




WHERE t.status = 'A'
AND t.AdjustedSalePrice <> '0'



--GEO information for Market Adjustments Sheets
Select Distinct
pm.neighborhood AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
COUNT(pm.lrsn) AS [Count_of_PINs]

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
AND pm.neighborhood IS NOT NULL

GROUP BY pm.neighborhood, pm.NeighborHoodName

ORDER BY [GEO]

-- WHAT IS A cbtyp from the codes_table joined to??
--EXAMPLE: cbtyp       70          Health, Dental Office    
--code        cbtyp       Commercial Building Types     
-- code        grades      Grade Factors for Quality     
--if you use "code" as the tbl_type_code you get a list of what each code is for!! 

Select *
From codes_table
Where tbl_type_code = 'code'










TSBv_PARCELMASTER

/*
AsTxDBProd
GRM_Main


In the context of sales, specifically in real estate transactions, "GrantorName" and "GranteeName" refer to the parties involved in the transfer of property ownership.

GrantorName: The Grantor is the party who is transferring or "granting" their ownership rights in a property to another party. The GrantorName refers to the name of the individual, group, or organization that is giving up their ownership interest in the property. Typically, the Grantor is the seller in a real estate transaction.

GranteeName: The Grantee is the party who is receiving or "being granted" the ownership rights in a property from the Grantor. The GranteeName refers to the name of the individual, group, or organization that is acquiring the ownership interest in the property. Typically, the Grantee is the buyer in a real estate transaction.
*/

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
--Sales Transfer Table from GRM Main
t.pxfer_date AS [TransferDate],
t.AdjustedSalePrice AS [SalesPrice_ProVal],
t.DocNum,
t.ConvForm,
t.SaleDesc,
t.TfrType,
t.GrantorName AS [Grantor_Seller],
t.GranteeName AS [Grantee_Buyer],
t.last_update AS [LastUpdated],
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [ProValOwner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
--Acres
parcel.Acres,
--Other
LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
LTRIM(RTRIM(parcel.DisplayDescr)) AS [LegalDescription]


FROM KCv_PARCELMASTER1 AS parcel
JOIN transfer AS t ON parcel.lrsn=t.lrsn


WHERE parcel.EffStatus = 'A'
AND t.status = 'A'
AND t.pxfer_date > '2023-01-01'

ORDER BY [GEO],[PIN];



----------------------
--Values Combined --Change to desired year in CTE Statements
----------------------


WITH 
  CTE_Cert AS (
    SELECT 
      lrsn,
      --Certified Values
      v.land_market_val AS [Cert Land],
      v.imp_val AS [Cert Imp],
      (v.imp_val + v.land_market_val) AS [Cert Total Value],
      v.eff_year AS [Tax Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
      AND v.status = 'A'
  ),

  CTE_Assessed AS (
    SELECT 
      lrsn,
      --Assessed Values
      v.land_assess AS [Assessed Land],
      v.imp_assess AS [Assessed Imp],
      (v.imp_assess + v.land_assess) AS [Assessed Total Value],
      v.eff_year AS [Tax Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
      AND v.status = 'A'
  )

SELECT 
  parcel.lrsn,
  LTRIM(RTRIM(parcel.pin)) AS [PIN], 
  LTRIM(RTRIM(parcel.ain)) AS [AIN], 
  parcel.neighborhood AS [GEO],
  parcel.Acres,
  parcel.ClassCD,
  --Certified Values
  crt.[Cert Land],
  crt.[Cert Imp],
  crt.[Cert Total Value],
  --Assessed Values
  asd.[Assessed Land],
  asd.[Assessed Imp],
  asd.[Assessed Total Value]

FROM KCv_PARCELMASTER1 AS parcel
LEFT JOIN CTE_Cert AS crt ON parcel.lrsn = crt.lrsn
LEFT JOIN CTE_Assessed AS asd ON parcel.lrsn = asd.lrsn

WHERE parcel.EffStatus = 'A'
AND crt.RowNumber=1
AND asd.RowNumber=1

ORDER BY [GEO], [PIN];


--status='A'; but to get before and after, you need both active and historical status.
Select
a.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(a.group_code)) AS [KootenaiGroupCode],
LEFT(a.group_code,2) AS [StateGroupCode],
SUM(a.cost_value) AS Cost,
MAX(a.last_update) AS [FinalDate],
--a.last_update AS [FirstDate],
ROW_NUMBER() OVER (PARTITION BY a.lrsn ORDER BY a.last_update DESC) AS RowNum
--ASC) AS RowNum

From allocations AS a
JOIN TSBv_PARCELMASTER AS pm ON a.lrsn=pm.lrsn
  And pm.EffStatus='A'
  
--Where last_update LIKE '%2023%'
--Where a.last_update = '2023-05-03'
Where a.status = 'H'
--  And a.last_update >= '2023-05-03'
And last_update LIKE '%2023%'

Group By a.lrsn, pm.pin, pm.AIN, a.group_code, a.last_update;


----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------

--Extensions always comes first
JOIN extensions AS e ON kcv.lrsn=e.lrsn
  AND e.status = 'A'
  
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id='M'
--manuf_housing, comm_bldg, dwellings all must be after e and i
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
Join codes_table AS ct ON mh.mh_make=ct.tbl_element 
  AND ct.tbl_type_code='mhmake'
  
--manuf_housing, comm_bldg, dwellings all must be after e and i
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'

--manuf_housing, comm_bldg, dwellings all must be after e and i
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension




--NOTES, CONCAT allows one line of notes instead of duplicate rows

CTE_MarketAdjustmentNotes AS (
  Select Distinct
    m1.lrsn,
    LTRIM(RTRIM(CONCAT(
    m2.memo_text,
    '.', 
    m3.memo_text,
    '.', 
    m4.memo_text,
    '.', 
    m5.memo_text,
    '.', 
    m6.memo_text,
    '.', 
    m7.memo_text
    ))) AS [MarketAdjustmentNotes]

  From memos AS m1
  LEFT JOIN memos AS m2 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '2'
    AND m2.status = 'A'
  LEFT JOIN memos AS m3 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '3'
    AND m3.status = 'A'
  LEFT JOIN memos AS m4 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '4'
    AND m4.status = 'A'
  LEFT JOIN memos AS m5 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '5'
    AND m5.status = 'A'
  LEFT JOIN memos AS m6 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '6'
    AND m6.status = 'A'
  LEFT JOIN memos AS m7 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '7'
    AND m7.status = 'A'
  --------------------------
  -- SA Sales Analysis, SAMH Sales Analyis MH (Mobile Home) are seperate Memo Headers in ProVal
  --------------------------
  Where m1.memo_id IN ('SA','SAMH')
  AND m1.status = 'A'
),






----------
--Land Header + Land Detail + Land Types Key
----------

SELECT
lh.RevObjId,
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

WHERE lh.EffStatus= 'A' 
  AND lh.LandModelId='702023'
  AND ld.LandModelId='702023'
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'
  
  --land_methods??
  --land_val_element??
  
  
  


-- !preview conn=con


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
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType],

--manuf_housing
    --codes_table 
    --AND make.tbl_type_code='mhmake'
    --AND model.tbl_type_code='mhmodel'    
    --AND park.tbl_type_code='mhpark'
mh.mh_make,
make.tbl_element_desc AS [MH_Make],
mh.mh_model,
model.tbl_element_desc AS [MH_Model],
mh.mh_serial_num AS [VIN],
mh.mhpark_code,
park.tbl_element_desc AS [MH_Park],


-- Residential Dwellings dw
  --codes_table
  -- AND htyp.tbl_type_code='htyp'  
dw.mkt_house_type,
htyp.tbl_element_desc AS [HouseTypeName],
dw.mkt_rdf AS [RDF] -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation


--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
      
--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension
      AND (e.ext_description LIKE '%H1%'
        OR e.ext_description LIKE '%H-1%')
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
     
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
    

WHERE e.status = 'A'
AND i.improvement_id IN ('C','D')

Order by e.lrsn



CTE_Improvements_Commercial AS (
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
--Commercial
cu.use_code,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType]


/*
--manuf_housing
    --codes_table 
    --AND make.tbl_type_code='mhmake'
    --AND model.tbl_type_code='mhmodel'    
    --AND park.tbl_type_code='mhpark'
mh.mh_make,
make.tbl_element_desc AS [MH_Make],
mh.mh_model,
model.tbl_element_desc AS [MH_Model],
mh.mh_serial_num AS [VIN],
mh.mhpark_code,
park.tbl_element_desc AS [MH_Park]
*/
--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status='A'
/*
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
*/

WHERE e.status = 'A'
AND i.improvement_id IN ('C')
--AND mh.mh_make IS NOT NULL
--,'D','M')
/*
AND (e.ext_description LIKE '%H1%'
  OR e.ext_description LIKE '%H-1%'
  OR e.ext_description LIKE '%NREV%'
  )
*/
),


CTE_Improvements_MF AS (
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
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType],

-- Residential Dwellings dw
  --codes_table
  -- AND htyp.tbl_type_code='htyp'  
dw.mkt_house_type,
htyp.tbl_element_desc AS [HouseTypeName],
dw.mkt_rdf AS [RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation

--Commercial
cu.use_code,

--manuf_housing
    --codes_table 
    --AND make.tbl_type_code='mhmake'
    --AND model.tbl_type_code='mhmodel'    
    --AND park.tbl_type_code='mhpark'
mh.mh_make,
make.tbl_element_desc AS [MH_Make],
mh.mh_model,
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
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
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
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
     
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
    
WHERE e.status = 'A'
AND i.improvement_id IN ('M')

--Order by e.lrsn
),


CTE_ParcelMasterData AS (
Select Distinct
pm.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC_ClassCD],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
pm.LegalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

),

-------------------------------------
--CTE_CertValues2023
-------------------------------------
  CTE_CertValues2023 AS (
    SELECT 
      lrsn,
      --Certified Values
      v.land_market_val AS [Cert_Land_2023],
      v.imp_val AS [Cert_Imp_2023],
      (v.imp_val + v.land_market_val) AS [Cert_Total_2023],
      v.eff_year AS [Tax_Year_2023],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
      AND v.status = 'A'
  )

CTE_Cat19Waste AS (
SELECT
lh.RevObjId,
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
ld.LDAcres AS [Cat19Waste]

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'
--Change land model id for current year
  AND lh.LandModelId='702023'
  AND ld.LandModelId='702023'
--Looking for:
  AND ld.LandType IN ('82')
  
)




-------------------------------------
-- CTE_LandDetails
-------------------------------------

CTE_LandDetails AS (
SELECT
lh.RevObjId,
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
ld.LDAcres,
ld.ActualFrontage,
ld.DepthFactor,
ld.SoilProdFactor,
ld.SmallAcreFactor

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'
--Change land model id for current year
  AND lh.LandModelId='702023'
  AND ld.LandModelId='702023'
--Looking for:
  --AND ld.LandType IN ('82')
)
