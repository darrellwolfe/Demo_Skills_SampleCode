/*
AsTxDBProd
GRM_Main

        WHEN RVYear >= 2013 AND RVYear <= 2017 THEN 'Previous Cycle'      
        WHEN RVYear >= 2018 AND RVYear <= 2022 THEN 'Current Cycle'
        WHEN RVYear >= 2023 AND RVYear <= 2027 THEN 'Next Cycle'

Count and concat Group codes in CTE 

*/


-----------------------------------------------
--val_detail hsa the "last updated" key for the State Report
-----------------------------------------------

SELECT
lrsn,
MAX(last_update_long) AS [Last],
LEFT(group_code,2) AS [GoupCode],
inspection_date

FROM val_detail

WHERE status='A'

GROUP BY
lrsn,
group_code,
inspection_date


-----------------------------------------------
--Extensions has the Inspection Dates and Appraised Dates
-----------------------------------------------
SELECT
lrsn,
MAX(date_priced),
data_collector AS [InspectedBY],
collection_date AS [InspectedDate],
appraiser AS [AppraisedBy],
appraisal_date AS [AppraisedDate]

FROM extensions --AS ex
WHERE status='A'
AND extension='L00'
GROUP BY
lrsn,
data_collector,
collection_date,
appraiser,
appraisal_date

ORDER BY lrsn;


-----------------------------------------------
--Memos --If exists, include
-----------------------------------------------


SELECT
--Reval 2018 - 2022, Reval 2023 - 2027
ry18.memo_text AS [RY18],
ry19.memo_text AS [RY19],
ry20.memo_text AS [RY20],
ry21.memo_text AS [RY21],
ry22.memo_text AS [RY22],
ry23.memo_text AS [RY23],
ry24.memo_text AS [RY24],
ry25.memo_text AS [RY25],
ry26.memo_text AS [RY26],
ry27.memo_text AS [RY27]

FROM memos AS ry18 
--ON ry18.lrsn=parcel.lrsn AND ry18.memo_id='RY18'AND ry18.memo_line_number='1'
LEFT JOIN memos AS ry19 ON ry19.lrsn=parcel.lrsn AND ry19.memo_id='RY19'AND ry19.memo_line_number='1'
LEFT JOIN memos AS ry20 ON ry20.lrsn=parcel.lrsn AND ry20.memo_id='RY20'AND ry20.memo_line_number='1'
LEFT JOIN memos AS ry21 ON ry21.lrsn=parcel.lrsn AND ry21.memo_id='RY21'AND ry21.memo_line_number='1'
LEFT JOIN memos AS ry22 ON ry22.lrsn=parcel.lrsn AND ry22.memo_id='RY22'AND ry22.memo_line_number='1'
LEFT JOIN memos AS ry23 ON ry23.lrsn=parcel.lrsn AND ry23.memo_id='RY23'AND ry23.memo_line_number='1'
LEFT JOIN memos AS ry24 ON ry24.lrsn=parcel.lrsn AND ry24.memo_id='RY24'AND ry24.memo_line_number='1'
LEFT JOIN memos AS ry25 ON ry25.lrsn=parcel.lrsn AND ry25.memo_id='RY25'AND ry25.memo_line_number='1'
LEFT JOIN memos AS ry26 ON ry26.lrsn=parcel.lrsn AND ry26.memo_id='RY26'AND ry26.memo_line_number='1'
LEFT JOIN memos AS ry27 ON ry27.lrsn=parcel.lrsn AND ry27.memo_id='RY27'AND ry27.memo_line_number='1'

WHERE ry18.memo_id='RY18'AND ry18.memo_line_number='1'



-----------------------------------------------
--ParcelMaster
-----------------------------------------------

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.TAG)) AS [TAG],
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],


FROM KCv_PARCELMASTER1 AS parcel
--JOINS



-----------------------------------------------
--parcel_base
-----------------------------------------------

SELECT
lrsn,
parcel_id AS [PIN],
tax_bill_id AS [AIN],
neighborhood AS [GEO],
reval_neigh AS [RevalGeo_SeeKeyInfoInProVal],
parcel_flags AS [ParcelFlags_WhatIsThis?],
legal_acreage AS [LegalAcres]

FROM parcel_base

WHERE status='A'
AND lrsn<>'528284'

ORDER BY GEO, PIN;



/*------------------------------------
This is from the 5-Year State Tax Commission (STC) Report Review from Crystal

2023-2027_PM069A-5YRProgressReport.rpt
------------------------------------*/

FROM parcel_base AS pb
JOIN tblRy_001 AS ry ON pb.lrsn=ry.lrsn
JOIN val_detail AS vd ON ry.lrsn=vd.lrsn AND ry.status=vd.status


--Three Seperate queries for now:

-----------------------------------------------
--Count PINs in Reval Cycles
-----------------------------------------------

WITH RevalCycles AS (
    SELECT 
        ry.parcel_id,
        CASE
            WHEN ry.RVYear >= 2023 AND ry.RVYear <= 2027 THEN 'Current Cycle'
            WHEN ry.RVYear >= 2018 AND ry.RVYear <= 2022 THEN 'Previous Cycle'
            ELSE 'Archive Cycle'
        END AS Reval_Cycle
    FROM tblRy_001 ry
    WHERE ry.status = 'A'
)
    SELECT 
        Reval_Cycle,
                COUNT(parcel_id) AS PIN_Count
    FROM RevalCycles
    GROUP BY Reval_Cycle

-----------------------------------------------
--Reval Cycles by PIN
-----------------------------------------------
    SELECT 
        ry.lrsn,
        ry.parcel_id,
        ry.RVYear,
        CASE
            WHEN ry.RVYear >= 2023 AND ry.RVYear <= 2027 THEN 'Current Cycle'
            WHEN ry.RVYear >= 2018 AND ry.RVYear <= 2022 THEN 'Previous Cycle'
            ELSE 'Archive Cycle'
        END AS Reval_Cycle
    FROM tblRy_001 ry
    WHERE ry.status = 'A'

-----------------------------------------------
--Main 5-Year State Tax Commission (STC) Report
-----------------------------------------------


SELECT DISTINCT
    vd.lrsn,
    ry.parcel_id AS [PIN],
    ry.neighborhood AS [GEO],
    ry.RVYear,
    ry.parcel_flags,
    pb.county_number,
    pb.property_class,
    pb.tax_bill_id,
    vd.group_code,
    LEFT(vd.group_code,2) AS [StateCode],
    vd.last_update_long,
    vd.val_seq_no,
    vd.eff_year,
    vd.inspection_date
FROM parcel_base AS pb
JOIN tblRy_001 AS ry ON pb.lrsn=ry.lrsn
JOIN val_detail AS vd ON ry.lrsn=vd.lrsn AND ry.status=vd.status
WHERE ry.RVYear BETWEEN 2023 AND 2027
AND pb.status='A'
AND ry.status='A'
AND vd.status='A'
AND vd.eff_year='20230101'

GROUP BY
    vd.lrsn,
    ry.parcel_id,
    ry.neighborhood,
    ry.RVYear,
    ry.parcel_flags,
    pb.county_number,
    pb.property_class,
    pb.tax_bill_id,
    vd.group_code,
    vd.last_update_long,
    vd.val_seq_no,
    vd.eff_year,
    vd.inspection_date


ORDER BY [GEO], [PIN];

