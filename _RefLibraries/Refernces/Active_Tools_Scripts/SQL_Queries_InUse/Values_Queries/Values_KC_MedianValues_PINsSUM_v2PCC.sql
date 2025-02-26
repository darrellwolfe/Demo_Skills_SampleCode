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

I ran this one script in Power Query,
then used it as a reference "ref" to build the individual buckets

-- To Find Cadaster Types
Select Distinct
vt.id
,vt.ShortDescr
,vt.Descr
From ValueType AS vt
--Where vt.Descr LIKE '%by%'
Order By vt.Descr

*/








Declare @Year int = 2024; -- Input THIS year here
Declare @YearPrevFiveYear int = @Year - 4; -- Input the year here


Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here

--NOTE: For HOEX from Cadaster, it will only pull fro a locked roll
  --If the current year roll is locked, and you use @Year no values will populate
  --If the @YearPrev is used, you will pull last year's cadasters not this years

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'


--EXACT
Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101PreviousPrevious varchar(8) = Cast(@YearPrevPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

-- Declaring and setting the current year effective date
--ONLY want the 01/01 values for each year, NOT the Occupancy values posted later in the year.
Declare @ValEffDateCurrent date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
-- Declaring and setting the previous year effective date
--ONLY want the 01/01 values for each year, NOT the Occupancy values posted later in the year.
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

Declare @AssessedAcres INT = 107;
--107 Total Acres Total Acres


WITH

CTE_CadValues AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,i.GeoCd AS GEO
,i.AIN
,i.PIN
,TRIM(i.TAGDescr) AS TAG
,i.ClassCd
,c.FullGroupCode
,r.AssessmentYear
,SUM(c.ValueAmount) AS Cadaster_Value

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
WHERE r.AssessmentYear BETWEEN @YearPrevFiveYear AND @Year
Group By i.RevObjId,i.GeoCd,i.AIN,i.PIN,i.TAGDescr,i.ClassCd,c.FullGroupCode,r.AssessmentYear
),

CTE_CadAcres AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,r.AssessmentYear
,SUM(c.ValueAmount) AS Cadaster_Acres
/*
,i.GeoCd AS GEO
,i.AIN
,i.PIN
,TRIM(i.TAGDescr) AS TAG
,i.ClassCd
,c.FullGroupCode
,r.AssessmentYear
,SUM(c.ValueAmount) AS Cadaster_Value
*/
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedAcres -- Variable
  --Declare @AssessedAcres INT = 107;
  --107 Total Acres Total Acres
WHERE r.AssessmentYear BETWEEN @YearPrevFiveYear AND @Year
Group By i.RevObjId, r.AssessmentYear
--,i.GeoCd,i.AIN,i.PIN,i.TAGDescr,i.ClassCd,c.FullGroupCode,r.AssessmentYear
),


CTE_ClassCDSysType AS (
Select
tbl_type_code AS PCC
,CAST(tbl_element AS INT) AS ClassCD
,tbl_element_desc AS ClassCD_Desc
,CodesToSysType AS ClassCD_SystemType
,CASE 
  WHEN CAST(tbl_element AS INT) IN ('010', '020', '021', '022', '030', '031', '032', '040'
    , '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  
  WHEN CAST(tbl_element AS INT) IN ('527', '526') THEN 'Condos'

  WHEN CAST(tbl_element AS INT) IN ('546', '548', '565') THEN 'Manufactered_Home'
  WHEN CAST(tbl_element AS INT) IN ('555') THEN 'Floathouse_Boathouse'
  WHEN CAST(tbl_element AS INT) IN ('550','549','451') THEN 'LeasedLand'

  WHEN CAST(tbl_element AS INT) IN ('314', '317', '322', '336', '339', '343', '413', '416'
  , '421', '435', '438', '442', '461') THEN 'Commercial_Industrial'

  WHEN CAST(tbl_element AS INT) IN ('411', '512', '515', '520', '534', '537', '541', '561') THEN 'Residential'

  WHEN CAST(tbl_element AS INT) IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  
  WHEN CAST(tbl_element AS INT) IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'

  WHEN CAST(tbl_element AS INT) = '667' THEN 'Operating_Property'
  WHEN CAST(tbl_element AS INT) = '681' THEN 'Exempt_Property'
  WHEN CAST(tbl_element AS INT) = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'

  ELSE 'Unasigned_or_OldInactiveParcel'

END AS Property_Class_Category
From codes_table
Where tbl_type_code LIKE '%PCC%'
And code_status = 'A'
--Order by tbl_element_desc
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
  WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
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
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,pm.LegalAcres
, CASE
    WHEN pm.LegalAcres < 1 THEN 'Acres_LessThan_1'
    WHEN pm.LegalAcres BETWEEN 1 AND 4.9999 THEN 'Acres_1-5'
    WHEN pm.LegalAcres > 5 THEN 'Acres_Over_5'  
    ELSE 'NoAcres_Other'
  END AS Acres_Category
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod


,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.ClassCD NOT LIKE '070%'
--AND pm.EffStatus = 'A'
),

CTE_TAG_TA_TIF_Key AS (
SELECT DISTINCT 
tag.Id AS TAGId
,TRIM(tag.Descr) AS TAG
,tif.Id AS TIFId
,TRIM(tif.Descr) AS TIF
--,ta.Id AS TaxAuthId
--,TRIM(ta.Descr) AS TaxAuthority

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
/*
--TAGTaxAuthority Key
LEFT JOIN TAGTaxAuthority 
  ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
--TaxAuthority Table
LEFT JOIN TaxAuthority AS ta 
  ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
--CTE_ JOIN, only want TAGs in this TaxAuth
*/
WHERE tag.EffStatus = 'A'
And tif.Descr LIKE '%URD%'
)

SELECT DISTINCT
pmd.District
,cv.GEO
,'PropInfo' AS PropInfo
,cv.lrsn
,cv.AIN
,cv.AIN
,cv.PIN
,cv.TAG
,tif.TIFId
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF
--,cv.ClassCd --This is actually the system type class code not the pcc number
,c2s.ClassCD
,c2s.ClassCD_Desc


CASE
  WHEN cv.PIN 

  ELSE c2s.Property_Class_Category

--,c2s.Property_Class_Category





--,cv.FullGroupCode
,'CadastreInfo' AS CadastreInfo
,cv.AssessmentYear
,SUM(cv.Cadaster_Value) AS CadAssessed_Value
,SUM(ca.Cadaster_Acres) AS Cadaster_Acres
, CASE
    WHEN SUM(ca.Cadaster_Acres) < 1 THEN 'Acres_LessThan_1'
    WHEN SUM(ca.Cadaster_Acres) BETWEEN 1 AND 4.9999 THEN 'Acres_1-5'
    WHEN SUM(ca.Cadaster_Acres) > 5 THEN 'Acres_Over_5'  
    ELSE 'NoAcres_Other'
  END AS Acres_Category

,'SitusInfo' AS SitusInfo
, CASE
    WHEN pmd.SitusCity IS NULL THEN 'COUNTYAddress_or_NoSitusAddress'
    WHEN pmd.SitusCity = '0' THEN 'COUNTYAddress_or_NoSitusAddress'
    WHEN pmd.SitusCity = ' ' THEN 'COUNTYAddress_or_NoSitusAddress'
    ELSE TRIM(pmd.SitusCity)
  END AS SitusCity

FROM CTE_CadValues AS cv
JOIN CTE_ClassCDSysType AS c2s
  ON c2s.ClassCD_SystemType = cv.ClassCd
LEFT JOIN CTE_CadAcres AS ca
  On ca.lrsn = cv.lrsn
  And ca.AssessmentYear=cv.AssessmentYear
LEFT JOIN CTE_ParcelMaster AS pmd
  On pmd.lrsn = cv.lrsn
Left Join CTE_TAG_TA_TIF_Key AS tif
  On tif.TAG = cv.TAG
  
GROUP BY
pmd.District
,cv.GEO
,cv.lrsn
,cv.AIN
,cv.AIN
,cv.PIN
,cv.TAG
,tif.TIFId
,tif.TIF 
,cv.AssessmentYear
,c2s.ClassCD
,c2s.ClassCD_Desc
,c2s.Property_Class_Category
,pmd.SitusCity
