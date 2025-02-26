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

,CASE 
  WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040'
    , '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  
  WHEN pm.ClassCD IN ('527', '526') THEN 'Condos'

  WHEN pm.ClassCD IN ('546', '548', '565') THEN 'Manufactered_Home'
  WHEN pm.ClassCD IN ('555') THEN 'Floathouse_Boathouse'
  WHEN pm.ClassCD IN ('550','549','451') THEN 'LeasedLand'

  WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416'
  , '421', '435', '438', '442', '461') THEN 'Commercial_Industrial'

  WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '561') THEN 'Residential'

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

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
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
),

CTE_Total AS (
SELECT DISTINCT
i.RevObjId AS lrsn
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
/*
Declare @AssessedByCat INT = 470;
--470 AssessedByCat Assessed Value
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
*/
--WHERE r.AssessmentYear IN (@Year)
WHERE r.AssessmentYear BETWEEN @YearPrevFiveYear AND @Year
--Declare @Year int = 2024; -- Input THIS year here
--Declare @YearPrevFiveYear int = @Year - 4; -- Input the year here

--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
--And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
--And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId --,c.FullGroupCode
,c.FullGroupCode
,r.AssessmentYear

),

CTE_AllocationsGroupCodeKey AS (
SELECT 
c.tbl_type_code AS CodeType
,TRIM(c.tbl_element) AS GroupCode_KC
,LEFT(TRIM(c.tbl_element),2) AS GroupCode_STC
,TRIM(c.tbl_element_desc) AS CodeDescription
,CASE 
    WHEN TRIM(c.tbl_element_desc) LIKE '%EXEMPT%' THEN 'Exempt_Property'
    WHEN TRIM(c.tbl_element_desc) LIKE '%OPERATING%' THEN 'Operating_Property'
    WHEN TRIM(c.tbl_element_desc) LIKE '%QIE%' THEN 'Qualified_Improvement_Expenditure'
    WHEN TRIM(c.tbl_element) LIKE '%P%' THEN 'Business_Personal_Property'
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('98','99') THEN 'Non-Allocated_Error'
    
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('25','26','27') THEN 'Condos'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('25') THEN 'Common_Area'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('26') THEN 'Condo_Residential'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('27') THEN 'Condo_Commercial'
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('81') THEN 'Exempt_Property'
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('19') THEN 'RightOfWay_ROW_Cat19'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('49','50','51') THEN 'Imp_On_LeasedLand'
  
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('45') THEN 'Operating_Property'
    
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('12','15','20','34','37','41') THEN 'Residential'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('30','31','32') THEN 'Non-Res'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('13','16','21','35','38','42'
                        ,'14','17','22','36','39','43') THEN 'Commercial_Industrial'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('13','16','21','35','38','42') THEN 'Commercial'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('14','17','22','36','39','43') THEN 'Industrial'
    
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('46','47','48','55','65') THEN 'Mobile_Home'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('01','03','04','05','06'
            ,'07','08','09','10','11','33') THEN 'Timber_Ag'

    ELSE 'Other'
  END AS GC_Category

,CASE
  --Improvement Group Codes
  WHEN TRIM(c.tbl_element) IN (
      '25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', 
      '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', 
      '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', 
      '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', 
      '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P', '81', '81P')
      THEN 'GC_Improvement'
      --
  -- Land Group Codes
  WHEN TRIM(c.tbl_element) IN (
      '01', '03', '04', '05', '06', '07', '09', '10', '10H', '11', '12', '12H', '13', '14', '15', '15H', '16', '17', 
      '18', '19', '20', '20H', '21', '22', '25L', '26LH', '27L', '81L')
      THEN 'GC_Land'
  --Land_GroupCode
  ELSE 'OtherCode'
  END AS CodeClass

FROM codes_table AS c
WHERE c.tbl_type_code = 'impgroup'
--AND c.code_status = 'A' 
--AND c.tbl_element_desc LIKE '%condo%'

)


SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.Owner
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.TAG
,tif.TIFId
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF
 
,'AssessedValues' AS AssessedValues
,cadtotal.Cadaster_Value AS AssesedTotal
,cadtotal.AssessmentYear
,CONCAT('01/01/',cadtotal.AssessmentYear) AS AssementDate

,'PCC_ClassCd' AS PCC_ClassCd
,pmd.Property_Class_Category
,pmd.ClassCD
,pmd.Property_Class_Description

,'GroupCode' AS GroupCode
,gckey.GC_Category
,cadtotal.FullGroupCode
,gckey.CodeDescription
,gckey.CodeClass

,'SitusInfo' AS SitusInfo
, CASE
    WHEN pmd.SitusCity IS NULL THEN 'COUNTYAddress_or_NoSitusAddress'
    WHEN pmd.SitusCity = '0' THEN 'COUNTYAddress_or_NoSitusAddress'
    WHEN pmd.SitusCity = ' ' THEN 'COUNTYAddress_or_NoSitusAddress'
    ELSE TRIM(pmd.SitusCity)
  END AS SitusCity
,pmd.Acres_Category
,pmd.LegalAcres
,pmd.CostingMethod
,pmd.Improvement_Status 


FROM CTE_ParcelMaster AS pmd
--Cadastre Assessed Values Total
JOIN CTE_Total AS cadtotal
  ON cadtotal.lrsn = pmd.lrsn
--GroupCodeKey
Left Join CTE_AllocationsGroupCodeKey AS gckey
  On gckey.GroupCode_KC = cadtotal.FullGroupCode
--Check TIFs
Left Join CTE_TAG_TA_TIF_Key AS tif
  On pmd.TAG = tif.TAG

--Where pmd.Owner LIKE '%KOOTENAI HEALTH%'
--Where gckey.Category IS NULL
/*
Group By
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.Owner
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,cadtotal.FullGroupCode
,cadtotal.AssessmentYear
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Property_Class_Type
,pmd.TAG
,tif.TIFId
,tif.TIF
,pmd.LegalAcres
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 
*/

ORDER BY District, GEO, PIN;