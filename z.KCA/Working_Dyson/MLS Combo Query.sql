SELECT DISTINCT
  '-' AS "Sales_Number"
, kp.lrsn AS "LRSN"
, kp.pin AS "PIN"
, kp.ain AS "AIN"
, ktb.pxfer_date AS "Sales_Date"
, ktb.adjustedsaleprice AS "Sales_Price"
, '-' AS "DAYS_UNTIL_Jan_01"
, '-' AS "TIME_ADJUST_TO_Jan_01"
, CASE
WHEN SUBSTRING(kp.ClassCD, 0, 4) != 'Una' THEN SUBSTRING(kp.ClassCD, 0, 4)
ELSE 'Unknown'
END AS "PC"
, kp.neighborhood AS "NBHD"
, i.year_built AS "Yr_Built"
, i.eff_year_built AS "Eff_Yr"
, CASE 
WHEN SUBSTRING(i.grade, 1, 2) = '12' THEN 'VLow-'
WHEN SUBSTRING(i.grade, 1, 2) = '15' THEN 'VLow'
WHEN SUBSTRING(i.grade, 1, 2) = '18' THEN 'VLow+'
WHEN SUBSTRING(i.grade, 1, 2) = '22' THEN 'Low-'
WHEN SUBSTRING(i.grade, 1, 2) = '25' THEN 'Low'
WHEN SUBSTRING(i.grade, 1, 2) = '28' THEN 'Low+'
WHEN SUBSTRING(i.grade, 1, 2) = '32' THEN 'Fair-'
WHEN SUBSTRING(i.grade, 1, 2) = '35' THEN 'Fair'
WHEN SUBSTRING(i.grade, 1, 2) = '38' THEN 'Fair+'
WHEN SUBSTRING(i.grade, 1, 2) = '42' THEN 'Avg-'
WHEN SUBSTRING(i.grade, 1, 2) = '45' THEN 'Avg'
WHEN SUBSTRING(i.grade, 1, 2) = '48' THEN 'Avg+'
WHEN SUBSTRING(i.grade, 1, 2) = '52' THEN 'Good-'
WHEN SUBSTRING(i.grade, 1, 2) = '55' THEN 'Good'
WHEN SUBSTRING(i.grade, 1, 2) = '58' THEN 'Good+'
WHEN SUBSTRING(i.grade, 1, 2) = '62' THEN 'VGood-'
WHEN SUBSTRING(i.grade, 1, 2) = '65' THEN 'VGood'
WHEN SUBSTRING(i.grade, 1, 2) = '68' THEN 'VGood+'
WHEN SUBSTRING(i.grade, 1, 2) = '72' THEN 'Exc-'
WHEN SUBSTRING(i.grade, 1, 2) = '75' THEN 'Exc'
WHEN SUBSTRING(i.grade, 1, 2) = '78' THEN 'Exc+'
WHEN SUBSTRING(i.grade, 1, 2) = '82' THEN 'HV1'
WHEN SUBSTRING(i.grade, 1, 2) = '85' THEN 'HV2'
WHEN SUBSTRING(i.grade, 1, 2) = '88' THEN 'HV3'
WHEN SUBSTRING(i.grade, 1, 2) = '92' THEN 'HV4'
WHEN SUBSTRING(i.grade, 1, 2) = '95' THEN 'HV5'
WHEN SUBSTRING(i.grade, 1, 2) = '98' THEN 'HV6' 
ELSE 'Other'
END AS "GRD"
, CASE 
WHEN i.condition = 'VP' then 'VPoor'
WHEN i.condition = 'P' then 'Poor'
WHEN i.condition = 'F' then 'Fair'
WHEN i.condition = 'AV' then 'Avg'
WHEN i.condition = 'G' then 'Good'
WHEN i.condition = 'VG' then 'VGood' 
WHEN i.condition = 'EX' then 'Exc' 
ELSE 'Other'
END AS "COND"
, d.mkt_house_type AS "HSE_TYPE"
, d.mkt_rdf AS "RDP"
, kp.Acres AS "LEGAL_ACRES"
, '1' AS "SITE"
, cat19waste.LDAcres AS "CAT_19_WASTE"
, '-' AS "REMAIN AC"
, r1.land_mkt_val_cost  AS "CERTIFIED_LAND_VALUE"
, r1.cost_value AS "CERTIFIED_IMP_VALUE"
, '-' AS "TOTAL_CERTIFIED_VALUE"
, '-' AS "2021_RATIO"
, '-' AS "A.B.S_DIFF"
, '-' AS "DAYS"
, '-' AS "TASP"
, '-' AS "LEGEND"
, '-' AS "BASE_SITE_VALUE"
, '-' AS "LAND_INF"
, '-' AS "LAND_INFL"
, '-' AS "|"
, '-' AS "ADJ_20XX_SITE_VALUE"
, land.BaseRate AS "BASE_REMAIN_AC_RATE"
, '-' AS "UNK"
, '-' AS "ADJUSTED_REM_ACRE_VALUE"
, '-' AS "BASE_TOTAL_LAND_VALUE"
, r2.cost_Value AS "TIME_OF_SALE_IMP_VALUE"
, '-' AS "ADJ_TIME_OF_SALE_IMP_VALUE"
, '-' AS "TOTAL_VALUE"
, '-' AS "RATIO"
, '-' AS "ABS_DIFF"
, ktb.tfrtype AS "TRF_TYPE"
, ktb.saledesc AS "SALES_INFO"
, '-' AS "OK_IF_ARMS_LGTH"
, '-' AS "RATIO_OF_ARMS_LENGTHS"
, '-' AS "ABS_DIFF_OF_ARMS_LENGTH"
, '-' AS "TOTAL_VALUE_OF_ARMS_LENGTH"
, '-' AS "TASP_OF_NOT_DISTRESS"
, '-' AS "COMMENTS"
, kp.situsaddress AS "ADDRESS"
FROM KCv_PARCELMASTER1 kp 
INNER JOIN (select distinct t.lrsn, t.TfrType, Status, pxfer_date, adjustedsaleprice, propclass, saledesc from transfer t
       where t.status='A' 
       and t.last_update=(select max(t_sub.last_update) from transfer t_sub where t.lrsn=t_sub.lrsn and t.pxfer_date=t_sub.pxfer_date)) ktb ON ktb.lrsn = kp.lrsn 
LEFT OUTER JOIN dwellings d ON d.lrsn = kp.lrsn AND d.status = 'A'
LEFT OUTER JOIN improvements i ON i.lrsn = kp.lrsn AND i.extension=d.extension AND i.dwelling_number=d.dwelling_number AND i.status = 'A'
LEFT OUTER JOIN reconciliation r1 ON r1.lrsn = kp.lrsn AND r1.status = (CASE WHEN @reconciliation = 'Worksheets' THEN '' WHEN @reconciliation = 'Certified' THEN 'C' ELSE 'C' END)  AND r1.land_model>=702021 AND r1.last_update = (SELECT MAX(r1_sub.last_update) FROM reconciliation r1_sub WHERE r1_sub.lrsn = r1.lrsn AND r1_sub.status = 'C' AND r1_sub.land_model>=702021)
LEFT OUTER JOIN reconciliation r2 ON r2.lrsn = kp.lrsn AND r2.status = (CASE WHEN @reconciliation = 'Worksheets' THEN 'W' WHEN @reconciliation = 'Certified' THEN '' ELSE 'W' END) AND r2.land_model>=702021
LEFT OUTER JOIN (SELECT lh.RevObjId, ld.BaseRate FROM LandHeader lh INNER JOIN LandDetail ld ON ld.LandHeaderId = lh.id AND ld.LandType = '91' AND ld.EffStatus = 'A' AND ld.BegEffDate = (select max(ld_sub.begeffdate) from LandDetail ld_sub where ld.id=ld_sub.id)) land ON land.RevObjId=kp.lrsn 
LEFT OUTER JOIN (SELECT lh.RevObjId, ld.LDAcres FROM LandHeader lh INNER JOIN LandDetail ld ON ld.LandHeaderId = lh.id AND ld.LandType = '82' AND ld.EffStatus = 'A' AND ld.BegEffDate = (select max(ld_sub.begeffdate) from LandDetail ld_sub where ld.id=ld_sub.id)) cat19waste ON cat19waste.RevObjId=kp.lrsn 
WHERE kp.EffStatus = 'A'
AND ktb.Status = 'A'
AND ktb.adjustedsaleprice>0 
AND ((r1.cost_value != 0) OR (CAST(SUBSTRING(kp.ClassCD, 0, 4) AS INT) IN (314,317,322,411,413,416,421,512,515,520,525,526,527)))
AND kp.neighborhood >= @start_neighborhood
AND kp.neighborhood <= @end_neighborhood
AND ktb.pxfer_date >= @start_date
AND ktb.pxfer_date <= @end_date
ORDER BY kp.lrsn, kp.pin
