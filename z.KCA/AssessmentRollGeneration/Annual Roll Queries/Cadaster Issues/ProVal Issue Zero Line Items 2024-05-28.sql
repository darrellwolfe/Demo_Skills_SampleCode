-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

*/

Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here

Declare @CertValueDateFROM varchar(8) = Cast(@Year - 1 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year - 1 as varchar) + '1231'; -- Generates '20230101' for the previous year

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'
Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'
--EXACT
Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101PreviousPrevious varchar(8) = Cast(@YearPrevPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
-- Declaring and setting the current year effective date
Declare @ValEffDateCurrent date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
-- Declaring and setting the previous year effective date
Declare @ValEffDatePrevious date = CAST(CAST(@YearPrev as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--LIKE
Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year
--Where eff_year LIKE '2023%'
--20230101
--20230804
Declare @EffYear0101PreviousPreviousLike varchar(8) = Cast(@YearPrevPrev as varchar) + '%'; -- Generates '20230101' for the previous year

Declare @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '20230101' for the previous year


Declare @ValueTypehoex INT = 305;
--    305 HOEX_Exemption Homeowner Exemption
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
Declare @NetTaxableValueImpOnly INT = 458;
--    458 Net Imp Only Net Taxable Value Imp Only
Declare @NetTaxableValueTotal INT = 455;
--    455 Net Tax Value Net Taxable Value

Declare @NewConstruction INT = 651;
--    651 NewConstByCat New Construction
Declare @AssessedByCat INT = 470;
--470 AssessedByCat Assessed Value


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
  WHEN pm.neighborhood = 0 THEN 'Personal-OperatingProperty_N/A_or_Error'
  ELSE NULL
END AS District

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity

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

CTE_WorksheetMarketValues AS(
SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_inc AS Worksheet_Land_Market,
    (r.income_value - r.land_mkt_val_inc) AS Worksheet_Imp_Market,
    r.income_value AS Worksheet_Total_Market

FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status = 'W'
AND r.method = 'I' 
--AND r.land_model = @LandModelId

UNION ALL

SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_cost AS Worksheet_Land_Market,
    r.cost_value AS Worksheet_Imp_Market,
    (r.cost_value + r.land_mkt_val_cost) AS Worksheet_Total_Market
    
FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status='W'
AND r.method = 'C' 
--AND r.land_model = @LandModelId
--ORDER BY GEO, PIN;
),


CTE_Cadastre AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value_Imp
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
/*
Declare @ValueTypehoex INT = 305;
--    305 HOEX_Exemption Homeowner Exemption
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
*/
WHERE r.AssessmentYear IN (@Year)
And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
And c.FullGroupCode NOT LIKE '81%'
--IMP Group Codes
And c.FullGroupCode IN (
    '25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', 
    '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', 
    '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', 
    '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', 
    '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P') 
    --, '81', '81L', '81P'
GROUP BY i.RevObjId 
),

CTE_Market AS (
SELECT 
v.lrsn
--,SUM(v.value) AS value
,v.extension
,v.improvement_id
,v.group_code
,v.assess_val
,v.value
,v.value_type
,v.dwelling_number
,v.line_number

FROM val_detail AS v
WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO
--Change to desired year
AND v.status = 'A'
),



CTE_ImprovementYears AS (
Select Distinct
i.lrsn
,i.extension
,e.ext_description
,i.dwelling_number
,i.imp_line_number
,i.improvement_id
,i.imp_type
,i.reproduction_cost1
,i.rem_value1
,i.true_tax_value1
,i.reproduction_cost3
,i.rem_value3
,i.true_tax_value3
,i.rcnld_value1
,i.rcnld_value3
,e.imp_tot_val2
,e.imp_tot_val3
,i.sound_value_code -- 3 means "None"
,i.sound_value_reason
,i.pct_complete
,e.UserId
,e.val_change_date
From improvements AS i
Join extensions AS e
  On i.lrsn = e.lrsn
  And i.extension = e.extension
  And e.status = 'A'
Where i.status = 'A'
  And e.status = 'A'

)


SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,iy.extension
--,market.extension
,iy.ext_description
,iy.imp_type
,iy.improvement_id
,iy.imp_line_number
,iy.reproduction_cost1
,iy.rem_value1
,iy.true_tax_value1
,market.group_code
,market.assess_val
,market.value
,market.value_type
,cad.Cadaster_Value_Imp
,wk.Worksheet_Imp_Market
,iy.sound_value_code
,iy.sound_value_reason
,iy.pct_complete
,iy.UserId
,iy.val_change_date
,market.line_number
,'Wk' AS WorksheetValues
,wk.Worksheet_Land_Market
,wk.Worksheet_Imp_Market
,wk.Worksheet_Total_Market
,wk.PriceMethod




,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.TAG
,pmd.SitusAddress
,pmd.SitusCity
,pmd.Improvement_Status 





FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_WorksheetMarketValues AS wk
  ON wk.lrsn = pmd.lrsn

LEFT JOIN CTE_ImprovementYears AS iy
  ON iy.lrsn = pmd.lrsn
  AND iy.extension NOT LIKE 'L%'
  JOIN CTE_Market AS market
    ON market.lrsn = iy.lrsn
    AND market.extension NOT LIKE 'L%'
    AND iy.extension = market.extension
    AND iy.improvement_id = market.improvement_id
    AND iy.dwelling_number = market.dwelling_number
  
LEFT JOIN CTE_Cadastre AS cad
  On pmd.lrsn = cad.lrsn
  --,SUM(c.ValueAmount) AS Cadaster_Value_Imp
  
  
WHERE (iy.sound_value_code = 0
    OR iy.sound_value_code IS NULL)
  AND market.group_code NOT IN ('19','98','99','81','81L','81P')
  
--  AND pmd.District <> 'Commercial'
  AND pmd.GEO > 999
  AND iy.extension LIKE 'C%'

  
--AND pmd.lrsn = 37452
--AND pmd.GEO = 29
--AND iy.sound_value_code <> 3
-- Sound Value Code 4 Means "True Tax Value"
/*
-- If Looking for TRUE TAX YES
WHERE iy.sound_value_code <> 0
AND iy.sound_value_code IS NOT NULL
--AND iy.sound_value_code <> 3
-- Sound Value Code 4 Means "True Tax Value"
*/

Order By District,GEO, PIN;


/*
CTE_Assessed AS (
  SELECT 
    lrsn,
    --Assessed Values
    v.land_assess AS AssessedValue_Land_wEx,
    v.imp_assess AS AssessedValue_Imp,
    (v.imp_assess + v.land_assess) AS AssessedValue_Total,
    v.eff_year AS Tax_Year_Assessed,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO
--Change to desired year
    AND v.status = 'A'
)
,ass.AssessedValue_Land_wEx
,ass.AssessedValue_Imp
,ass.AssessedValue_Total
,ass.Tax_Year_Assessed

LEFT JOIN CTE_Assessed AS ass
  ON ass.lrsn = pmd.lrsn
  AND ass.RowNumber = '1'
*/
