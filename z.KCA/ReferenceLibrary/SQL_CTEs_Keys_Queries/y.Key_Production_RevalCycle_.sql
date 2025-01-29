/*
AsTxDBProd
GRM_Main
*/


WITH 

CTE_RevalCycles AS (
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
        END AS Reval_Cycle_Status
    FROM tblRy_001 ry
    WHERE ry.status = 'A'

),

CTE_ParcelBase AS (
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

),

CTE_ValDetail AS (
-----------------------------------------------
--val_detail hsa the "last updated" key for the State Report
-----------------------------------------------
    SELECT
    lrsn,
    MAX(last_update_long) AS [LastUpdated],
    LEFT(group_code,2) AS [GoupCode],
    inspection_date

    FROM val_detail

    WHERE status='A'

    GROUP BY
    lrsn,
    group_code,
    inspection_date

),


CTE_Ext AS (
-----------------------------------------------
--Extensions has the Inspection Dates and Appraised Dates
-----------------------------------------------
    SELECT
    lrsn,
    MAX(date_priced) AS [MaxDatePriced],
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

),


CTE_Memos AS (
-----------------------------------------------
--Memos --If exists, include, Make sure to LEFT JOIN
-----------------------------------------------
    SELECT
    --Reval 2018 - 2022, Reval 2023 - 2027
    parcel.lrsn,
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

    FROM KCv_PARCELMASTER1 AS parcel
    LEFT JOIN memos AS ry18 ON ry18.lrsn=parcel.lrsn AND ry18.memo_id='RY18'AND ry18.memo_line_number='1'
    LEFT JOIN memos AS ry19 ON ry19.lrsn=parcel.lrsn AND ry19.memo_id='RY19'AND ry19.memo_line_number='1'
    LEFT JOIN memos AS ry20 ON ry20.lrsn=parcel.lrsn AND ry20.memo_id='RY20'AND ry20.memo_line_number='1'
    LEFT JOIN memos AS ry21 ON ry21.lrsn=parcel.lrsn AND ry21.memo_id='RY21'AND ry21.memo_line_number='1'
    LEFT JOIN memos AS ry22 ON ry22.lrsn=parcel.lrsn AND ry22.memo_id='RY22'AND ry22.memo_line_number='1'
    LEFT JOIN memos AS ry23 ON ry23.lrsn=parcel.lrsn AND ry23.memo_id='RY23'AND ry23.memo_line_number='1'
    LEFT JOIN memos AS ry24 ON ry24.lrsn=parcel.lrsn AND ry24.memo_id='RY24'AND ry24.memo_line_number='1'
    LEFT JOIN memos AS ry25 ON ry25.lrsn=parcel.lrsn AND ry25.memo_id='RY25'AND ry25.memo_line_number='1'
    LEFT JOIN memos AS ry26 ON ry26.lrsn=parcel.lrsn AND ry26.memo_id='RY26'AND ry26.memo_line_number='1'
    LEFT JOIN memos AS ry27 ON ry27.lrsn=parcel.lrsn AND ry27.memo_id='RY27'AND ry27.memo_line_number='1'

    WHERE parcel.EffStatus= 'A'

)


-------------------------------------------
--End CTEs, Start Primary Join Query
-------------------------------------------

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
--Adding CTEs
ryc.RVYear,
ryc.Reval_Cycle_Status,
pb.[RevalGeo_SeeKeyInfoInProVal],
vd.[GoupCode],
vd.inspection_date,
vd.[LastUpdated],
ext.[MaxDatePriced],
ext.[InspectedBY],
ext.[InspectedDate],
ext.[AppraisedBy],
ext.[AppraisedDate],
mem.[RY18],
mem.[RY19],
mem.[RY20],
mem.[RY21],
mem.[RY22],
mem.[RY23],
mem.[RY24],
mem.[RY25],
mem.[RY26],
mem.[RY27]

--GRM Main Table
FROM KCv_PARCELMASTER1 AS parcel
--State Table
LEFT JOIN CTE_RevalCycles AS ryc ON parcel.lrsn=ryc.lrsn
--State Table
LEFT JOIN CTE_ParcelBase AS pb ON parcel.lrsn=pb.lrsn
--State Table
LEFT JOIN CTE_ValDetail AS vd ON parcel.lrsn=vd.lrsn
--GRM Main Table
LEFT JOIN CTE_Ext AS ext ON parcel.lrsn=ext.lrsn
--GRM Main Table
LEFT JOIN CTE_Memos AS mem ON parcel.lrsn=mem.lrsn


WHERE parcel.EffStatus= 'A'
AND parcel.lrsn <> '306166'
AND parcel.ClassCD NOT LIKE '010%'
AND parcel.ClassCD NOT LIKE '020%'
AND parcel.ClassCD NOT LIKE '021%'
AND parcel.ClassCD NOT LIKE '022%'
AND parcel.ClassCD NOT LIKE '030%'
AND parcel.ClassCD NOT LIKE '032%'
AND parcel.ClassCD NOT LIKE '070%'
AND parcel.ClassCD NOT LIKE '090%'


ORDER BY [GEO], [PIN], [ClassCD];