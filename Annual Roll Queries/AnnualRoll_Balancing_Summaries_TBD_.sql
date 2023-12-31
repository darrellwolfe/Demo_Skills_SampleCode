/*
AsTxDBProd
GRM_Main

--Summary Balancing Spreadsheet
*/

--TA SUMMARY ANNUAL REAL AND PERSONAL
SELECT TaxAuthorityId, TaxAuthority, IncrCtrlCd, MV_Projected, MV_Actual,
(MV_Projected-MV_Actual) AS MV_Diff, LevyRate, ROUND((((MV_Projected*LevyRate)*100))/100,2) AS TA_Projected,
TA_Actual, (TA_Actual-ROUND((((MV_Projected*LevyRate)*100))/100,2)) AS TA_Diff

FROM
(--ANNUAL REAL AND PERSONAL SUMMARY TAB GATHER 
SELECT TaxAuthority, TaxAuthorityId, IncrCtrlCd,

CASE 
WHEN IncrCtrlCd = 0 THEN ISNULL(Sum(CadDistTaxable), 0) 
WHEN IncrCtrlCd = 1 THEN ISNULL(Sum(CadDistTaxable), 0) + ISNULL(SUM(CadURDIncr),0)
END AS MV_Projected,

Sum(TaxValueDistTaxable) AS MV_Actual,
MAX(LevyRate) AS LevyRate,
Sum(TaxCharge) AS TA_Actual

FROM KC_Balance_TA_Tax_Value_Compare
WHERE year = 2021
AND Roll in ('RPA','PPA')

GROUP BY TaxAuthority, TaxAuthorityId, IncrCtrlCd) a
ORDER BY TaxAuthority 


--URD SUMMARY ANNUAL REAL AND PERSONAL
SELECT TIF, SUM(CadDistTaxable) AS MV_Projected, SUM(TaxValueDistTaxable) AS MV_Actual,
SUM(TaxValueDistTaxable)-SUM(CadDistTaxable) AS MV_Diff, NULL, NULL, SUM(TaxCharge)

FROM KC_Balance_TA_Tax_Value_Compare_URD
WHERE year = 2021
AND Roll in ('RPA','PPA')

GROUP BY TIF

--TA SUMMARY ESTIMATED SUB AND MISSED PROPERTY
SELECT TaxAuthorityId, TaxAuthority, Sum(TaxValueDistTaxable) AS MV_Actual, Sum(TaxCharge) AS TA_Actual

FROM KC_Balance_TA_Tax_Value_Compare

WHERE year = 2021
AND Roll in ('PP2','RPS')

GROUP BY TaxAuthority, TaxAuthorityId
ORDER BY TaxAuthority

--URD SUMMARY ESTIMATED SUB AND MISSED PROPERTY
SELECT TIF, SUM(TaxValueDistTaxable) AS MV_Actual, SUM(TaxCharge)

FROM KC_Balance_TA_Tax_Value_Compare_URD

WHERE year = 2021

AND Roll in ('PP2','RPS')
GROUP BY TIF

--TA SUMMARY TRANSIENT
SELECT TaxAuthorityId, TaxAuthority, Sum(TaxValueDistTaxable) AS MV_Actual, Sum(TaxCharge) AS TA_Actual

FROM KC_Balance_TA_Tax_Value_Compare

WHERE year = 2021
AND Roll in ('TR')

GROUP BY TaxAuthority, TaxAuthorityId
ORDER BY TaxAuthority 

--URD SUMMARY TRANSIENT (SHOULD BE NO VALUE)
SELECT TIF, SUM(TaxValueDistTaxable) AS MV_Actual, SUM(TaxCharge)

FROM KC_Balance_TA_Tax_Value_Compare_URD

WHERE year = 2021
AND Roll in ('TR')

GROUP BY TIF

--TA SUMMARY OPERATING PROPERTY
SELECT TaxAuthorityId, TaxAuthority, IncrCtrlCd, MV_Projected, MV_Actual,
(MV_Projected-MV_Actual) AS MV_Diff, LevyRate, ROUND((((MV_Projected*LevyRate)*100))/100,2) AS TA_Projected,
TA_Actual, (TA_Actual-ROUND((((MV_Projected*LevyRate)*100))/100,2)) AS TA_Diff

FROM
(--ANNUAL REAL AND PERSONAL SUMMARY TAB GATHER 
SELECT TaxAuthority, TaxAuthorityId, IncrCtrlCd,

CASE 
WHEN IncrCtrlCd = 0 THEN ISNULL(Sum(CadDistTaxable), 0) 
WHEN IncrCtrlCd = 1 THEN ISNULL(Sum(CadDistTaxable), 0) + ISNULL(SUM(CadURDIncr),0)
END AS MV_Projected,

Sum(TaxValueDistTaxable) AS MV_Actual,
MAX(LevyRate) AS LevyRate,
Sum(TaxCharge) AS TA_Actual

FROM KC_Balance_TA_Tax_Value_Compare

WHERE year = 2021
AND Roll in ('OP')

GROUP BY TaxAuthority, TaxAuthorityId, IncrCtrlCd) a
ORDER BY TaxAuthority 


--URD SUMMARY OPERATING PROPERTY
SELECT TIF, SUM(CadDistTaxable) AS MV_Projected, SUM(TaxValueDistTaxable) AS MV_Actual,

SUM(TaxValueDistTaxable)-SUM(CadDistTaxable) AS MV_Diff, NULL, NULL, SUM(TaxCharge)

FROM KC_Balance_TA_Tax_Value_Compare_URD

WHERE year = 2021
AND Roll in ('OP')

GROUP BY TIF



--TA SUMMARY OCCUPANCY
SELECT TaxAuthorityId, TaxAuthority, Sum(TaxValueDistTaxable) AS MV_Actual, Sum(TaxCharge) AS TA_Actual

FROM KC_Balance_TA_Tax_Value_Compare

WHERE year = 2021
AND Roll in ('OCC')

GROUP BY TaxAuthority, TaxAuthorityId
ORDER BY TaxAuthority 



--URD SUMMARY OCCUPANCY
SELECT TIF, SUM(TaxValueDistTaxable) AS MV_Actual, SUM(TaxCharge)

FROM KC_Balance_TA_Tax_Value_Compare_URD

WHERE year = 2021
AND Roll in ('OCC')

GROUP BY TIF





