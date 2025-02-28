
-- !preview conn=conn




Declare @Year int = 2024; -- Input THIS year here

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

CTE_Memo_NC AS (
Select
lrsn
--,memo_id
,STRING_AGG(memo_text, ' | ') AS NC
--JOIN Memos, change to current year NC22, NC23
From memos 
--  ON parcel.lrsn=mNC.lrsn 
WHere memo_id = @NCYearPrevious 
  --And memo_line_number = '1'
  And status = 'A'
Group By lrsn
),

CTE_DistrictKey AS (
  SELECT
      CASE
          WHEN GEO >= 9000 THEN 'Manufactured_Homes'
          WHEN GEO >= 6003 THEN 'District_6'
          WHEN GEO = 6002 THEN 'Manufactured_Homes'
          WHEN GEO = 6001 THEN 'District_6'
          WHEN GEO = 6000 THEN 'Manufactured_Homes'
          WHEN GEO >= 5003 THEN 'District_5'
          WHEN GEO = 5002 THEN 'Manufactured_Homes'
          WHEN GEO = 5001 THEN 'District_5'
          WHEN GEO = 5000 THEN 'Manufactured_Homes'
          WHEN GEO >= 4000 THEN 'District_4'
          WHEN GEO >= 3000 THEN 'District_3'
          WHEN GEO >= 2000 THEN 'District_2'
          WHEN GEO >= 1021 THEN 'District_1'
          WHEN GEO = 1020 THEN 'Manufactured_Homes'
          WHEN GEO >= 1001 THEN 'District_1'
          WHEN GEO = 1000 THEN 'Manufactured_Homes'
          WHEN GEO >= 451 THEN 'Commercial'
          WHEN GEO = 450 THEN 'Specialized_Cell_Towers'
          WHEN GEO >= 1 THEN 'Commercial'
          WHEN GEO = 0 THEN 'N/A_or_Error'
          ELSE NULL
      END AS District,
      GEO
  FROM (
      SELECT DISTINCT
          pm.neighborhood AS GEO
      FROM TSBv_PARCELMASTER AS pm
      WHERE pm.EffStatus = 'A'
      AND pm.neighborhood <> 0
  ) AS Subquery
),

CTE_ParcelMaster AS (
    --------------------------------
    --ParcelMaster
    --------------------------------
    Select Distinct
    pm.lrsn
  ,  LTRIM(RTRIM(pm.pin)) AS PIN
  ,  LTRIM(RTRIM(pm.AIN)) AS AIN
  ,  pm.neighborhood AS GEO
  ,  LTRIM(RTRIM(pm.NeighborHoodName)) AS GEO_Name
  ,  LTRIM(RTRIM(pm.PropClassDescr)) AS ClassCD
  ,  LTRIM(RTRIM(pm.TAG)) AS TAG
  ,  LTRIM(RTRIM(pm.DisplayName)) AS Owner
  ,  LTRIM(RTRIM(pm.SitusAddress)) AS SitusAddress
  ,  LTRIM(RTRIM(pm.SitusCity)) AS SitusCity
  ,  pm.LegalAcres
  ,  pm.TotalAcres
  ,  pm.Improvement_Status
  ,  pm.WorkValue_Land
  ,  pm.WorkValue_Impv
  ,  pm.WorkValue_Total
  ,  pm.CostingMethod
    
    From TSBv_PARCELMASTER AS pm
    
    Where pm.EffStatus = 'A'
      AND pm.ClassCD NOT LIKE '070%'
      AND pm.ClassCD NOT LIKE '060%'
      AND pm.ClassCD NOT LIKE '090%'
      
    Group By
    pm.lrsn,
    pm.pin,
    pm.AIN,
    pm.PropClassDescr,
    pm.neighborhood,
    pm.NeighborHoodName,
    pm.TAG,
    pm.DisplayName,
    pm.SitusAddress,
    pm.SitusCity,
    pm.LegalAcres,
    pm.TotalAcres,
    pm.Improvement_Status,
    pm.WorkValue_Land,
    pm.WorkValue_Impv,
    pm.WorkValue_Total,
    pm.CostingMethod
  
)


SELECT DISTINCT
ap.lrsn
, ap.year_appealed
,nc.NC
, dk.District
, ap.assignedto
, pm.GEO
, pm.GEO_Name
, pm.PIN
, pm.AIN
--ap.det_type,
, CASE
    WHEN ap.det_type = 1 THEN 'BOE'
    WHEN ap.det_type = 2 THEN 'SBTA'
    WHEN ap.det_type = 3 THEN 'District Court'
    WHEN ap.det_type = 4 THEN 'AS-54'
    WHEN ap.det_type = 5 THEN 'AS-52'
    ELSE NULL
  END AS Determination
  
, ap.appeal_id
, CAST(ap.hear_date AS DATE) AS HearingDate
, CAST(ap.hear_date AS TIME) AS HearingTime
, ap.hear_room
, TRIM(ap.det_req_review) Request_Review_Notes

--ap.appeal_status,
, CASE
    WHEN ap.appeal_status = 1 THEN 'Entered'
    WHEN ap.appeal_status = 2 THEN 'Scheduled'
    WHEN ap.appeal_status = 3 THEN 'Appeal Done-Pending Outcome'
    WHEN ap.appeal_status = 4 THEN 'Value Determined'
    WHEN ap.appeal_status = 5 THEN 'Appeal Dismissed'
    ELSE NULL
  END AS Status

, pm.Owner
, pm.SitusAddress
, pm.SitusCity
, ap.PetitionerName
, ap.PetitionerAddress1
, ap.PetitionerAddress2
, ap.PetitionerCity
, ap.PetitionerState
, ap.PetitionerZip
, ap.final_date
, ap.deter_date
, TRIM(ap.det_explanation) AS Explanation
, TRIM(ap.grounds) AS Grounds
, TRIM(ap.local_grounds) AS Local_Grounds
--ap.app_res_cat,
, CASE
    WHEN ap.app_res_cat = 1 THEN 'In Favor of Assessor'
    WHEN ap.app_res_cat = 2 THEN 'In Favor of Tax Payer'
    WHEN ap.app_res_cat = 3 THEN 'Other Resolution or New Information Provided'
    ELSE NULL
  END AS Resolution_Category


FROM APPEALS AS ap

JOIN CTE_ParcelMaster AS pm
  ON ap.lrsn=pm.lrsn

JOIN CTE_DistrictKey AS dk
  ON pm.GEO=dk.GEO

Join CTE_Memo_NC AS nc
  On pm.lrsn = nc.lrsn

  
WHERE ap.status = 'A'
AND ap.year_appealed = @Year
--AND ap.det_type = 2
AND ap.app_res_cat <> 1

ORDER BY
GEO, appeal_id;



