-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

WITH

CTE_CertVal AS (
  Select 
      v.lrsn,
      v.land_market_val AS Cert_Land,
      v.imp_val AS Cert_Imp,
      (v.imp_val + v.land_market_val) AS Cert_Total_Value,
      v.last_update AS Last_Updated,
  ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNum
  
  From valuation AS v --ON pm.lrsn = v.lrsn
  Where v.status = 'A'
    AND v.eff_year BETWEEN 20230101 AND 20231231
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
  
),

CTE_ResBldgSF AS (
  SELECT
    lrsn,
    SUM(finish_living_area) AS ResBldg_SF
  FROM res_floor
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_ManBldgSF AS (
  SELECT
    e.lrsn,
    SUM(i.imp_size) AS MH_SF
  FROM extensions AS e --ON kcv.lrsn=e.lrsn
  --AND e.status = 'A'
    JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M')
      --('M','','')
  WHERE e.status = 'A'
  GROUP BY e.lrsn
),

CTE_CommBldgSF AS (
  SELECT
    lrsn,
    SUM(area) AS CommSF
  FROM comm_uses
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_YearBuilt AS (
  SELECT
    e.lrsn,
    MAX(i.year_built) AS YearBuilt,
    MAX(i.eff_year_built) AS EffYear,
    MAX(i.year_remodeled) AS RemodelYear
  
  FROM extensions AS e --ON kcv.lrsn=e.lrsn
  --AND e.status = 'A'
  JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      --AND i.improvement_id IN ('M','','')  
    WHERE e.status = 'A'
  GROUP BY e.lrsn
),

CTE_SalePrice AS (
  SELECT
    lrsn,
    pxfer_date AS Last_Sale_Date,
    AdjustedSalePrice,
    ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY pxfer_date DESC) AS RowNum
  FROM transfer
  WHERE AdjustedSalePrice <> '0'
  GROUP BY lrsn, AdjustedSalePrice, pxfer_date
),

CTE_AppraiserKey AS (
  SELECT
      ap.assignedto AS AssignedTo,
      CASE
          WHEN ap.assignedto IN ('AAR', 'ARDW', 'DWAR') THEN 'Alex Reichert'
          WHEN ap.assignedto IN ('CMAB', 'RSAB', 'TSAB', 'ACB') THEN 'Andrew Buffin'
          WHEN ap.assignedto = 'AHH' THEN 'Aubrey Hollenbeck'
          WHEN ap.assignedto = 'BGK' THEN 'Bela Kovacs'
          WHEN ap.assignedto = 'BIC' THEN 'Ben Crotinger'
          WHEN ap.assignedto = 'RFS' THEN 'Bob Scott'
          WHEN ap.assignedto = 'BLC' THEN 'Brittany Crane'
          WHEN ap.assignedto IN ('CMG', 'RRCG', 'RSCG', 'CMCG', 'SHCG', 'EHCG', 'JLCG') THEN 'Chanice Giao'
          WHEN ap.assignedto = 'CDE' THEN 'Colette Erickson'
          WHEN ap.assignedto IN ('CCS', 'CS') THEN 'Colton Smith'
          WHEN ap.assignedto = 'CLM' THEN 'Cori Murrell'
          WHEN ap.assignedto IN ('DBDW', 'DGW', 'DWDB', 'DWEM', 'DWTJ') THEN 'Darrell Wolfe'
          WHEN ap.assignedto = 'DEB' THEN 'David Brazzle'
          WHEN ap.assignedto = 'DKB' THEN 'Donna Browne'
          WHEN ap.assignedto IN ('CMDH', 'DHH', 'DDH', 'RSDH', 'RRDH', 'EHDH', 'SHDH', 'GKDH', 'MWDH', 'JLDH') THEN 'Dustin Huddleston'
          WHEN ap.assignedto IN ('DAS', 'DSDB', 'DSTJ') THEN 'Dyson Savage'
          WHEN ap.assignedto = 'EAM' THEN 'Elizabeth Macgregor'
          WHEN ap.assignedto = 'EVH' THEN 'Eric Hart'
          WHEN ap.assignedto IN ('GRK', 'SHGK', 'CMGK', 'BBGK', 'ESGK', 'TSGK') THEN 'Garrett Kreitz'
          WHEN ap.assignedto = 'GRP' THEN 'Gina Price'
          WHEN ap.assignedto = 'HSS' THEN 'Heather Shackelford'
          WHEN ap.assignedto = 'HW' THEN 'Helga Wernicke'
          WHEN ap.assignedto = 'JCL' THEN 'James Labish'
          WHEN ap.assignedto IN ('JCB', 'JB') THEN 'Janice Ball'
          WHEN ap.assignedto IN ('JRT', 'RSJT', 'RRJT') THEN 'Jason Tweedy'
          WHEN ap.assignedto = 'JJP' THEN 'Joe Pounder'
          WHEN ap.assignedto = 'JJR' THEN 'Josiah Roberts'
          WHEN ap.assignedto = 'JGP' THEN 'Justin Parich'
          WHEN ap.assignedto = 'KKC' THEN 'Kathleen Clancy'
          WHEN ap.assignedto = 'KMM' THEN 'Kendall Mallery'
          WHEN ap.assignedto IN ('CMLB', 'LKB', 'TSLB', 'SHLB', 'BBLB', 'RSLB', 'RRLB') THEN 'Landen Butterfield'
          WHEN ap.assignedto = 'LAB' THEN 'Linda Buffington'
          WHEN ap.assignedto IN ('MJV', 'JBMV', 'TJJMV', 'MV', 'DMMV', 'MVDB') THEN 'Matthew Volz'
          WHEN ap.assignedto = 'MYG' THEN 'Michelle Goughnour'
          WHEN ap.assignedto IN ('MPW', 'PF') THEN 'Pat Fitzwater'
          WHEN ap.assignedto = 'PGF' THEN 'Pat Fitzwater'
          WHEN ap.assignedto = 'RRE' THEN 'Robin Egbert'
          WHEN ap.assignedto = 'REJ' THEN 'Rod Jones'
          WHEN ap.assignedto = 'RWR' THEN 'Ryan Rouse'
          WHEN ap.assignedto = 'SLH' THEN 'Shane Harmon'
          WHEN ap.assignedto = 'SHE' THEN 'Shelli Halloran'
          WHEN ap.assignedto = 'SRA' THEN 'Shelly Amos'
          WHEN ap.assignedto IN ('EHTH', 'RRTH', 'TH') THEN 'Taryn Hardway'
          WHEN ap.assignedto = 'TJJ' THEN 'Terry Jensen'
          WHEN ap.assignedto IN ('TKH', 'TKS') THEN 'Tony Harbison'
          WHEN ap.assignedto = 'VMW' THEN 'Vicki Williamson'
          ELSE 'Unknown' -- Default value if no match is found
      END AS Appraiser_User
      
      
  FROM APPEALS AS ap
  WHERE ap.status = 'A'
  AND ap.year_appealed = 2023
)



SELECT DISTINCT
ap.lrsn
, ap.year_appealed
, dk.District
, ap.assignedto
, Appraiser_User
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

--Building Details
, rsf.ResBldg_SF
, msf.MH_SF
, csf.CommSF
, yb.YearBuilt
, yb.EffYear
, yb.RemodelYear

--Values
, sp.Last_Sale_Date
, sp.AdjustedSalePrice
--Petitioner Stated/Requested Value
, ap.stated_land AS Petitioner_stated_land
, (ap.stated_val - ap.stated_land) AS Petitioner_stated_imp
, ap.stated_val AS Petitioner_stated_value

--Prior Certified
, ap.prior_land AS Prior_Cert_Land
, (ap.prior_val - ap.prior_land) AS Prior_Cert_Improvement
, ap.prior_val AS Prior_Cert_Value
--Certified
, cv.Cert_Land
, cv.Cert_Imp
, cv.Cert_Total_Value
--Calc
, ( cv.Cert_Total_Value -  ap.prior_val) AS Change_Dollar
,   CASE
        WHEN ap.prior_val = 0 THEN 0  -- Handle the divide by zero case
        ELSE (CAST(cv.Cert_Total_Value AS DECIMAL(18, 2)) / CAST(ap.prior_val AS DECIMAL(18, 2))) -- Percent Change
    END AS Change_Percent

FROM APPEALS AS ap

JOIN CTE_ParcelMaster AS pm
  ON ap.lrsn=pm.lrsn

JOIN CTE_DistrictKey AS dk
  ON pm.GEO=dk.GEO

JOIN CTE_AppraiserKey AS ak
  ON ak.AssignedTo = ap.assignedto

LEFT JOIN CTE_CertVal AS cv ON pm.lrsn = cv.lrsn
  AND cv.RowNum = '1'

LEFT JOIN CTE_ResBldgSF AS rsf ON pm.lrsn = rsf.lrsn
LEFT JOIN CTE_ManBldgSF AS msf ON pm.lrsn = msf.lrsn
LEFT JOIN CTE_CommBldgSF AS csf ON pm.lrsn = csf.lrsn
LEFT JOIN CTE_YearBuilt AS yb ON pm.lrsn = yb.lrsn
LEFT JOIN CTE_SalePrice AS sp ON pm.lrsn = sp.lrsn
  AND sp.RowNum = '1'


WHERE ap.status = 'A'
AND ap.year_appealed = 2023
--AND ap.det_type = 2

ORDER BY
GEO, appeal_id;



