-- !preview conn=conn


/*
AsTxDBProd
GRM_Main

**PERSONAL PROPERTY QUERY REQUIRES YEARLY UPDATES IN SEVERAL TABLES, REVIEW ALL YEARS
2023 TO 2024, ETC.

*/


--------------------------------
--Variables BEGIN
--------------------------------
DECLARE @Year INT = 2024; -- Input year

-- Use CONCAT to create date strings for the start and end of the year
DECLARE @LastYearCertFrom INT = CONCAT(@Year - 1, '0101');
DECLARE @LastYearCertTo INT = CONCAT(@Year - 1, '1231');

-- Date and time for January 1 of the input year
DECLARE @Jan1ThisYear1 DATETIME = CONCAT(@Year, '-01-01 00:00:00');
DECLARE @Jan1ThisYear2 DATETIME = CONCAT(@Year, '-01-01 23:59:59');

-- Use CONCAT to create certification date strings for the current year
DECLARE @ThisYearCertFrom INT = CONCAT(@Year, '0101');
DECLARE @ThisYearCertTo INT = CONCAT(@Year, '1231');

-- Use CONCAT for creating range values for MPPV
DECLARE @ThisYearMPPVFrom INT = CONCAT(@Year, '00000');
DECLARE @ThisYearMPPVTo INT = CONCAT(@Year, '99999');

-- Declare cadaster year as the input year
DECLARE @CadasterYear INT = @Year;

DECLARE @NoteYear VARCHAR(10) = CONCAT('%',@Year,'%');

WITH
--------------------------------
--CTEs BEGIN
--------------------------------
CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
  Select Distinct
  pm.lrsn
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Desc
, TRIM(pm.TAG) AS TAG
, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip
--, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.AttentionLine) AS Attn
, TRIM(pm.MailingAddress) AS MailingAddress
, TRIM(pm.MailingCityStZip) AS MailingCSZ
, TRIM(pm.DisplayDescr) AS LegalDescription

, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.LegalAcres
,  pm.Improvement_Status -- <Improved vs Vacant


  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
  And pm.ClassCD IN ('020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090')
  AND pm.PIN NOT LIKE 'U%'
  AND pm.PIN NOT LIKE 'G%'
--Order By District,GEO;
),

CTE_MPPV AS (
--Looking for Aquisition Value and Appraised Value from MPPV, aggragated by lrsn (mPropertyId); rather than by individual asset.
--DECLARE @ThisYearMPPVFrom INT = '202300000';
--DECLARE @ThisYearMPPVTo INT = '202399999';
SELECT 
mPropertyId AS lrsn
,SUM(mAcquisitionValue) AS mAcquisitionValue
,SUM(
 CASE 
--mOverrideReason = 1 --This means the checkmark is checked
--mOverrideReason = 0 --This means the checkmark is NOT checked  
    WHEN mOverrideReason = 0 THEN mAppraisedValue
    WHEN mOverrideReason = 1 THEN mOverrideValue
    ELSE mAppraisedValue
  END
  ) AS mAppraisedValue

FROM tPPAsset
WHERE mEffStatus = 'A' 
--AND mPropertyId = 510587 -- Use as Test
And mbegTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo
And mendTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo

GROUP BY 
mPropertyId
--,mAssetCategory
--,mScheduleName
),

--Pulling in Aumentum Notes
CTE_Note_Status AS (
SELECT
n.createTimestamp,
--n.createdByUserId,
CONCAT(TRIM(up.FirstName), ' ', TRIM(up.LastName)) AS UserName,
--up.FirstName,
--up.LastName,
--n.effStatus
n.objectId, --lrsn or RevObjId
n.noteText,
n.taxYear
FROM Note AS n
JOIN UserProfile AS up
  ON up.Id = n.createdByUserId
JOIN CTE_ParcelMaster AS pmd
  ON pmd.lrsn = n.objectId

WHERE n.effStatus = 'A'
AND (noteText LIKE '%AUDIT%'
    AND noteText LIKE '%24%')

AND YEAR(createTimestamp) = @Year
--noteText LIKE @NoteYear
),

--Looking for the Personal Property 63-602KK $250,000 exemption from Aumentum Modifiers, paying special attention to the shared exemptions
CTE_63602KK AS (
SELECT
lrsn,
TRIM(ModifierDescr) AS ModifierDescr,
ModifierPercent,
CAST(OverrideAmount AS BIGINT) AS PPExemption602KK

FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%602KK%'
AND PINStatus='A'
),

--2023 Looking for Cert and Assessed Values (should match) for prior year(s) and current year. However, current year will not show until after Price & Post.
CTE_CadastreValues AS (
Select Distinct
c.TaxYear
,c.CadRollId
,r.Descr AS AssessmentType
,c.TAG
,c.LRSN
,c.PIN
,c.ValueAmount  AS Cadaster_Value
 --sum(ValueAmount) 

 From tsbv_cadastre AS c 
 
   Join TagTaxAuthority AS tta
   On tta.tagid = c.tagid
   And tta.EffStatus = 'A'
   And tta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority ttasub where ttasub.id = tta.id and ttasub.BegEffYear <= @CadasterYear)
 
 
 Join TaxAuthority AS ta
   On ta.id = tta.TaxAuthorityId
   And ta.EffStatus = 'A'
   And ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id and tasub.BegEffYear <= @CadasterYear)
 
 
 Join Taf AS taf
   On taf.TaxAuthorityId = ta.id
   And taf.EffStatus = 'A'
   And taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id and tafsub.BegEffYear <= @CadasterYear)
 
 
 Join Fund AS f
   On f.id = taf.fundId
   And f.EffStatus = 'A'
   And f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id and fsub.BegEffYear <= @CadasterYear)
 
 Join ValueType AS vt
   On vt.id = c.ValueType
   And vt.Id = 109
/*
455	Net Tax Value	Net Taxable Value
109	Total Value	Total Value -- aka Assessed Value
320	Total Exemptions	Total Exemptions
105	PP Assessed	Personal Property Assessed
262	PPPAssessed	Personal Property Assessed Prorated
*/

 Join CadRoll AS r
   On c.CadRollId = r.Id
   --And r.Id = '563' -- 2023 PERSONAL PROPERTY 2

 Where c.taxyear = @CadasterYear
  AND PIN like 'E%'
),

CTE_CadastreNetTaxable AS (
Select Distinct
c.TaxYear
,c.CadRollId
,r.Descr AS AssessmentType
,c.TAG
,c.LRSN
,c.PIN
,c.ValueAmount  AS Cadaster_Value
 --sum(ValueAmount) 

 From tsbv_cadastre AS c 
 
   Join TagTaxAuthority AS tta
   On tta.tagid = c.tagid
   And tta.EffStatus = 'A'
   And tta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority ttasub where ttasub.id = tta.id and ttasub.BegEffYear <= @CadasterYear)
 
 
 Join TaxAuthority AS ta
   On ta.id = tta.TaxAuthorityId
   And ta.EffStatus = 'A'
   And ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id and tasub.BegEffYear <= @CadasterYear)
 
 
 Join Taf AS taf
   On taf.TaxAuthorityId = ta.id
   And taf.EffStatus = 'A'
   And taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id and tafsub.BegEffYear <= @CadasterYear)
 
 
 Join Fund AS f
   On f.id = taf.fundId
   And f.EffStatus = 'A'
   And f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id and fsub.BegEffYear <= @CadasterYear)
 
 Join ValueType AS vt
   On vt.id = c.ValueType
   And vt.Id = 455
/*
455	Net Tax Value	Net Taxable Value
109	Total Value	Total Value -- aka Assessed Value
320	Total Exemptions	Total Exemptions
105	PP Assessed	Personal Property Assessed
262	PPPAssessed	Personal Property Assessed Prorated
*/

 Join CadRoll AS r
   On c.CadRollId = r.Id
   --And r.Id = '563' -- 2023 PERSONAL PROPERTY 2

 Where c.taxyear = @CadasterYear
  AND PIN like 'E%'
)




---------------------------------------
--Begins Primary Query
---------------------------------------

--------------------------
-- SELECT START HERE
-------------------------

SELECT DISTINCT
CAST(pmd.ClassCD AS INT) AS ClassCD
,pmd.Property_Class_Desc
,pmd.lrsn
,pmd.AIN
,pmd.PIN
,pmd.Owner
,mppv.mAcquisitionValue
,mppv.mAppraisedValue
,kk602.PPExemption602KK
,(mppv.mAppraisedValue-kk602.PPExemption602KK) AS NetTaxable

,cvc.Cadaster_Value AS CadAppraisedValue_2024
,net.Cadaster_Value AS CadNetTaxableValue_2024

,((mppv.mAppraisedValue-kk602.PPExemption602KK) - net.Cadaster_Value) AS New_Value_Minus_CadastreValue

,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,statusnotes.createTimestamp
,statusnotes.UserName
,statusnotes.noteText AS StatusNotes
,pmd.Attn
,pmd.MailingAddress
,pmd.MailingCSZ
,pmd.TAG



--------------------------
-- FROM START HERE
-------------------------

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_MPPV AS mppv 
  ON pmd.lrsn=mppv.lrsn

LEFT JOIN CTE_63602KK AS kk602
  ON pmd.lrsn=kk602.lrsn

JOIN CTE_CadastreValues AS cvc --current
  ON pmd.lrsn=cvc.LRSN

JOIN CTE_CadastreNetTaxable AS net --current
  ON pmd.lrsn=net.LRSN
  AND cvc.LRSN = net.LRSN

JOIN CTE_Note_Status AS statusnotes
  ON pmd.lrsn=statusnotes.objectId

--Order By
---------------------------------------
ORDER BY pmd.Owner, ClassCD, pmd.PIN;



