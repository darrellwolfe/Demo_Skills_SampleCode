-- !preview conn=conn

DECLARE @CURRENTYEAR INT = 2024;

SELECT DISTINCT
  p.lrsn AS LRSN,
  TRIM(p.pin) AS PIN,
  TRIM(p.AIN) AS AIN,
  CASE
    WHEN p.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 6003 THEN 'District_6'
    WHEN p.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 6001 THEN 'District_6'
    WHEN p.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 5003 THEN 'District_5'
    WHEN p.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 5001 THEN 'District_5'
    WHEN p.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 4000 THEN 'District_4'
    WHEN p.neighborhood >= 3000 THEN 'District_3'
    WHEN p.neighborhood >= 2000 THEN 'District_2'
    WHEN p.neighborhood >= 1021 THEN 'District_1'
    WHEN p.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 1001 THEN 'District_1'
    WHEN p.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 451 THEN 'Commercial'
    WHEN p.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN p.neighborhood >= 1 THEN 'Commercial'
    WHEN p.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District,
  p.neighborhood AS GEO,
  TRIM(p.DisplayName) AS Owner_Name,
  TRIM(p.SitusAddress) AS Situs_Address,
  TRIM(a.appeal_id) AS Appeal_#,
  a.local_grounds AS Appeal_Presentation,
  TRIM(a.assignedto) AS Appraiser,
  FORMAT(a.hear_date,'d') AS Hearing_Date,
  FORMAT(a.hear_date,'t') AS Hearing_Time,
  CASE
    WHEN a.appeal_status = '5' THEN 'Dismissed'
    WHEN a.app_res_cat = '1' THEN 'In Favor of Assessor'
    WHEN a.app_res_cat = '2' THEN 'In Favor of Taxpayer'
    WHEN a.grounds = 'REC' THEN 'REC'
    WHEN a.grounds = 'CLE' THEN 'Casualty Loss Exemption'
    WHEN a.app_res_cat = '3' THEN 'Resolved in Some Other Manner'
  ELSE 'Pending Outcome'
  END AS [Appeal_Outcome],
  FORMAT(a.prior_val,'c0') AS Certified_Value,
  FORMAT(a.stated_val,'c0') AS Apellant_Stated_Value,
  FORMAT(a.prior_val-a.stated_val,'c0') AS Difference_Opinion_Value,
  CASE 
    WHEN p.CostingMethod = 'C' THEN 'Cost'
    WHEN p.CostingMethod = 'I' THEN 'Income'
    WHEN p.CostingMethod = 'O' THEN 'Override'
    WHEN p.CostingMethod = 'R' THEN 'User Entered'
  ELSE 'Other Pricing Method'
  END AS [Pricing_Method]

FROM TSBv_PARCELMASTER AS p
  JOIN appeals AS a ON p.lrsn=a.lrsn

WHERE p.EffStatus = 'A'
  AND a.year_appealed = @CURRENTYEAR
  AND a.det_type = '1'
  AND a.status = 'A'

ORDER BY
  
  Appeal_#
;