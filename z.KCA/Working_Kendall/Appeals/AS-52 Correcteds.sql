-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

CODES TABLE TESTING

*/
SELECT
CASE
  WHEN a.appeal_status = '1' THEN 'Entered'
  WHEN a.appeal_status = '6' THEN 'No Change'
  WHEN a.appeal_status = '7' THEN 'Corrected Notice'
ELSE NULL
END AS [Appeal Outcome],
a.lastupdate,
a.appeal_id AS [Appeal_No],
TRIM(p.AIN) AS [AIN],
p.neighborhood AS [GEO],
FORMAT(a.hear_date, 'MM/dd/yyyy') AS [Hearing_Date],
FORMAT(a.hear_date, 'HH:mm') AS [Hearing_Time],
TRIM(p.DisplayName) AS [Owner],
TRIM(p.SitusAddress) AS [SitusAddress],
CONCAT(TRIM(p.SitusCity), ', ',p.SitusState, ' ', p.SitusZip) AS [Situs_City_St_Zip], 
TRIM(p.pin) AS [PIN],
TRIM(a.assignedto) AS [Appraiser]

FROM TSBv_PARCELMASTER AS p
JOIN appeals AS a ON p.lrsn=a.lrsn

WHERE p.EffStatus = 'A'
AND a.year_appealed = '2024'
AND a.det_type = 4
AND a.status = 'A'
AND a.appeal_status = '7'

ORDER BY
a.lastupdate,
a.appeal_id
;