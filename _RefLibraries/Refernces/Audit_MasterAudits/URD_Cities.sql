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

1. Give me every parcel that has a URD in the legal description, 
  LEFT JOIN the URD Modifier
  Look for parcels missing the modifier and parcels with 0 or null

2. Base - Net taxable shouldn't be zero or negative
3. Base - Assessed shouldn't be zero or negative

*/


DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year


DECLARE @TaxYear INT = @Year; 
-- Current Tax Year -- Change this to the current tax year
DECLARE @TaxYearPrevious INT = CAST(@TaxYear - 1 as INT);

Declare @CertValueDateFROM varchar(8) = Cast(@TaxYear - 1 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@TaxYear - 1 as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20230101';
--Declare @CertValueDateTO INT = '20231231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231


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
,TRIM(pm.DisplayDescr) AS LegalDescription
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(NULLIF(pm.SitusCity,'')) AS SitusCity
,pm.LegalAcres


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
And (pm.DisplayDescr LIKE '%URD%'
--    Or pm.DisplayDescr LIKE '%URA%'
    Or pm.neighborhood <> 0
    Or pm.neighborhood IS NOT NULL )
AND pm.SitusCity IS NOT NULL

),

CTE_TAG_TA_TIF_Key AS (

  SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ta.Id AS TaxAuthId,
  TRIM(ta.Descr) AS TaxAuthority
  
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
  --TAGTaxAuthority Key
  LEFT JOIN TAGTaxAuthority 
    ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
  --TaxAuthority Table
  LEFT JOIN TaxAuthority AS ta 
    ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
  --CTE_ JOIN, only want TAGs in this TaxAuth
  
  WHERE tag.EffStatus = 'A'
--  AND ta.id = '242'
  And tif.Descr IS NOT NULL

)

SELECT DISTINCT
--pmd.District
--,pmd.GEO
--,pmd.GEO_Name
--,pmd.lrsn
--,pmd.PIN
--,pmd.AIN
--,pmd.TAG
ttt.TIFId
,ttt.TIF
,pmd.SitusCity

FROM CTE_ParcelMaster AS pmd

JOIN CTE_TAG_TA_TIF_Key AS ttt
  On ttt.tag = pmd.tag

WHERE ttt.TIF IS NOT NULL
AND TRIM(pmd.SitusCity) IS NOT NULL
AND ttt.TIF LIKE '%URD'

ORDER BY ttt.TIFId

/*

SELECT
  COUNT(*) AS TotalCount,
  COUNT(pmd.SitusCity) AS NonNullSitusCityCount,
  COUNT(NULLIF(pmd.SitusCity, '')) AS NonEmptySitusCityCount
FROM CTE_ParcelMaster AS pmd

*/