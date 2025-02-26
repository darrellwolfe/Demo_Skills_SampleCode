--NOTE: For HOEX from Cadaster, it will only pull from a locked roll
  --If the current year roll is locked, and you use @Year no values will populate
  --If the @YearPrev is used, you will pull last year's cadasters not this years

DECLARE @Year int = 2024;
DECLARE @YearPrev int = @Year - 1;
DECLARE @YearPrevPrev int = @Year - 2; 

DECLARE @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2);
DECLARE @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2);

DECLARE @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101';
DECLARE @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101';
DECLARE @EffYear0101PreviousPrevious varchar(8) = Cast(@YearPrevPrev as varchar) + '0101';

DECLARE @ValEffDateCurrent date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE);
DECLARE @ValEffDatePrevious date = CAST(CAST(@YearPrev as varchar) + '-01-01' AS DATE);

DECLARE @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%';
DECLARE @EffYear0101PreviousPreviousLike varchar(8) = Cast(@YearPrevPrev as varchar) + '%';
DECLARE @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%';

DECLARE @ValueTypehoex INT = 305;
--305 HOEX_Exemption Homeowner Exemption
DECLARE @ValueTypeimp INT = 103;
--103 Imp Assessed Improvement Assessed
DECLARE @ValueTypeland INT = 102;
--102 Land Assessed Land Assessed
DECLARE @ValueTypetotal INT = 109;
--109 Total Value Total Value
DECLARE @NetTaxableValueImpOnly INT = 458;
--458 Net Imp Only Net Taxable Value Imp Only
DECLARE @NetTaxableValueTotal INT = 455;
--455 Net Tax Value Net Taxable Value

DECLARE @NewConstruction INT = 651;
--651 NewConstByCat New Construction
DECLARE @AssessedByCat INT = 470;
--470 AssessedByCat Assessed Value

WITH CTE_ParcelMaster AS (
SELECT DISTINCT
pm.lrsn [LRSN],
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
,pm.neighborhood AS GEO
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_AllocationLevel AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,c.ValueAmount  AS Cadaster_Value
,c.TypeCode AS CadasterValyeType
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  ON c.CadRollId = r.Id
  AND c.CadInvId = i.Id
  AND c.ValueType = @ValueTypetotal -- Variable

WHERE r.AssessmentYear IN (@Year)
AND CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
)

Select Distinct
pmd.*
,al.*

From CTE_AllocationLevel AS al
Join CTE_ParcelMaster AS pmd
  On pmd.lrsn = al.lrsn

Where al.Cadaster_Value = 0

