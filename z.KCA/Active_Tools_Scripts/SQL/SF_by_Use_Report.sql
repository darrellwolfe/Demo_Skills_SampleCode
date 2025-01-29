-- !preview conn=con

/*
AsTxDBProd
GRM_Main
SF by Use Report

USE
GRADE
CONDITION
YEAR BUILT
EFFECTIVE YEAR
SQUARE FOOTAGE

--PM
IMPROVEMENT VALUE
LAND VALUE

--Calculated??
SQUARE FOOT VALUE IMPROVEMENT
SQUARE FOOT VALUE LAND

--PM
METHOD OF VALUE (COST OR INCOME)
ACRES
*/




WITH

-----------------------
--CTE_CommBldgSF pulls in Commercial SF for a $/SF Rate
-----------------------
CTE_CommBldgSF AS (
  SELECT DISTINCT
  a.lrsn,
  a.extension,
  a.improvement_id,
  i.imp_type,
  i.imp_size,
  SUM(cu.area) AS [CommSF]
FROM allocations AS a
  JOIN improvements AS i ON i.lrsn=a.lrsn
    AND i.extension=a.extension 
    AND i.improvement_id=a.improvement_id
  JOIN comm_uses AS cu ON a.extension=cu.extension
    AND cu.lrsn=a.lrsn

  AND a.status = 'A'
  AND i.status = 'A'
  AND cu.status = 'A'

GROUP BY 
  a.lrsn,
  a.extension,
  a.improvement_id,
  i.imp_type,
  i.imp_size
  
),

-------------------------------------
--CTE_Improvements_Commercial
-------------------------------------
CTE_Improvements_Commercial AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
-- IN JOIN for Commercial, ensure AND RowNum = 1
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
  STRING_AGG(cu.use_code, ',') AS use_codes,
  i.year_built,
  i.eff_year_built,
  i.year_remodeled,
  i.condition,
  i.grade AS [GradeCode], -- is this a code that needs a key?
  grades.tbl_element_desc AS [GradeType],
  ROW_NUMBER() OVER (PARTITION BY e.lrsn ORDER BY e.extension ASC) AS RowNum
  
  
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
  
  WHERE e.status = 'A'
  AND i.improvement_id IN ('C')
  
  GROUP BY
  e.lrsn,
  e.extension,
  e.ext_description,
  e.data_collector,
  e.collection_date,
  e.appraiser,
  e.appraisal_date,
  i.imp_type,
  i.year_built,
  i.eff_year_built,
  i.year_remodeled,
  i.condition,
  i.grade,
  grades.tbl_element_desc
),

-----------------------
--CTE_ParcelMaster_SpecialRequest
-----------------------

CTE_ParcelMaster_SpecialRequest AS (

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

WHEN pm.neighborhood = '9103' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '9103' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

WHEN pm.neighborhood >= '9000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood >= '9000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         

--Else
ELSE 'Res_Sales'
END AS District_SubClass
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
, pm.lrsn
, TRIM(pm.pin) AS PIN
, TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Type
, CASE 
WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
WHEN pm.ClassCD = '667' THEN 'Operating_Property'
WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
ELSE 'Unasigned_or_OldInactiveParcel'
END AS Property_Type_Class
, TRIM(pm.TAG) AS TAG
, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, pm.Improvement_Status -- <Improved vs Vacant
, pm.WorkValue_Land
, pm.WorkValue_Impv
, pm.WorkValue_Total
, pm.CostingMethod
, pm.LegalAcres



From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'

),

CTE_Permits AS (
SELECT DISTINCT
p.lrsn,
LTRIM(RTRIM(p.permit_ref)) AS REFERENCE_Num,
LTRIM(RTRIM(p.permit_desc)) AS DESCRIPTION,
p.permit_type,
LTRIM(RTRIM(c.tbl_element_desc)) AS PERMIT_TYPE_Desc,
p.filing_date AS FILING_DATE,
f.field_out AS WORK_ASSIGNED_DATE,
p.callback AS CALLBACK_DATE,
f.field_in AS WORK_DUE_DATE,
p.cert_for_occ AS DATE_CERT_FOR_OCC,
p.permservice AS PERMANENT_SERVICE_DATE,
f.need_to_visit AS NEED_TO_VISIT, 
LTRIM(RTRIM(f.field_person)) AS APPRAISER,
f.date_completed AS COMPLETED_DATE,
--Other Dates
LTRIM(RTRIM(p.permit_source)) AS PERMIT_SOURCE,
--Additional Data
p.cost_estimate AS COST_ESTIMATE,
p.sq_ft AS ESTIMATED_SF


FROM permits AS p --ON parcel.lrsn=p.lrsn


LEFT JOIN field_visit AS f ON p.field_number=f.field_number
  AND f.status='A'

LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'

WHERE p.status= 'A' 

/*
AND NOT (f.need_to_visit='N'
AND f.field_person IS NOT NULL
AND f.date_completed IS NOT NULL
    )
*/
--ORDER BY GEO, PIN, REFERENCE#;
)



SELECT DISTINCT

pmd.District
, pmd.GEO
, pmd.GEO_Name
, pmd.lrsn
, pmd.PIN
, pmd.AIN
, pmd.Improvement_Status -- <Improved vs Vacant
, pmd.CostingMethod
,comm.use_codes
,comm.year_built
,comm.eff_year_built
,comm.year_remodeled
,comm.condition
,comm.GradeType

,'CommBuildingSF>' AS SF_Analysis_CommBuilding
,commsf.CommSF
, pmd.WorkValue_Impv
, CASE 
    WHEN commsf.CommSF = 0 THEN NULL  -- Handle division by zero
    ELSE (pmd.WorkValue_Impv / commsf.CommSF)
  END AS ValuePerSF_Imp

,'Acres_SF>' AS SF_Analysis_Acres_SF
, pmd.LegalAcres
, (pmd.LegalAcres * 43560) AS LegalSF
, pmd.WorkValue_Land
, CASE 
    WHEN (pmd.LegalAcres * 43560) = 0 THEN NULL  -- Handle division by zero
    ELSE (pmd.WorkValue_Land / (pmd.LegalAcres * 43560))
  END AS ValuePerSF_Land

, pmd.WorkValue_Total
, CASE 
    WHEN (commsf.CommSF + (pmd.LegalAcres * 43560)) = 0 THEN NULL  -- Handle division by zero
    ELSE (pmd.WorkValue_Total / commsf.CommSF)
  END AS TotalValuePer_ImpSFOnly

/*
Terrys said not to include the land in the total SF, which is odd, but sure why not
, CASE 
    WHEN (commsf.CommSF + (pmd.LegalAcres * 43560)) = 0 THEN NULL  -- Handle division by zero
    ELSE (pmd.WorkValue_Total / (commsf.CommSF + (pmd.LegalAcres * 43560)))
  END AS ValuePerSF_ImpPlusLand_Total
*/

, pmd.ClassCD
, pmd.Property_Class_Type
, pmd.Property_Type_Class
, pmd.TAG
, pmd.Owner
, pmd.SitusAddress
, pmd.SitusCity

,perm.REFERENCE_Num
,perm.DESCRIPTION
,permit_type
,perm.PERMIT_TYPE_Desc
,perm.FILING_DATE
,perm.WORK_ASSIGNED_DATE
,perm.CALLBACK_DATE
,perm.WORK_DUE_DATE
,perm.DATE_CERT_FOR_OCC
,perm.PERMANENT_SERVICE_DATE
,perm.NEED_TO_VISIT
,perm.APPRAISER
,perm.COMPLETED_DATE
,perm.PERMIT_SOURCE
,perm.COST_ESTIMATE
,perm.ESTIMATED_SF



FROM CTE_ParcelMaster_SpecialRequest AS pmd

LEFT JOIN CTE_Improvements_Commercial AS comm 
  ON pmd.lrsn=comm.lrsn
  AND comm.RowNum = 1

LEFT JOIN CTE_CommBldgSF AS commsf 
  ON pmd.lrsn=commsf.lrsn

LEFT JOIN CTE_Permits AS perm
  ON perm.lrsn=pmd.lrsn
  AND permit_type = '2'

WHERE pmd.District = 'Commercial'



ORDER BY District, GEO, PIN, use_codes;


























