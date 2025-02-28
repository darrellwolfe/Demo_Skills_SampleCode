WITH CTE_PermitCounter AS (
SELECT DISTINCT
--pm.lrsn,
TRIM(p.permit_ref) AS REFERENCENum,
COUNT(TRIM(p.permit_ref)) AS Count
FROM permits AS p 
GROUP BY TRIM(p.permit_ref)
--HAVING COUNT(TRIM(p.permit_ref)) > 1
),

CTE_PermitQuery AS (
SELECT DISTINCT
--Account Details
pm.lrsn,
pm.neighborhood AS GEO,
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
        WHEN pm.neighborhood = 0 THEN 'PersonalProperty_N/A_or_Error'
        ELSE NULL
    END AS District,
UPPER(TRIM(pm.ain)) AS AIN, 
CONCAT(TRIM(pm.ain),',') AS AIN_LookUp,
UPPER(TRIM(pm.pin)) AS PIN, 
UPPER(TRIM(pm.SitusAddress)) AS SitusAddress,
UPPER(TRIM(pm.SitusCity)) AS SitusCity,
--StatusCheck
p.status AS PermitStatus,
pm.EffStatus AS AccountStatus,
--Permit Data
UPPER(TRIM(p.permit_ref)) AS REFERENCENum,
UPPER(TRIM(p.permit_desc)) AS DESCRIPTION,
p.permit_type,
TRIM(c.tbl_element_desc) AS PERMIT_TYPE_Descr,
p.filing_date AS FILING_DATE,
f.field_out AS WORK_ASSIGNED_DATE,
p.callback AS CALLBACK_DATE,
f.field_in AS WORK_DUE_DATE,
p.cert_for_occ AS DATE_CERT_FOR_OCC,
p.permservice AS PERMANENT_SERVICE_DATE,
f.need_to_visit AS NEED_TO_VISIT, 
UPPER(TRIM(f.field_person)) AS APPRAISER,
f.date_completed AS COMPLETED_DATE,
--Other Dates
UPPER(TRIM(p.permit_source)) AS PERMIT_SOURCE,
--Additional Data
p.cost_estimate AS COST_ESTIMATE,
p.sq_ft AS ESTIMATED_SF,
p.permit_fee,
p.phone_number,
--Demographics
pm.ClassCD, 
UPPER(TRIM(pm.PropClassDescr)) AS Property_Class_Description,
UPPER(TRIM(pm.DisplayName)) AS Owner, 
--Acres
pm.LegalAcres,
--End SELECT
UPPER(TRIM(pm.DisplayDescr)) AS LegalDescription

FROM TSBv_PARCELMASTER AS pm
JOIN permits AS p ON pm.lrsn=p.lrsn
  LEFT JOIN field_visit AS f 
    ON p.field_number=f.field_number
    AND f.status='A'
LEFT JOIN codes_table AS c 
  ON c.tbl_element=p.permit_type 
  AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'
),

CTE_Memos_Imp_Land AS (
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS LandMemos
FROM memos AS m1
WHERE m1.memo_id IN ('LAND') 
  AND (m1.memo_text LIKE CONCAT('%/',RIGHT(YEAR(GETDATE()),2),' %')
  OR m1.memo_text LIKE CONCAT('%/',YEAR(GETDATE()),' %'))
GROUP BY m1.lrsn
)

SELECT DISTINCT
pq.REFERENCENum
,pc.Count
,pq.DESCRIPTION
,pq.permit_type
,pq.PERMIT_TYPE_Descr
,pq.lrsn AS OLD_LRSN
,pq.AIN AS OLD_AIN
,pq.PIN AS OLD_PIN
,pq.GEO
,pq.District
,pq.SitusAddress
,pq.LegalDescription
,pq.PermitStatus
,pq.AccountStatus
,land.LandMemos
,pq.SitusCity
,pq.FILING_DATE
,pq.WORK_ASSIGNED_DATE
,pq.CALLBACK_DATE
,pq.WORK_DUE_DATE
,pq.DATE_CERT_FOR_OCC
,pq.PERMANENT_SERVICE_DATE
,pq.NEED_TO_VISIT
,pq.APPRAISER
,pq.COMPLETED_DATE
,pq.PERMIT_SOURCE
,pq.COST_ESTIMATE
,pq.ESTIMATED_SF
,pq.permit_fee
,pq.phone_number
,pq.ClassCD
,pq.Property_Class_Description
,pq.Owner
,pq.LegalAcres
,pq.AIN_LookUp

FROM CTE_PermitQuery AS pq

LEFT JOIN CTE_PermitCounter AS pc
  ON pc.REFERENCENum = pq.REFERENCENum

LEFT JOIN CTE_Memos_Imp_Land AS land
  ON land.lrsn = pq.lrsn


-- Active Permits, Active Accounts
WHERE pq.PermitStatus IN ('A')
AND pq.AccountStatus IN ('A')

/*

These are various pre-set filters

In this way, I can edit the script once, 
but paste into difference senarios more easily.

,pq.PermitStatus
,pq.AccountStatus

--Only looks for Active Permits on Inactive or Deleted Accounts 
-- where there are no duplicate permits already on another account.
WHERE pq.PermitStatus IN ('A')
AND pc.REFERENCENum IS NULL -- Exclude rows that matched the CTE
AND (pq.LegalDescription LIKE '%DELETE%'
  OR pq.AccountStatus = 'I')

-- ALL Permits, regardless of Permit or Account status
WHERE pq.PermitStatus IN ('A', 'I')
AND pq.AccountStatus IN ('I', 'A')

-- Active Permits, Any Account Status
WHERE pq.PermitStatus IN ('A')
AND pq.AccountStatus IN ('I', 'A')

-- Active Permits, Inactive Accounts
WHERE pq.PermitStatus IN ('A')
AND pq.AccountStatus IN ('I')

-- Active Permits, Active Accounts
WHERE pq.PermitStatus IN ('A')
AND pq.AccountStatus IN ('A')

-- Inactive Permits, Any Account Status
WHERE pq.PermitStatus IN ('I')
AND pq.AccountStatus IN ('I', 'A')

-- Inactive permits, Active Accounts
WHERE pq.PermitStatus IN ('I')
AND pq.AccountStatus IN ('A')

-- Inactive permits, Inactive Accounts
WHERE pq.PermitStatus IN ('I')
AND pq.AccountStatus IN ('I')

*/


ORDER BY pq.GEO, pq.PIN, pq.REFERENCENum;
