/*
AsTxDBProd
GRM_Main

        WHEN RVYear >= 2013 AND RVYear <= 2017 THEN 'Previous Cycle'      
        WHEN RVYear >= 2018 AND RVYear <= 2022 THEN 'Current Cycle'
        WHEN RVYear >= 2023 AND RVYear <= 2027 THEN 'Next Cycle'

Count and concat Group codes in CTE 

*/




--Three Seperate queries for now:


--Count PINs in Reval Cycles
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


--Reval Cycles by PIN
    SELECT 
        ry.parcel_id,
        ry.RVYear,
        CASE
            WHEN ry.RVYear >= 2023 AND ry.RVYear <= 2027 THEN 'Current Cycle'
            WHEN ry.RVYear >= 2018 AND ry.RVYear <= 2022 THEN 'Previous Cycle'
            ELSE 'Archive Cycle'
        END AS Reval_Cycle
    FROM tblRy_001 ry
    WHERE ry.status = 'A'


--Main
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



-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------




------Fail


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
),
RevalCounts AS (
    SELECT 
        Reval_Cycle,
        COUNT(parcel_id) AS PIN_Count
    FROM RevalCycles
    GROUP BY Reval_Cycle
)

SELECT
    vd.lrsn,
    ry.parcel_id AS [PIN],
    ry.neighborhood AS [GEO],
    ry.RVYear,
    ry.parcel_flags,
    pb.county_number,
    pb.property_class,
    pb.tax_bill_id,
    vd.group_code,
    vd.last_update_long,
    vd.val_seq_no,
    vd.eff_year,
    vd.inspection_date,
    rc.PIN_Count
FROM parcel_base AS pb
JOIN tblRy_001 AS ry ON pb.lrsn=ry.lrsn
JOIN val_detail AS vd ON ry.lrsn=vd.lrsn AND ry.status=vd.status
JOIN RevalCycles AS rvc ON ry.parcel_id=rvc.parcel_id
JOIN RevalCounts AS rc ON rvc.Reval_Cycle=rc.Reval_Cycle
WHERE ry.RVYear BETWEEN 2023 AND 2027
AND pb.status='A'
AND ry.status='A'
AND vd.status='A'
ORDER BY [GEO], [PIN];






---Full list of columns from tables
Select
--pb tables
pb.status,
pb.parcel_id,
pb.county_number,
pb.property_class,
pb.tax_bill_id,
--ry tables
ry.status,
ry.RVYear,
ry.parcel_id,
ry.neighborhood,
ry.parcel_flags,
--vd tables
vd.lrsn,
vd.status,
vd.last_update_long,
vd.val_seq_no,
vd.eff_year,
vd.group_code,
vd.inspection_date

From parcel_base AS pb
Join tblRy_001 AS ry ON pb.lrsn=ry.lrsn
Join val_detail AS vd ON ry.lrsn=vd.lrsn AND ry.status=vd.status

WHEN RVYear >= 2023 AND RVYear <= 2027 

Order By 


--Reval Report, Table 1, parcel_base
Select
status,
parcel_id,
county_number,
property_class,
tax_bill_id
From parcel_base


--Reval Report, Table 2, tblRy_001
Select
status,
RVYear,
parcel_id,
neighborhood,
parcel_flags
From tblRy_001


--Reval Report, Table 3, val_detail
Select
lrsn,
status,
last_update_long,
val_seq_no,
eff_year,
group_code,
inspection_date
From val_detail

-- Crystalk Group Code Query, Reformatted for SQL
SELECT 
    val_detail.lrsn,
    parcel_base.property_class,
    val_detail.group_code,
    CASE 
        WHEN val_detail.lrsn IS NULL 
            THEN CAST(parcel_base.property_class AS VARCHAR(20)) 
        ELSE 
            LEFT(val_detail.group_code, 2) 
    END AS result 

FROM 
    val_detail
    INNER JOIN parcel_base ON val_detail.lrsn = parcel_base.lrsn

ORDER BY 
    result DESC;

--Count of PINs/LRSNs by Cycle
SELECT
    CASE
        WHEN RVYear >= 2019 AND RVYear <= 2023 THEN 'Current Cycle'
        WHEN RVYear >= 2014 AND RVYear <= 2018 THEN 'Previous Cycle'
        WHEN RVYear >= 2024 AND RVYear <= 2028 THEN 'Next Cycle'
        ELSE 'Unknown'
    END AS Reval_Cycle,
    COUNT(lrsn) AS Parcel_Count
FROM tblRy_001
WHERE status = 'A'
GROUP BY RVYear;

--List of LRSNs in each Cycle
SELECT 
    CASE
        WHEN RVYear >= 2013 AND RVYear <= 2017 THEN 'Previous Cycle'      
        WHEN RVYear >= 2018 AND RVYear <= 2022 THEN 'Current Cycle'
        WHEN RVYear >= 2023 AND RVYear <= 2027 THEN 'Next Cycle'
        ELSE 'Unknown'
    END AS Reval_Cycle,
    COUNT(lrsn) AS Parcel_Count,
    STUFF((SELECT ', ' + CAST(lrsn AS VARCHAR(max))
           FROM tblRy_001
           WHERE status = 'A' AND RVYear = t.RVYear
           ORDER BY lrsn
           FOR XML PATH ('')), 1, 2, '') AS LRSN_List
FROM tblRy_001 t
WHERE status = 'A'
GROUP BY RVYear, 
    CASE
        WHEN RVYear >= 2013 AND RVYear <= 2017 THEN 'Previous Cycle'      
        WHEN RVYear >= 2018 AND RVYear <= 2022 THEN 'Current Cycle'
        WHEN RVYear >= 2023 AND RVYear <= 2027 THEN 'Next Cycle'
        ELSE 'Unknown'
    END;

--List of PINs in each Cycle
SELECT 
    CASE
        WHEN RVYear >= 2013 AND RVYear <= 2017 THEN 'Previous Cycle'      
        WHEN RVYear >= 2018 AND RVYear <= 2022 THEN 'Current Cycle'
        WHEN RVYear >= 2023 AND RVYear <= 2027 THEN 'Next Cycle'
        ELSE 'Unknown'
    END AS Reval_Cycle,
    COUNT(parcel_id) AS Parcel_Count,
    STUFF((SELECT ', ' + CAST(parcel_id AS VARCHAR(max))
           FROM tblRy_001
           WHERE status = 'A' AND RVYear = t.RVYear
           ORDER BY parcel_id
           FOR XML PATH ('')), 1, 2, '') AS Parcel_ID_List
FROM tblRy_001 t
WHERE status = 'A'
GROUP BY RVYear, 
    CASE
        WHEN RVYear >= 2013 AND RVYear <= 2017 THEN 'Previous Cycle'      
        WHEN RVYear >= 2018 AND RVYear <= 2022 THEN 'Current Cycle'
        WHEN RVYear >= 2023 AND RVYear <= 2027 THEN 'Next Cycle'
        ELSE 'Unknown'
    END;














/*

-----------------------------------------------------------------------------------
Key Info
-----------------------------------------------------------------------------------


Filters:
        If {?Parcel Types To Include} = "ALL"
            then
                not ({parcel_base.status} in ["E", "I", "M", "T", "V"])
            else
                (
                    not ({parcel_base.status} in ["E", "I", "M", "T", "V"]) and
                    {@Parcel ID} startswith {?Parcel Types To Include}
                )
        and {tblRy_001.status} = "A"


Group Code is 
    if isnull({val_detail.lrsn}) 
    then 
        totext({parcel_base.property_class},0,'')
    else
        left({val_detail.group_code},2)
--If val_detail.lrsn is null, this means the property is "inactive" in ProVal. 


-----------------------------------------------------------------------------------
Allocation Key
-----------------------------------------------------------------------------------
Notes from five year report code, their "allocation key"

EvaluateAfter ({@GPID});
shared stringvar array gpid;
shared stringvar land_1;
shared stringvar land_2;
shared stringvar land_3;
shared numbervar pcc_land;
shared stringvar imp_1;
shared stringvar imp_2;
shared stringvar imp_3;
shared numbervar pcc_imp;
shared numbervar grm_1;
shared numbervar pcc_grm;
shared numbervar pcc_std;



// LAND START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
    then land_3 := 'L'
    else

// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD
(
// 2.A PASS 1
(
// 2.A.1 PASS 1 LAND - PRIMARY
    If '12' in gpid then land_1 := '12' else
    If '13' in gpid then land_1 := '13' else
    If '14' in gpid then land_1 := '14' else
    If '15' in gpid then land_1 := '15' else
    If '16' in gpid then land_1 := '16' else
    If '17' in gpid then land_1 := '17' else
    If '20' in gpid then land_1 := '20' else
    If '21' in gpid then land_1 := '21' else
    If '22' in gpid then land_1 := '22' else
    If '25' in gpid then land_1 := '25' else
    If '26' in gpid then land_1 := '26' else
    If '27' in gpid then land_1 := '27' else
    If '10' in gpid then land_1 := '10' else
    If '11' in gpid then land_1 := '11' else
    If '18' in gpid then land_1 := '18' else
    If '45' in gpid then land_1 := '45' else
    If '57' in gpid then land_1 := '57' else
    If '67' in gpid then land_1 := '67' else
    If '81' in gpid then land_1 := '81' else
    If '82' in gpid then land_1 := '82' else

// 2.A.2 PASS 1 LAND - SECONDARY
    If '01' in gpid then land_1 := '01' else
    If '02' in gpid then land_1 := '02' else
    If '03' in gpid then land_1 := '03' else
    If '04' in gpid then land_1 := '04' else
    If '05' in gpid then land_1 := '05' else
    If '06' in gpid then land_1 := '06' else
    If '07' in gpid then land_1 := '07' else
    If '09' in gpid then land_1 := '09' else
    If '66' in gpid then land_1 := '66' else
    If '70' in gpid then land_1 := '70' else
    If '19' in gpid then land_1 := '19' else

// 2.A.3 PASS 1 DEFAULT
    land_1 := '00';
);

// 2.B PASS 2
(
// 2.B.1 PASS 2 LAND - PRIMARY
    If '12' in gpid and land_1 <> '12' then land_2 := '12' else
    If '13' in gpid and land_1 <> '13' then land_2 := '13' else
    If '14' in gpid and land_1 <> '14' then land_2 := '14' else
    If '15' in gpid and land_1 <> '15' then land_2 := '15' else
    If '16' in gpid and land_1 <> '16' then land_2 := '16' else
    If '17' in gpid and land_1 <> '17' then land_2 := '17' else
    If '20' in gpid and land_1 <> '20' then land_2 := '20' else
    If '21' in gpid and land_1 <> '21' then land_2 := '21' else
    If '22' in gpid and land_1 <> '22' then land_2 := '22' else
    If '25' in gpid and land_1 <> '25' then land_2 := '25' else
    If '26' in gpid and land_1 <> '26' then land_2 := '26' else
    If '27' in gpid and land_1 <> '27' then land_2 := '27' else
    If '10' in gpid and land_1 <> '10' then land_2 := '10' else
    If '11' in gpid and land_1 <> '11' then land_2 := '11' else
    If '18' in gpid and land_1 <> '18' then land_2 := '18' else
    If '45' in gpid and land_1 <> '45' then land_2 := '45' else
    If '57' in gpid and land_1 <> '57' then land_2 := '57' else
    If '67' in gpid and land_1 <> '67' then land_2 := '67' else
    If '81' in gpid and land_1 <> '81' then land_2 := '81' else
    If '82' in gpid and land_1 <> '82' then land_2 := '82' else

// 2.B.2 PASS 2 LAND - SECONDARY
    If '01' in gpid and land_1 <> '01' then land_2 := '01' else
    If '02' in gpid and land_1 <> '02' then land_2 := '02' else
    If '03' in gpid and land_1 <> '03' then land_2 := '03' else
    If '04' in gpid and land_1 <> '04' then land_2 := '04' else
    If '05' in gpid and land_1 <> '05' then land_2 := '05' else
    If '06' in gpid and land_1 <> '06' then land_2 := '06' else
    If '07' in gpid and land_1 <> '07' then land_2 := '07' else
    If '09' in gpid and land_1 <> '09' then land_2 := '09' else
    If '70' in gpid and land_1 <> '70' then land_2 := '70' else
    If '19' in gpid and land_1 <> '19' then land_2 := '19' else

// 2.B.3 PASS 2 DEFAULT
    land_2 := '00';
);

// 2.B.4 PASS 2 FINAL
    land_3 := land_1 & land_2;
);
// 3.A.1 FINAL - PRIMARY
    If land_3 in ['0100','0102','0103','0104','0105','0106','0107','0109','0119'] then pcc_land := 101 else
    If land_3 in ['0200','0203','0204','0205','0206','0207','0209','0219'] then pcc_land := 102 else
    If land_3 in ['0300','0304','0305','0306','0307','0309','0319'] then pcc_land := 103 else
    If land_3 in ['0400','0405','0406','0407','0409','0419'] then pcc_land := 104 else
    If land_3 in ['0500','0506','0507','0509','0519'] then pcc_land := 105 else
    If land_3 in ['0600','0607','0609','0619'] then pcc_land := 106 else
    If land_3 in ['0700','0709','0719'] then pcc_land := 107 else
    If land_3 in ['1001','1002','1003','1004','1005','1006','1007','1009','1000','1018','1019'] then pcc_land := 110 else
    If land_3 in ['0900','0919'] then pcc_land := 209 else
    If land_3 in ['6600'] then pcc_land := 266 else
    If land_3 in ['7000'] then pcc_land := 270 else
    If land_3 in ['1400','1419'] then pcc_land := 314 else
    If land_3 in ['1700','1719'] then pcc_land := 317 else
    If land_3 in ['2219','2200'] then pcc_land := 322 else
    If land_3 in ['1100','1119'] then pcc_land := 411 else
    If land_3 in ['1300','1319'] then pcc_land := 413 else
    If land_3 in ['1600','1619'] then pcc_land := 416 else
    If land_3 in ['2119','2100'] then pcc_land := 421 else
    If land_3 in ['2719','2700'] then pcc_land := 427 else
    If land_3 in ['1200','1218'] then pcc_land := 512 else
    If land_3 in ['1500','1518'] then pcc_land := 515 else
    If land_3 in ['1820','2018','2000','2019'] then pcc_land := 520 else
    If land_3 in ['2619','2600'] then pcc_land := 526 else
    If land_3 in ['8100'] then pcc_land := 681 else
    If land_3 in ['8200'] then pcc_land := 682 else
    If land_3 in ['1800','1819'] then pcc_land := 718 else
    If land_3 in ['1900'] then pcc_land := 719 else
    If land_3 in ['5719','5700'] then pcc_land := 757 else
    If land_3 in ['4519','4500'] then pcc_land := 845 else
    If land_3 in ['6719','6700'] then pcc_land := 867 else
    If land_3 in ['2519','2500'] then pcc_land := 925 else
    If land_3 = 'L' then pcc_land := 999 else

// 3.A.2 FINAL - MIXED USE
    If land_3 in ['1101','1102','1103','1104','1105','1106','1107','1109','1110'] then pcc_land := 111 else
    If land_3 in ['1201','1202','1203','1204','1205','1206','1207','1209','1210'] then pcc_land := 112 else
    If land_3 in ['1301','1302','1303','1304','1305','1306','1307','1309','1310'] then pcc_land := 113 else
    If land_3 in ['1401','1402','1403','1404','1405','1406','1407','1409','1410'] then pcc_land := 114 else
    If land_3 in ['1501','1502','1503','1504','1505','1506','1507','1509','1510'] then pcc_land := 115 else
    If land_3 in ['1601','1602','1603','1604','1605','1606','1607','1609','1610'] then pcc_land := 116 else
    If land_3 in ['1701','1702','1703','1704','1705','1706','1707','1709','1710'] then pcc_land := 117 else
    If land_3 in ['1801','1802','1803','1804','1805','1806','1807','1809','1810'] then pcc_land := 118 else
    If land_3 in ['2001','2002','2003','2004','2005','2006','2007','2009','2010'] then pcc_land := 120 else
    If land_3 in ['2101','2102','2103','2104','2105','2106','2107','2109','2110'] then pcc_land := 121 else
    If land_3 in ['2201','2202','2203','2204','2205','2206','2207','2209','2210'] then pcc_land := 122 else
    If land_3 in ['1211','1213'] then pcc_land := 412 else
    If land_3 in ['1214'] then pcc_land := 312 else
    If land_3 in ['1516'] then pcc_land := 415 else
    If land_3 in ['1517'] then pcc_land := 315 else
    If land_3 in ['2021'] then pcc_land := 420 else
    If land_3 in ['2022'] then pcc_land := 320 else
    If land_3 in ['1118'] then pcc_land := 711 else
    If land_3 in ['1318'] then pcc_land := 713 else
    If land_3 in ['1618'] then pcc_land := 716 else
    If land_3 in ['2118'] then pcc_land := 721 else

// 4 FINAL
    pcc_land := 0;
    pcc_land;
);
// LAND END


// IMP START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
    then imp_3 := 'I'
    else

// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD
(
// 2.A. PASS 1
(
// 2.A.1 PASS 1 IMPROVEMENT - PRIMARY
    If '31' in gpid then imp_1 := '31' else
    If '33' in gpid then imp_1 := '33' else
    If '34' in gpid then imp_1 := '34' else
    If '35' in gpid then imp_1 := '35' else
    If '36' in gpid then imp_1 := '36' else
    If '37' in gpid then imp_1 := '37' else
    If '38' in gpid then imp_1 := '38' else
    If '39' in gpid then imp_1 := '39' else
    If '41' in gpid then imp_1 := '41' else
    If '42' in gpid then imp_1 := '42' else
    If '43' in gpid then imp_1 := '43' else
    If '46' in gpid then imp_1 := '46' else
    If '48' in gpid then imp_1 := '48' else
    If '49' in gpid then imp_1 := '49' else
    If '65' in gpid then imp_1 := '65' else
    If '25' in gpid then imp_1 := '25' else
    If '26' in gpid then imp_1 := '26' else
    If '27' in gpid then imp_1 := '27' else
    If '45' in gpid then imp_1 := '45' else
    If '50' in gpid then imp_1 := '50' else
    If '51' in gpid then imp_1 := '51' else
    If '57' in gpid then imp_1 := '57' else
    If '66' in gpid then imp_1 := '66' else
    If '69' in gpid then imp_1 := '69' else
    If '81' in gpid then imp_1 := '81' else
    If '82' in gpid then imp_1 := '82' else

// 2.A.2 PASS 1 IMPROVEMENT - SECONDARY
    If '30' in gpid then imp_1 := '30' else
    If '32' in gpid then imp_1 := '32' else
    If '40' in gpid then imp_1 := '40' else
    If '47' in gpid then imp_1 := '47' else

// 2.A.3 PASS 1 IMPROVEMENT - DELETE AFTER 2007
//    If '60' in gpid then imp_1 := '60' else
//    If '61' in gpid then imp_1 := '61' else
   If '62' in gpid then imp_1 := '62' else

// 2.A.4 PASS 1 DEFAULT
    imp_1 := '00';
);
// 2.B PASS 2
(
// 2.B.1 PASS 2 IMPROVEMENT - PRIMARY
    If '31' in gpid and imp_1 <> '31' then imp_2 := '31' else
    If '33' in gpid and imp_1 <> '33' then imp_2 := '33' else
    If '34' in gpid and imp_1 <> '34' then imp_2 := '34' else
    If '35' in gpid and imp_1 <> '35' then imp_2 := '35' else
    If '36' in gpid and imp_1 <> '36' then imp_2 := '36' else
    If '37' in gpid and imp_1 <> '37' then imp_2 := '37' else
    If '38' in gpid and imp_1 <> '38' then imp_2 := '38' else
    If '39' in gpid and imp_1 <> '39' then imp_2 := '39' else
    If '41' in gpid and imp_1 <> '41' then imp_2 := '41' else
    If '42' in gpid and imp_1 <> '42' then imp_2 := '42' else
    If '43' in gpid and imp_1 <> '43' then imp_2 := '43' else
    If '46' in gpid and imp_1 <> '46' then imp_2 := '46' else
    If '48' in gpid and imp_1 <> '48' then imp_2 := '48' else
    If '49' in gpid and imp_1 <> '49' then imp_2 := '49' else
    If '65' in gpid and imp_1 <> '65' then imp_2 := '65' else
    If '25' in gpid and imp_1 <> '25' then imp_2 := '25' else
    If '26' in gpid and imp_1 <> '26' then imp_2 := '26' else
    If '27' in gpid and imp_1 <> '27' then imp_2 := '27' else
    If '45' in gpid and imp_1 <> '45' then imp_2 := '45' else
    If '50' in gpid and imp_1 <> '50' then imp_2 := '50' else
    If '51' in gpid and imp_1 <> '51' then imp_2 := '51' else
    If '57' in gpid and imp_1 <> '57' then imp_2 := '57' else
    If '69' in gpid and imp_1 <> '69' then imp_2 := '69' else
    If '81' in gpid and imp_1 <> '81' then imp_2 := '81' else
    If '82' in gpid and imp_1 <> '82' then imp_2 := '82' else

// 2.B.2 PASS 2 IMPROVEMENT - SECONDARY
    If '30' in gpid and imp_1 <> '30' then imp_2 := '30' else
    If '32' in gpid and imp_1 <> '32' then imp_2 := '32' else
    If '40' in gpid and imp_1 <> '40' then imp_2 := '40' else
    If '47' in gpid and imp_1 <> '47' then imp_2 := '47' else

// 2.B.3 PASS 2 DEFAULT
    imp_2 := '00';
);

// 2.C PASS 2 FINAL
    imp_3 := imp_1 + imp_2;
);
// 3.A.1 FINAL - PRIMARY
    If imp_3 in ['3130','3100','3132','3140'] then pcc_imp := 131 else
    If imp_3 in ['6600'] then pcc_imp := 266 else
    If imp_3 in ['3600','3632'] then pcc_imp := 336 else
    If imp_3 in ['3900','3932'] then pcc_imp := 339 else
    If imp_3 in ['4300','4340'] then pcc_imp := 343 else
    If imp_3 in ['2700'] then pcc_imp := 427 else
    If imp_3 in ['3300','3332'] then pcc_imp := 433 else
    If imp_3 in ['3500','3532'] then pcc_imp := 435 else
    If imp_3 in ['3800','3832'] then pcc_imp := 438 else
    If imp_3 in ['4200','4230'] then pcc_imp := 442 else
    If imp_3 in ['5100'] then pcc_imp := 451 else
    If imp_3 in ['2600'] then pcc_imp := 526 else
    If imp_3 in ['3000','3047'] then pcc_imp := 530 else
    If imp_3 in ['3200','3240','3247','3432','3237','3732'] then pcc_imp := 532 else
    If imp_3 in ['3400'] then pcc_imp := 534 else
    If imp_3 in ['3700'] then pcc_imp := 537 else
    If imp_3 in ['3041','4100','4130'] then pcc_imp := 541 else
    If imp_3 in ['4630','4632','4640','4600','4647'] then pcc_imp := 546 else
    If imp_3 in ['4700'] then pcc_imp := 547 else
    If imp_3 in ['4830','4832','4840','4847','4800'] then pcc_imp := 548 else
    If imp_3 in ['4930','4932','4940','4947','4900'] then pcc_imp := 549 else
    If imp_3 in ['5000'] then pcc_imp := 550 else
    If imp_3 in ['5100'] then pcc_imp := 551 else
    If imp_3 in ['6530','6532','6540','6547','6500'] then pcc_imp := 565 else
    If imp_3 in ['8100'] then pcc_imp := 681 else
    If imp_3 in ['8200'] then pcc_imp := 682 else
    If imp_3 in ['4000'] then pcc_imp := 740 else
    If imp_3 in ['4500'] then pcc_imp := 845 else
    If imp_3 in ['5700'] then pcc_imp := 757 else
    If imp_3 in ['6900'] then pcc_imp := 769 else
    If imp_3 in ['6700'] then pcc_imp := 867 else
    If imp_3 in ['2500'] then pcc_imp := 925 else
    If imp_3 = 'I' then pcc_imp := 999 else

// 3.A.2 FINAL - MIXED USE
    If imp_3 = '3133' then pcc_imp := 133 else
    If imp_3 = '3134' then pcc_imp := 134 else
    If imp_3 = '3135' then pcc_imp := 135 else
    If imp_3 = '3136' then pcc_imp := 136 else
    If imp_3 = '3137' then pcc_imp := 137 else
    If imp_3 = '3138' then pcc_imp := 138 else
    If imp_3 = '3139' then pcc_imp := 139 else
    If imp_3 = '3140' then pcc_imp := 140 else
    If imp_3 = '3141' then pcc_imp := 141 else
    If imp_3 = '3142' then pcc_imp := 142 else
    If imp_3 = '3143' then pcc_imp := 143 else
    If imp_3 = '3146' then pcc_imp := 146 else
    If imp_3 = '3148' then pcc_imp := 148 else
    If imp_3 in ['3546','3846','4246'] then pcc_imp := 446 else
    If imp_3 in ['3548','3848','4248'] then pcc_imp := 448 else

    If imp_3 in ['3334','3435'] then pcc_imp := 434 else
    If imp_3 = '3436' then pcc_imp := 334 else
    If imp_3 = '3738' then pcc_imp := 437 else
    If imp_3 = '3739' then pcc_imp := 337 else
    If imp_3 = '4142' then pcc_imp := 441 else
    If imp_3 = '4143' then pcc_imp := 341 else

    If imp_3 in ['3446','3746','4146'] then pcc_imp := 546 else
    If imp_3 in ['3448','3748','4148'] then pcc_imp := 548 else

// 3.A.3 FINAL - DELETE AFTER 2007
//    If imp_3 = '6000' then pcc_imp := 960 else
//   If imp_3 = '6100' then pcc_imp := 961 else
    If imp_3 = '6200' then pcc_imp := 962 else


// 4 FINAL
    pcc_imp := 0;
    pcc_imp;
);
// IMP END


// GRM START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
then 
(
// 1.A. IF GRM COUNTY USE GRM SYSTYPE FOR PCC_STD
//    If '102500'  in gpid then grm_1 := 100 else     // 100- Agricultural Vac                                           
//    If '102501'  in gpid then grm_1 := 101 else     // 101- Irrigated Crop Land                                        
//    If '102502'  in gpid then grm_1 := 102 else     // 102- Irrigated Grazing Land                                     
//    If '102503'  in gpid then grm_1 := 103 else     // 103- Non-irrigated Crop Land                                    
//    If '102504'  in gpid then grm_1 := 104 else     // 104- Meadow Land                                                
//    If '102505'  in gpid then grm_1 := 105 else     // 105- Dry Grazing                                                
//    If '102506'  in gpid then grm_1 := 106 else     // 106- Productivity Forest Land                                   
//    If '102507'  in gpid then grm_1 := 107 else     // 107- Bare Forest Land                                           
//    If '102508'  in gpid then grm_1 := 108 else     // 108- Speculative Homesite                                       
//    If '102509'  in gpid then grm_1 := 109 else     // 109- Agri greenhouses                                           
//    If '102510'  in gpid then grm_1 := 110 else     // 110- Agri Homesite Land                                         
//    If '102511'  in gpid then grm_1 := 111 else     // 111
//    If '102512'  in gpid then grm_1 := 112 else     // 112
//    If '102513'  in gpid then grm_1 := 113 else     // 113
//    If '102514'  in gpid then grm_1 := 114 else     // 114
//    If '102515'  in gpid then grm_1 := 115 else     // 115
//    If '102516'  in gpid then grm_1 := 116 else     // 116
//    If '102517'  in gpid then grm_1 := 117 else     // 117
//    If '102518'  in gpid then grm_1 := 118 else     // 118- Other Rural Land                                           
//    If '102519'  in gpid then grm_1 := 119 else     // 119 - Waste                                                     
//    If '102520'  in gpid then grm_1 := 120 else     // 120- Agri timber                                                
//    If '102521'  in gpid then grm_1 := 121 else     // 121
//    If '102522'  in gpid then grm_1 := 122 else     // 122
//    If '102523'  in gpid then grm_1 := 123 else     // 123
//    If '102524'  in gpid then grm_1 := 124 else     // 124
//    If '102525'  in gpid then grm_1 := 125 else     // 125
//    If '102526'  in gpid then grm_1 := 126 else     // 126
//    If '102527'  in gpid then grm_1 := 127 else     // 127
//    If '102528'  in gpid then grm_1 := 128 else     // 128
//    If '102529'  in gpid then grm_1 := 129 else     // 129
//    If '102530'  in gpid then grm_1 := 130 else     // 130
//    If '102531'  in gpid then grm_1 := 131 else     // Residential Improv on Cat 10                                    
//    If '102532'  in gpid then grm_1 := 132 else     // Non-Residential Improv Cat 10                                   
//    If '102533'  in gpid then grm_1 := 133 else     // 133
//    If '102534'  in gpid then grm_1 := 134 else     // 134
//    If '102535'  in gpid then grm_1 := 135 else     // 135
//    If '102536'  in gpid then grm_1 := 136 else     // 136
//    If '102537'  in gpid then grm_1 := 137 else     // 137
//    If '102538'  in gpid then grm_1 := 138 else     // 138
//    If '102539'  in gpid then grm_1 := 139 else     // 139
//    If '102540'  in gpid then grm_1 := 140 else     // 140
//    If '102541'  in gpid then grm_1 := 141 else     // 141
//    If '102542'  in gpid then grm_1 := 142 else     // 142
//    If '102543'  in gpid then grm_1 := 143 else     // 143
//    If '102544'  in gpid then grm_1 := 144 else     // 144
//    If '102545'  in gpid then grm_1 := 145 else     // 145
//    If '102546'  in gpid then grm_1 := 146 else     // 146
//    If '102547'  in gpid then grm_1 := 147 else     // 147
//    If '102548'  in gpid then grm_1 := 148 else     // MH Real Cat 10                                                  
//    If '102549'  in gpid then grm_1 := 149 else     // 149
//    If '102550'  in gpid then grm_1 := 150 else     // 150
//    If '102551'  in gpid then grm_1 := 151 else     // 151
//    If '102552'  in gpid then grm_1 := 152 else     // 152
//    If '102553'  in gpid then grm_1 := 153 else     // 153
//    If '102554'  in gpid then grm_1 := 154 else     // 154
//    If '102555'  in gpid then grm_1 := 155 else     // 155
//    If '102556'  in gpid then grm_1 := 156 else     // 156
//    If '102557'  in gpid then grm_1 := 157 else     // 157-Equities in State Land                                      
//    If '102558'  in gpid then grm_1 := 158 else     // 158
//    If '102559'  in gpid then grm_1 := 159 else     // 159
//    If '102560'  in gpid then grm_1 := 160 else     // 160
//    If '102561'  in gpid then grm_1 := 161 else     // 161- Ag Imp/Leased Land                                         
//    If '102562'  in gpid then grm_1 := 162 else     // 162
//    If '102563'  in gpid then grm_1 := 163 else     // 163
//    If '102564'  in gpid then grm_1 := 164 else     // 164
//    If '102565'  in gpid then grm_1 := 165 else     // 165
//    If '102566'  in gpid then grm_1 := 166 else     // 166
//    If '102567'  in gpid then grm_1 := 167 else     // 167
//    If '102568'  in gpid then grm_1 := 168 else     // 168
//    If '102569'  in gpid then grm_1 := 169 else     // 169
//    If '102570'  in gpid then grm_1 := 170 else     // 170
//    If '102571'  in gpid then grm_1 := 171 else     // 171
//    If '102572'  in gpid then grm_1 := 172 else     // 172
//    If '102573'  in gpid then grm_1 := 173 else     // 173
//    If '102574'  in gpid then grm_1 := 174 else     // 174
//    If '102575'  in gpid then grm_1 := 175 else     // 175
//    If '102576'  in gpid then grm_1 := 176 else     // 176
//    If '102577'  in gpid then grm_1 := 177 else     // 177
//    If '102578'  in gpid then grm_1 := 178 else     // 178
//    If '102579'  in gpid then grm_1 := 179 else     // 179
//    If '102580'  in gpid then grm_1 := 180 else     // 180
//    If '102581'  in gpid then grm_1 := 181 else     // 181- Ag (not classified)                                        
//    If '102582'  in gpid then grm_1 := 182 else     // 182- Ag related activities                                      
//    If '102583'  in gpid then grm_1 := 183 else     // 183- Ag classified in O.S.                                      
//    If '102584'  in gpid then grm_1 := 184 else     // 184
//    If '102585'  in gpid then grm_1 := 185 else     // 185
//    If '102586'  in gpid then grm_1 := 186 else     // 186
//    If '102587'  in gpid then grm_1 := 187 else     // 187
//    If '102588'  in gpid then grm_1 := 188 else     // 188
//    If '102589'  in gpid then grm_1 := 189 else     // 189
//    If '102590'  in gpid then grm_1 := 190 else     // 190
//    If '102591'  in gpid then grm_1 := 191 else     // 191- Undetermined                                               
//    If '102592'  in gpid then grm_1 := 192 else     // 192
//    If '102593'  in gpid then grm_1 := 193 else     // 193
//    If '102594'  in gpid then grm_1 := 194 else     // 194- Open space                                                 
//    If '102595'  in gpid then grm_1 := 195 else     // 195
//    If '102596'  in gpid then grm_1 := 196 else     // 196
//    If '102597'  in gpid then grm_1 := 197 else     // 197
//    If '102598'  in gpid then grm_1 := 198 else     // 198
//    If '102599'  in gpid then grm_1 := 199 else     // 199-Other undeveloped land                                      
//    If '102600'  in gpid then grm_1 := 200 else     // 200- Mineral                                                    
//    If '102601'  in gpid then grm_1 := 201 else     // 201
//    If '102602'  in gpid then grm_1 := 202 else     // 202
//    If '102603'  in gpid then grm_1 := 203 else     // 203
//    If '102604'  in gpid then grm_1 := 204 else     // 204
//    If '102605'  in gpid then grm_1 := 205 else     // 205
//    If '102606'  in gpid then grm_1 := 206 else     // 206
//    If '102607'  in gpid then grm_1 := 207 else     // 207
//    If '102608'  in gpid then grm_1 := 208 else     // 208
//    If '102609'  in gpid then grm_1 := 209 else     // 209- Mineral land                                               
//    If '102610'  in gpid then grm_1 := 210 else     // 210
//    If '102611'  in gpid then grm_1 := 211 else     // 211
//    If '102612'  in gpid then grm_1 := 212 else     // 212
//    If '102613'  in gpid then grm_1 := 213 else     // 213
//    If '102614'  in gpid then grm_1 := 214 else     // 214
//    If '102615'  in gpid then grm_1 := 215 else     // 215
//    If '102616'  in gpid then grm_1 := 216 else     // 216
//    If '102617'  in gpid then grm_1 := 217 else     // 217
//    If '102618'  in gpid then grm_1 := 218 else     // 218
//    If '102619'  in gpid then grm_1 := 219 else     // 219
//    If '102620'  in gpid then grm_1 := 220 else     // 220
//    If '102621'  in gpid then grm_1 := 221 else     // 221
//    If '102622'  in gpid then grm_1 := 222 else     // 222
//    If '102623'  in gpid then grm_1 := 223 else     // 223
//    If '102624'  in gpid then grm_1 := 224 else     // 224
//    If '102625'  in gpid then grm_1 := 225 else     // 225
//    If '102626'  in gpid then grm_1 := 226 else     // 226
//    If '102627'  in gpid then grm_1 := 227 else     // 227
//    If '102628'  in gpid then grm_1 := 228 else     // 228
//    If '102629'  in gpid then grm_1 := 229 else     // 229
//    If '102630'  in gpid then grm_1 := 230 else     // 230
//    If '102631'  in gpid then grm_1 := 231 else     // 231
//    If '102632'  in gpid then grm_1 := 232 else     // 232
//    If '102633'  in gpid then grm_1 := 233 else     // 233
//    If '102634'  in gpid then grm_1 := 234 else     // 234
//    If '102635'  in gpid then grm_1 := 235 else     // 235
//    If '102636'  in gpid then grm_1 := 236 else     // 236
//    If '102637'  in gpid then grm_1 := 237 else     // 237
//    If '102638'  in gpid then grm_1 := 238 else     // 238
//    If '102639'  in gpid then grm_1 := 239 else     // 239
//    If '102640'  in gpid then grm_1 := 240 else     // 240
//    If '102641'  in gpid then grm_1 := 241 else     // 241
//    If '102642'  in gpid then grm_1 := 242 else     // 242
//    If '102643'  in gpid then grm_1 := 243 else     // 243
//    If '102644'  in gpid then grm_1 := 244 else     // 244
//    If '102645'  in gpid then grm_1 := 245 else     // 245
//    If '102646'  in gpid then grm_1 := 246 else     // 246
//    If '102647'  in gpid then grm_1 := 247 else     // 247
//    If '102648'  in gpid then grm_1 := 248 else     // 248
//    If '102649'  in gpid then grm_1 := 249 else     // 249
//    If '102650'  in gpid then grm_1 := 250 else     // 250
//    If '102651'  in gpid then grm_1 := 251 else     // 251
//    If '102652'  in gpid then grm_1 := 252 else     // 252
//    If '102653'  in gpid then grm_1 := 253 else     // 253
//    If '102654'  in gpid then grm_1 := 254 else     // 254
//    If '102655'  in gpid then grm_1 := 255 else     // 255
//    If '102656'  in gpid then grm_1 := 256 else     // 256
//    If '102657'  in gpid then grm_1 := 257 else     // 257
//    If '102658'  in gpid then grm_1 := 258 else     // 258
//    If '102659'  in gpid then grm_1 := 259 else     // 259
//    If '102660'  in gpid then grm_1 := 260 else     // 260
//    If '102661'  in gpid then grm_1 := 261 else     // 261
//    If '102662'  in gpid then grm_1 := 262 else     // 262
//    If '102663'  in gpid then grm_1 := 263 else     // 263
//    If '102664'  in gpid then grm_1 := 264 else     // 264
//    If '102665'  in gpid then grm_1 := 265 else     // 265
//    If '102673'  in gpid then grm_1 := 270 else     // 270- Mineral Rights                                             
//    If '1300000'  in gpid then grm_1 := 272 else     // 272
//    If '1304130'  in gpid then grm_1 := 273 else     // 273
//    If '1306099'  in gpid then grm_1 := 274 else     // 274
//    If '1306100'  in gpid then grm_1 := 275 else     // 275
//    If '1306101'  in gpid then grm_1 := 276 else     // 276
//    If '1306102'  in gpid then grm_1 := 277 else     // 277
//    If '1306103'  in gpid then grm_1 := 278 else     // 278
//    If '1306104'  in gpid then grm_1 := 279 else     // 279
//    If '1306105'  in gpid then grm_1 := 280 else     // 280
//    If '1306106'  in gpid then grm_1 := 281 else     // 281
//    If '1306107'  in gpid then grm_1 := 282 else     // 282
//    If '1306108'  in gpid then grm_1 := 283 else     // 283
//    If '1306109'  in gpid then grm_1 := 284 else     // 284
//    If '1306110'  in gpid then grm_1 := 285 else     // 285- Mining related-gravel                                      
//    If '1306111'  in gpid then grm_1 := 286 else     // 286
//    If '1306112'  in gpid then grm_1 := 287 else     // 287
//    If '1306113'  in gpid then grm_1 := 288 else     // 288
//    If '1306114'  in gpid then grm_1 := 289 else     // 289
//    If '1306115'  in gpid then grm_1 := 290 else     // 290
//    If '1306116'  in gpid then grm_1 := 291 else     // 291
//    If '1306117'  in gpid then grm_1 := 292 else     // 292
//    If '1306118'  in gpid then grm_1 := 293 else     // 293
//    If '1306119'  in gpid then grm_1 := 294 else     // 294
//    If '1306120'  in gpid then grm_1 := 295 else     // 295
//    If '1306121'  in gpid then grm_1 := 296 else     // 296
//    If '1306122'  in gpid then grm_1 := 297 else     // 297
//    If '1306123'  in gpid then grm_1 := 298 else     // 298
//    If '1306124'  in gpid then grm_1 := 299 else     // 299
//    If '1306125'  in gpid then grm_1 := 300 else     // 300- Industrial Vac land                                        
//    If '1306126'  in gpid then grm_1 := 301 else     // 301- Industrial general class                                   
//    If '1306127'  in gpid then grm_1 := 302 else     // 302
//    If '1306128'  in gpid then grm_1 := 303 else     // 303
//    If '1306129'  in gpid then grm_1 := 304 else     // 304
//    If '1306130'  in gpid then grm_1 := 305 else     // 305
//    If '1306131'  in gpid then grm_1 := 306 else     // 306
//    If '1306132'  in gpid then grm_1 := 307 else     // 307
//    If '1306133'  in gpid then grm_1 := 308 else     // 308
//    If '1306134'  in gpid then grm_1 := 309 else     // 309
//    If '1306135'  in gpid then grm_1 := 310 else     // 310- Industrial Food - drink                                    
//    If '1306136'  in gpid then grm_1 := 311 else     // 314- Rural indust land tract                                    
//    If '1306137'  in gpid then grm_1 := 312 else     // 312
//    If '1306138'  in gpid then grm_1 := 313 else     // 313
//    If '1306139'  in gpid then grm_1 := 314 else     // 314- Rural indust land tract                                    
//    If '1306140'  in gpid then grm_1 := 315 else     // 315
//    If '1306141'  in gpid then grm_1 := 316 else     // 316
//    If '1306142'  in gpid then grm_1 := 317 else     // 317- Rural indust subdivision                                   
//    If '1306143'  in gpid then grm_1 := 318 else     // 318
//    If '1306144'  in gpid then grm_1 := 319 else     // 319
//    If '1306145'  in gpid then grm_1 := 320 else     // 320 Ind foundries/hvy mfg                                       
//    If '1306146'  in gpid then grm_1 := 321 else     // 321- Food & kindred products                                    
//    If '1306147'  in gpid then grm_1 := 322 else     // 322- Indust City tract/lot                                      
//    If '1306148'  in gpid then grm_1 := 323 else     // 323- Apparel & fin. prdcts                                      
//    If '1306149'  in gpid then grm_1 := 324 else     // 324
//    If '1306150'  in gpid then grm_1 := 325 else     // 325
//    If '1306151'  in gpid then grm_1 := 326 else     // 3- Paper and allied products                                    
//    If '1306152'  in gpid then grm_1 := 327 else     // 3- Printing and publishing                                      
//    If '1306153'  in gpid then grm_1 := 328 else     // 3- Chemicals                                                    
//    If '1306154'  in gpid then grm_1 := 329 else     // 3- Petroleum refining & rel                                     
//    If '1306155'  in gpid then grm_1 := 330 else     // Ind med mfg & assembly                                          
//    If '1306156'  in gpid then grm_1 := 331 else     // 3- Rubber/misc plastic prod                                     
//    If '1306157'  in gpid then grm_1 := 332 else     // 3- Stone                                                        
//    If '1306158'  in gpid then grm_1 := 333 else     // 3- Primary metal industries                                     
//    If '1306159'  in gpid then grm_1 := 334 else     // 3- Fabricated metal products                                    
//    If '1306160'  in gpid then grm_1 := 335 else     // 3- Prof. scientific                                             
//    If '1306161'  in gpid then grm_1 := 336 else     // 336
//    If '1306162'  in gpid then grm_1 := 337 else     // 337
//    If '1306163'  in gpid then grm_1 := 338 else     // 338
//    If '1306164'  in gpid then grm_1 := 339 else     // 3- Misc manufacturing                                           
//    If '1306165'  in gpid then grm_1 := 340 else     // Industrial lt mfg & assembly                                    
//    If '1306166'  in gpid then grm_1 := 341 else     // 341
//    If '1306167'  in gpid then grm_1 := 342 else     // 342
//    If '1306168'  in gpid then grm_1 := 343 else     // 343
//    If '1306169'  in gpid then grm_1 := 344 else     // 344
//    If '1306170'  in gpid then grm_1 := 345 else     // 345
//    If '1306171'  in gpid then grm_1 := 346 else     // 346
//    If '1306172'  in gpid then grm_1 := 347 else     // 347
//    If '1306173'  in gpid then grm_1 := 348 else     // 348
//    If '1306174'  in gpid then grm_1 := 349 else     // 349
//    If '1306175'  in gpid then grm_1 := 350 else     // Industrial warehouse                                            
//    If '1306176'  in gpid then grm_1 := 351 else     // 351
//    If '1306177'  in gpid then grm_1 := 352 else     // 352
//    If '1306178'  in gpid then grm_1 := 353 else     // 353
//    If '1306179'  in gpid then grm_1 := 354 else     // 354
//    If '1306180'  in gpid then grm_1 := 355 else     // 355
//    If '1306181'  in gpid then grm_1 := 356 else     // 356
//    If '1306182'  in gpid then grm_1 := 357 else     // 357
//    If '1306183'  in gpid then grm_1 := 358 else     // 358
//    If '1306184'  in gpid then grm_1 := 359 else     // 359
//    If '1306185'  in gpid then grm_1 := 360 else     // 360-Ind Bldg on RR r/w                                          
//    If '1306186'  in gpid then grm_1 := 361 else     // 361
//    If '1306187'  in gpid then grm_1 := 362 else     // 362
//    If '1306188'  in gpid then grm_1 := 363 else     // 363
//    If '1306189'  in gpid then grm_1 := 364 else     // 364
//    If '1306190'  in gpid then grm_1 := 365 else     // 365
//    If '1306191'  in gpid then grm_1 := 366 else     // 366
//    If '1306192'  in gpid then grm_1 := 367 else     // 367
//    If '1306193'  in gpid then grm_1 := 368 else     // 368
//    If '1306194'  in gpid then grm_1 := 369 else     // 369
//    If '1306195'  in gpid then grm_1 := 370 else     // Industrial small shops                                          
//    If '1306196'  in gpid then grm_1 := 371 else     // 371
//    If '1306197'  in gpid then grm_1 := 372 else     // 372
//    If '1306198'  in gpid then grm_1 := 373 else     // 373
//    If '1306199'  in gpid then grm_1 := 374 else     // 374
//    If '1306200'  in gpid then grm_1 := 375 else     // 375
//    If '1306201'  in gpid then grm_1 := 376 else     // 376
//    If '1306202'  in gpid then grm_1 := 377 else     // 377
//    If '1306203'  in gpid then grm_1 := 378 else     // 378
//    If '1306204'  in gpid then grm_1 := 379 else     // 379
//    If '1306205'  in gpid then grm_1 := 380 else     // Industrial mines & quarries                                     
//    If '1306206'  in gpid then grm_1 := 381 else     // 381
//    If '1306207'  in gpid then grm_1 := 382 else     // 382
//    If '1306208'  in gpid then grm_1 := 383 else     // 383
//    If '1306209'  in gpid then grm_1 := 384 else     // 384
//    If '1306210'  in gpid then grm_1 := 385 else     // 385
//    If '1306211'  in gpid then grm_1 := 386 else     // 386
//    If '1306212'  in gpid then grm_1 := 387 else     // 387
//    If '1306213'  in gpid then grm_1 := 388 else     // 388
//    If '1306214'  in gpid then grm_1 := 389 else     // 389
//    If '1306215'  in gpid then grm_1 := 390 else     // Industrial grain elevators                                      
//    If '1306216'  in gpid then grm_1 := 391 else     // 3- Undeveloped land                                             
//    If '1306217'  in gpid then grm_1 := 392 else     // 392
//    If '1306218'  in gpid then grm_1 := 393 else     // 393
//    If '1306219'  in gpid then grm_1 := 394 else     // 394
//    If '1306220'  in gpid then grm_1 := 395 else     // 395
//    If '1306221'  in gpid then grm_1 := 396 else     // 396
//    If '1306222'  in gpid then grm_1 := 397 else     // 397
//    If '1306223'  in gpid then grm_1 := 398 else     // 398
//    If '1306224'  in gpid then grm_1 := 399 else     // Indust other structures                                         
//    If '1306225'  in gpid then grm_1 := 400 else     // Commercial vacant land                                          
//    If '1306226'  in gpid then grm_1 := 401 else     // Commercial general class                                        
//    If '1306227'  in gpid then grm_1 := 402 else     // Commercially classified apts                                    
//    If '1306228'  in gpid then grm_1 := 403 else     // Commercial 40+ family apts                                      
//    If '1306229'  in gpid then grm_1 := 404 else     // Commercial/Industrial Class                                     
//    If '1306230'  in gpid then grm_1 := 405 else     // 405
//    If '1306231'  in gpid then grm_1 := 406 else     // 406
//    If '1306232'  in gpid then grm_1 := 407 else     // 407
//    If '1306233'  in gpid then grm_1 := 408 else     // 408
//    If '1306234'  in gpid then grm_1 := 409 else     // 409
//    If '1306235'  in gpid then grm_1 := 410 else     // Com Motels                                                      
//    If '1306236'  in gpid then grm_1 := 411 else     // 411- Recreational                                               
//    If '1306237'  in gpid then grm_1 := 412 else     // Com Hospitals/Nurs hms                                          
//    If '1306238'  in gpid then grm_1 := 413 else     // 413- Rural commercial tracts                                    
//    If '1306239'  in gpid then grm_1 := 414 else     // 4- Res. Hotels-Condos                                           
//    If '1306240'  in gpid then grm_1 := 415 else     // 415- Mobile home parks                                          
//    If '1306241'  in gpid then grm_1 := 416 else     // 416- Rural commercial subdiv                                    
//    If '1306242'  in gpid then grm_1 := 417 else     // 417
//    If '1306243'  in gpid then grm_1 := 418 else     // 418
//    If '1306244'  in gpid then grm_1 := 419 else     // Com Other housing                                               
//    If '1306245'  in gpid then grm_1 := 420 else     // Com Small retail                                                
//    If '1306246'  in gpid then grm_1 := 421 else     // 421- Commercial lot/ac in city                                  
//    If '1306247'  in gpid then grm_1 := 422 else     // Com Discount department store                                   
//    If '1306248'  in gpid then grm_1 := 423 else     // 423
//    If '1306249'  in gpid then grm_1 := 424 else     // Com Full line dept store                                        
//    If '1306250'  in gpid then grm_1 := 425 else     // 425- Commercial Common Area                                     
//    If '1306251'  in gpid then grm_1 := 426 else     // 426- Commercial Condo                                           
//    If '1306252'  in gpid then grm_1 := 427 else     // 427-                                                            
//    If '1306253'  in gpid then grm_1 := 428 else     // 428
//    If '1306254'  in gpid then grm_1 := 429 else     // Com Other retail buildings                                      
//    If '1306255'  in gpid then grm_1 := 430 else     // Com Restaurant/bar                                              
//    If '1306256'  in gpid then grm_1 := 431 else     // 431
//    If '1306257'  in gpid then grm_1 := 432 else     // 432
//    If '1306258'  in gpid then grm_1 := 433 else     // 433
//    If '1306259'  in gpid then grm_1 := 434 else     // 434
//    If '1306260'  in gpid then grm_1 := 435 else     // Com DriveIn restaurant                                          
//    If '1306261'  in gpid then grm_1 := 436 else     // 436
//    If '1306262'  in gpid then grm_1 := 437 else     // 437
//    If '1306263'  in gpid then grm_1 := 438 else     // 438
//    If '1306264'  in gpid then grm_1 := 439 else     // Com Other food service                                          
//    If '1306265'  in gpid then grm_1 := 440 else     // Com Dry clean/laundry                                           
//    If '1306266'  in gpid then grm_1 := 441 else     // Com Funeral home                                                
//    If '1306267'  in gpid then grm_1 := 442 else     // Com Medical clinic/offices                                      
//    If '1306268'  in gpid then grm_1 := 443 else     // 443
//    If '1306269'  in gpid then grm_1 := 444 else     // Com Full service banks                                          
//    If '1306270'  in gpid then grm_1 := 445 else     // Com Savings and loans                                           
//    If '1306271'  in gpid then grm_1 := 446 else     // 446
//    If '1306272'  in gpid then grm_1 := 447 else     // Com 1 and 2 story off bldgs                                     
//    If '1306273'  in gpid then grm_1 := 448 else     // Com Office O/T 47 walkup                                        
//    If '1306274'  in gpid then grm_1 := 449 else     // Com Office O/T 47 elev                                          
//    If '1306275'  in gpid then grm_1 := 450 else     // 450
//    If '1306276'  in gpid then grm_1 := 451 else     // 4- Wholesale trade                                              
//    If '1306277'  in gpid then grm_1 := 452 else     // 4- RT--bldg matrl                                               
//    If '1306278'  in gpid then grm_1 := 453 else     // 4- RT general merchandise                                       
//    If '1306279'  in gpid then grm_1 := 454 else     // 4- RT food                                                      
//    If '1306280'  in gpid then grm_1 := 455 else     // 4- RT auto                                                      
//    If '1306281'  in gpid then grm_1 := 456 else     // 4- RT apparel and accessories                                   
//    If '1306282'  in gpid then grm_1 := 457 else     // 4- RT furniture                                                 
//    If '1306283'  in gpid then grm_1 := 458 else     // 4- RT eating and drinking                                       
//    If '1306284'  in gpid then grm_1 := 459 else     // 4- Other retail trade                                           
//    If '1306285'  in gpid then grm_1 := 460 else     // 460-Comm Imps/Railroad R/W                                      
//    If '1306286'  in gpid then grm_1 := 461 else     // 461-Comm imps/leased land                                       
//    If '1306287'  in gpid then grm_1 := 462 else     // 462-Comm imps/exempt land                                       
//    If '1306288'  in gpid then grm_1 := 463 else     // 4- Business services                                            
//    If '1306289'  in gpid then grm_1 := 464 else     // 4- Repair services                                              
//    If '1306290'  in gpid then grm_1 := 465 else     // 4- Professional services                                        
//    If '1306291'  in gpid then grm_1 := 466 else     // 4- Contract constrctn svcs                                      
//    If '1306292'  in gpid then grm_1 := 467 else     // 4- Governmental services                                        
//    If '1306293'  in gpid then grm_1 := 468 else     // 4- Educational services                                         
//    If '1306294'  in gpid then grm_1 := 469 else     // 4- Miscellaneous services                                       
//    If '1306295'  in gpid then grm_1 := 470 else     // 470
//    If '1306296'  in gpid then grm_1 := 471 else     // 471
//    If '1306297'  in gpid then grm_1 := 472 else     // 4- Public assembly                                              
//    If '1306298'  in gpid then grm_1 := 473 else     // 4- Amusements                                                   
//    If '1306299'  in gpid then grm_1 := 474 else     // 4- Recreational activities                                      
//    If '1306300'  in gpid then grm_1 := 475 else     // 4- Resorts & group camps                                        
//    If '1306301'  in gpid then grm_1 := 476 else     // 4- Parks                                                        
//    If '1306302'  in gpid then grm_1 := 477 else     // 477
//    If '1306303'  in gpid then grm_1 := 478 else     // 478
//    If '1306304'  in gpid then grm_1 := 479 else     // 4- Other cult                                                   
//    If '1306305'  in gpid then grm_1 := 480 else     // Com Warehouse                                                   
//    If '1306306'  in gpid then grm_1 := 481 else     // 481
//    If '1306307'  in gpid then grm_1 := 482 else     // Com Truck terminals                                             
//    If '1306308'  in gpid then grm_1 := 483 else     // 483
//    If '1306309'  in gpid then grm_1 := 484 else     // 484
//    If '1306310'  in gpid then grm_1 := 485 else     // 485
//    If '1306311'  in gpid then grm_1 := 486 else     // 486
//    If '1306312'  in gpid then grm_1 := 487 else     // 487
//    If '1306313'  in gpid then grm_1 := 488 else     // 488
//    If '1306314'  in gpid then grm_1 := 489 else     // 489
//    If '1306315'  in gpid then grm_1 := 490 else     // Com Marine service facility                                     
//    If '1306316'  in gpid then grm_1 := 491 else     // 4- Undeveloped land                                             
//    If '1306317'  in gpid then grm_1 := 492 else     // 492
//    If '1306318'  in gpid then grm_1 := 493 else     // 493
//    If '1306319'  in gpid then grm_1 := 494 else     // 4- Open space                                                   
//    If '1306320'  in gpid then grm_1 := 495 else     // 495
//    If '1306321'  in gpid then grm_1 := 496 else     // Com Marina                                                      
//    If '1306322'  in gpid then grm_1 := 497 else     // 497
//    If '1306323'  in gpid then grm_1 := 498 else     // 498
//    If '1306324'  in gpid then grm_1 := 499 else     // 499- Commercial other                                           
//    If '1306325'  in gpid then grm_1 := 500 else     // Residential: Vacant lot                                         
//    If '1306326'  in gpid then grm_1 := 501 else     // Res Urban 1 family                                              
//    If '1306327'  in gpid then grm_1 := 502 else     // Res Suburban 1 fam to 19.99ac                                   
//    If '1306328'  in gpid then grm_1 := 503 else     // Res Multi-family                                                
//    If '1306329'  in gpid then grm_1 := 504 else     // Res vac unplatted 30-39.9ac                                     
//    If '1306330'  in gpid then grm_1 := 505 else     // Res vac unplatted 20+Ac                                         
//    If '1306331'  in gpid then grm_1 := 506 else     // 506
//    If '1306332'  in gpid then grm_1 := 507 else     // 507
//    If '1306333'  in gpid then grm_1 := 508 else     // 508
//    If '1306334'  in gpid then grm_1 := 509 else     // 509
//    If '1306335'  in gpid then grm_1 := 510 else     // 510- Homesite non-agriculture                                   
//    If '1306336'  in gpid then grm_1 := 511 else     // 5- Household                                                    
//    If '1306337'  in gpid then grm_1 := 512 else     // 512- Rural residential tracts                                   
//    If '1306338'  in gpid then grm_1 := 513 else     // Res 1 fam unplatted 20-29.99a                                   
//    If '1306339'  in gpid then grm_1 := 514 else     // Res 1 fam unplatted 30-39.99a                                   
//    If '1306340'  in gpid then grm_1 := 515 else     // 515- Rural resid subdivisions                                   
//    If '1306341'  in gpid then grm_1 := 516 else     // 516
//    If '1306342'  in gpid then grm_1 := 517 else     // 517
//    If '1306343'  in gpid then grm_1 := 518 else     // 518- Other Rual Land Improved                                   
//    If '1306344'  in gpid then grm_1 := 519 else     // 5- Vacation and cabin                                           
//    If '1306345'  in gpid then grm_1 := 520 else     // 520- Resid lots/tracts in city                                  
//    If '1306346'  in gpid then grm_1 := 521 else     // Res 2 fam unplatted 0-9.99 ac                                   
//    If '1306347'  in gpid then grm_1 := 522 else     // Res 2 fam unplatted 10-19.99a                                   
//    If '1306348'  in gpid then grm_1 := 523 else     // Res 2 fam unplatted 20-29.99a                                   
//    If '1306349'  in gpid then grm_1 := 524 else     // Res 2 fam unplatted 30-39.99a                                   
//    If '1306350'  in gpid then grm_1 := 525 else     // 525- Common areas- condo/tnhse                                  
//    If '1306351'  in gpid then grm_1 := 526 else     // 526 - Condominium                                               
//    If '1306352'  in gpid then grm_1 := 527 else     // 527
//    If '1306353'  in gpid then grm_1 := 528 else     // 528
//    If '1306354'  in gpid then grm_1 := 529 else     // 529
//    If '1306355'  in gpid then grm_1 := 530 else     // Res 3 family dwelling                                           
//    If '1306356'  in gpid then grm_1 := 531 else     // Res 3 fam unplatted 0-9.99 ac                                   
//    If '1306357'  in gpid then grm_1 := 532 else     // Res 3 fam unplatted 10-19.99a                                   
//    If '1306358'  in gpid then grm_1 := 533 else     // Res 3 fam unplatted 20-29.99a                                   
//    If '1306359'  in gpid then grm_1 := 534 else     // Res 3 fam unplatted 30-39.99a                                   
//    If '1306360'  in gpid then grm_1 := 535 else     // Res 3 fam unplatted 40+ ac                                      
//    If '1306361'  in gpid then grm_1 := 536 else     // 536
//    If '1306362'  in gpid then grm_1 := 537 else     // 537
//    If '1306363'  in gpid then grm_1 := 538 else     // 538
//    If '1306364'  in gpid then grm_1 := 539 else     // 539
//    If '1306365'  in gpid then grm_1 := 540 else     // 540- Other Rural Land Improved                                  
//    If '1306366'  in gpid then grm_1 := 541 else     // Res mobile home on 0-9.99 ac                                    
//    If '1306367'  in gpid then grm_1 := 542 else     // Res mobile home on 10-19.99 a                                   
//    If '1306368'  in gpid then grm_1 := 543 else     // Res Trailer unplat 10-19.99 a                                   
//    If '1306369'  in gpid then grm_1 := 544 else     // Res Trailer unplat 30-39.99 a                                   
//    If '1306370'  in gpid then grm_1 := 545 else     // Res Trailer unplatted 40+ ac                                    
//    If '1306371'  in gpid then grm_1 := 546 else     // 546 - Manuf housing                                             
//    If '1306372'  in gpid then grm_1 := 547 else     // 547
//    If '1306373'  in gpid then grm_1 := 548 else     // 548- M H on Real Property                                       
//    If '1306374'  in gpid then grm_1 := 549 else     // 549- M H on Leased Land                                         
//    If '1306375'  in gpid then grm_1 := 550 else     // Res condominium                                                 
//    If '1306376'  in gpid then grm_1 := 551 else     // Res Condo unplatted 0-9.99 ac                                   
//    If '1306377'  in gpid then grm_1 := 552 else     // Res Condo unplatted 10-19.99a                                   
//    If '1306378'  in gpid then grm_1 := 553 else     // Res Condo unplatted 20-29.99a                                   
//    If '1306379'  in gpid then grm_1 := 554 else     // Res Condo unplatted 30-39.99a                                   
//    If '1306380'  in gpid then grm_1 := 555 else     // Res Condo unplatted 40+ ac                                      
//    If '1306381'  in gpid then grm_1 := 556 else     // 556
//    If '1306382'  in gpid then grm_1 := 557 else     // 557
//    If '1306383'  in gpid then grm_1 := 558 else     // 558
//    If '1306384'  in gpid then grm_1 := 559 else     // 559
//    If '1306385'  in gpid then grm_1 := 560 else     // 560
//    If '1306386'  in gpid then grm_1 := 561 else     // 561-Res imps/leased land                                        
//    If '1306387'  in gpid then grm_1 := 562 else     // 562-Res imps/exempt land                                        
//    If '1306388'  in gpid then grm_1 := 563 else     // 563
//    If '1306389'  in gpid then grm_1 := 564 else     // 564
//    If '1306390'  in gpid then grm_1 := 565 else     // 565 - Manuf housing personal                                    
//    If '1306391'  in gpid then grm_1 := 566 else     // 566
//    If '1306392'  in gpid then grm_1 := 567 else     // 567
//    If '1306393'  in gpid then grm_1 := 568 else     // 568
//    If '1306394'  in gpid then grm_1 := 569 else     // 569
//    If '1306395'  in gpid then grm_1 := 570 else     // 570
//    If '1306396'  in gpid then grm_1 := 571 else     // 571
//    If '1306397'  in gpid then grm_1 := 572 else     // 572
//    If '1306398'  in gpid then grm_1 := 573 else     // 573
//    If '1306399'  in gpid then grm_1 := 574 else     // 574
//    If '1306400'  in gpid then grm_1 := 575 else     // 575
//    If '1306401'  in gpid then grm_1 := 576 else     // 576
//    If '1306402'  in gpid then grm_1 := 577 else     // 577
//    If '1306403'  in gpid then grm_1 := 578 else     // 578
//    If '1306404'  in gpid then grm_1 := 579 else     // 579
//    If '1306405'  in gpid then grm_1 := 580 else     // 580
//    If '1306406'  in gpid then grm_1 := 581 else     // 581
//    If '1306407'  in gpid then grm_1 := 582 else     // 582
//    If '1306408'  in gpid then grm_1 := 583 else     // 583
//    If '1306409'  in gpid then grm_1 := 584 else     // 584
//    If '1306410'  in gpid then grm_1 := 585 else     // 585
//    If '1306411'  in gpid then grm_1 := 586 else     // 586
//    If '1306412'  in gpid then grm_1 := 587 else     // 587
//    If '1306413'  in gpid then grm_1 := 588 else     // 588
//    If '1306414'  in gpid then grm_1 := 589 else     // 589
//    If '1306415'  in gpid then grm_1 := 590 else     // 590
//    If '1306416'  in gpid then grm_1 := 591 else     // 5- Undeveloped land                                             
//    If '1306417'  in gpid then grm_1 := 592 else     // 592
//    If '1306418'  in gpid then grm_1 := 593 else     // 593
//    If '1306419'  in gpid then grm_1 := 594 else     // 5- Open space                                                   
//    If '1306420'  in gpid then grm_1 := 595 else     // 595
//    If '1306421'  in gpid then grm_1 := 596 else     // 596
//    If '1306422'  in gpid then grm_1 := 597 else     // 597
//    If '1306423'  in gpid then grm_1 := 598 else     // 598
//    If '1306424'  in gpid then grm_1 := 599 else     // Residential other                                               
//    If '1306425'  in gpid then grm_1 := 600 else     // 6- USA                                                          
//    If '1306426'  in gpid then grm_1 := 601 else     // 6- Federal Govt                                                 
//    If '1306427'  in gpid then grm_1 := 602 else     // 6- State Govt                                                   
//    If '1306428'  in gpid then grm_1 := 603 else     // 6- Local Govt                                                   
//    If '1306429'  in gpid then grm_1 := 604 else     // 6- Municipality                                                 
//    If '1306430'  in gpid then grm_1 := 605 else     // 6- Religious                                                    
//    If '1306431'  in gpid then grm_1 := 606 else     // 6- Educational                                                  
//    If '1306432'  in gpid then grm_1 := 607 else     // 6- Hospital District                                            
//    If '1306433'  in gpid then grm_1 := 608 else     // 6- Charities                                                    
//    If '1306434'  in gpid then grm_1 := 609 else     // 6- Other                                                        
//    If '1306435'  in gpid then grm_1 := 610 else     // 6- Churches                                                     
//    If '1306436'  in gpid then grm_1 := 611 else     // 6- Cemeteries                                                   
//    If '1306437'  in gpid then grm_1 := 612 else     // 612
//    If '1306438'  in gpid then grm_1 := 613 else     // 613
//    If '1306439'  in gpid then grm_1 := 614 else     // 614
//    If '1306440'  in gpid then grm_1 := 615 else     // 615
//    If '1306441'  in gpid then grm_1 := 616 else     // 616
//    If '1306442'  in gpid then grm_1 := 617 else     // 617
//    If '1306443'  in gpid then grm_1 := 618 else     // 618
//    If '1306444'  in gpid then grm_1 := 619 else     // 619- Public Right-of-Way                                        
//    If '1306445'  in gpid then grm_1 := 620 else     // 620
//    If '1306446'  in gpid then grm_1 := 621 else     // 621
//    If '1306447'  in gpid then grm_1 := 622 else     // 622
//    If '1306448'  in gpid then grm_1 := 623 else     // 623
//    If '1306449'  in gpid then grm_1 := 624 else     // 624- Public or exempt land                                      
//    If '1306450'  in gpid then grm_1 := 625 else     // 625
//    If '1306451'  in gpid then grm_1 := 626 else     // 626
//    If '1306452'  in gpid then grm_1 := 627 else     // 627
//    If '1306453'  in gpid then grm_1 := 628 else     // 628
//    If '1306454'  in gpid then grm_1 := 629 else     // 629
//    If '1306455'  in gpid then grm_1 := 630 else     // 630
//    If '1306456'  in gpid then grm_1 := 631 else     // 631
//    If '1306457'  in gpid then grm_1 := 632 else     // 632
//    If '1306458'  in gpid then grm_1 := 633 else     // 633
//    If '1306459'  in gpid then grm_1 := 634 else     // 634
//    If '1306460'  in gpid then grm_1 := 635 else     // 635
//    If '1306461'  in gpid then grm_1 := 636 else     // 636
//    If '1306462'  in gpid then grm_1 := 637 else     // 637
//    If '1306463'  in gpid then grm_1 := 638 else     // 638
//    If '1306464'  in gpid then grm_1 := 639 else     // 639
//    If '1306465'  in gpid then grm_1 := 640 else     // 640
//    If '1306466'  in gpid then grm_1 := 641 else     // 641
//    If '1306467'  in gpid then grm_1 := 642 else     // 642
//    If '1306468'  in gpid then grm_1 := 643 else     // 643
//    If '1306469'  in gpid then grm_1 := 644 else     // 644
//    If '1306471'  in gpid then grm_1 := 645 else     // 645
//    If '1306472'  in gpid then grm_1 := 646 else     // 646
//    If '1306473'  in gpid then grm_1 := 647 else     // 647
//    If '1306474'  in gpid then grm_1 := 648 else     // 648
//    If '1306475'  in gpid then grm_1 := 649 else     // 649
//    If '1306476'  in gpid then grm_1 := 650 else     // 650
//    If '1306477'  in gpid then grm_1 := 651 else     // 651
//    If '1306478'  in gpid then grm_1 := 652 else     // 652
//    If '1306479'  in gpid then grm_1 := 653 else     // 653
//    If '1306480'  in gpid then grm_1 := 654 else     // 654
//    If '1306481'  in gpid then grm_1 := 655 else     // 655
//    If '1306482'  in gpid then grm_1 := 656 else     // 656
//    If '1306483'  in gpid then grm_1 := 657 else     // 657
//    If '1306484'  in gpid then grm_1 := 658 else     // 658
//    If '1306485'  in gpid then grm_1 := 659 else     // 659
//    If '1306486'  in gpid then grm_1 := 660 else     // 660
//    If '1306487'  in gpid then grm_1 := 661 else     // 661- Imp/RR or Exempt Land                                      
//    If '1306488'  in gpid then grm_1 := 662 else     // 662
//    If '1306489'  in gpid then grm_1 := 663 else     // 663
//    If '1306490'  in gpid then grm_1 := 664 else     // 664
//    If '1306491'  in gpid then grm_1 := 665 else     // 665
//    If '1306492'  in gpid then grm_1 := 666 else     // 666
//    If '1306493'  in gpid then grm_1 := 667 else     // 667- Operating property                                         
//    If '1306494'  in gpid then grm_1 := 668 else     // 668
//    If '1306495'  in gpid then grm_1 := 669 else     // 669
//    If '1306496'  in gpid then grm_1 := 670 else     // 670
//    If '1306497'  in gpid then grm_1 := 671 else     // 671
//    If '1306498'  in gpid then grm_1 := 672 else     // 672
//    If '1306499'  in gpid then grm_1 := 673 else     // 673- Water                                                      
//    If '1306500'  in gpid then grm_1 := 674 else     // 674
//    If '1306501'  in gpid then grm_1 := 675 else     // 675
//    If '1306502'  in gpid then grm_1 := 676 else     // 676
//    If '1306503'  in gpid then grm_1 := 677 else     // 677
//    If '1306504'  in gpid then grm_1 := 678 else     // 678
//    If '1306505'  in gpid then grm_1 := 679 else     // 679
//    If '1306506'  in gpid then grm_1 := 680 else     // 680
//    If '1306507'  in gpid then grm_1 := 681 else     // 681 - Exempt property                                           
//    If '1306508'  in gpid then grm_1 := 682 else     // 682
//    If '1306509'  in gpid then grm_1 := 683 else     // 683
//    If '1306510'  in gpid then grm_1 := 684 else     // 684
//    If '1306511'  in gpid then grm_1 := 685 else     // 685
//    If '1306512'  in gpid then grm_1 := 686 else     // 686
//    If '1306513'  in gpid then grm_1 := 687 else     // 687
//    If '1306514'  in gpid then grm_1 := 688 else     // 688
//    If '1306515'  in gpid then grm_1 := 689 else     // 689
//    If '1306516'  in gpid then grm_1 := 690 else     // 690
//    If '1306517'  in gpid then grm_1 := 691 else     // 691
//    If '1306518'  in gpid then grm_1 := 692 else     // 692
//    If '1306519'  in gpid then grm_1 := 693 else     // 693
//    If '1306520'  in gpid then grm_1 := 694 else     // 694
//    If '1306521'  in gpid then grm_1 := 695 else     // 695
//    If '1306522'  in gpid then grm_1 := 696 else     // 696
//    If '1306523'  in gpid then grm_1 := 697 else     // 697
//    If '1306524'  in gpid then grm_1 := 698 else     // 698
//    If '1306525'  in gpid then grm_1 := 699 else     // 699 - Fish & Game                                               
//    If '1306526'  in gpid then grm_1 := 700 else     // 700
//    If '1306527'  in gpid then grm_1 := 701 else     // 701
//    If '1306528'  in gpid then grm_1 := 702 else     // 702
//    If '1306529'  in gpid then grm_1 := 703 else     // 703
//    If '1306530'  in gpid then grm_1 := 704 else     // 704
//    If '1306531'  in gpid then grm_1 := 705 else     // 705
//    If '1306532'  in gpid then grm_1 := 706 else     // 706
//    If '1306533'  in gpid then grm_1 := 707 else     // 707
//    If '1306534'  in gpid then grm_1 := 708 else     // 708
//    If '1306535'  in gpid then grm_1 := 709 else     // 709
//    If '1306536'  in gpid then grm_1 := 710 else     // 710
//    If '1306537'  in gpid then grm_1 := 711 else     // 711
//    If '1306538'  in gpid then grm_1 := 712 else     // 712
//    If '1306539'  in gpid then grm_1 := 713 else     // 713
//    If '1306540'  in gpid then grm_1 := 714 else     // 714
//    If '1306541'  in gpid then grm_1 := 715 else     // 715
//    If '1306542'  in gpid then grm_1 := 716 else     // 716
//    If '1306543'  in gpid then grm_1 := 717 else     // 717
//    If '1306544'  in gpid then grm_1 := 718 else     // 718
//    If '1306545'  in gpid then grm_1 := 719 else     // 719
//    If '1306546'  in gpid then grm_1 := 720 else     // 720
//    If '1306547'  in gpid then grm_1 := 721 else     // 721
//    If '1306548'  in gpid then grm_1 := 722 else     // 722
//    If '1306549'  in gpid then grm_1 := 723 else     // 723
//    If '1306550'  in gpid then grm_1 := 724 else     // 724
//    If '1306551'  in gpid then grm_1 := 725 else     // 725
//    If '1306552'  in gpid then grm_1 := 726 else     // 726
//    If '1306553'  in gpid then grm_1 := 727 else     // 727
//    If '1306554'  in gpid then grm_1 := 728 else     // 728
//    If '1306555'  in gpid then grm_1 := 729 else     // 729
//    If '1306556'  in gpid then grm_1 := 730 else     // 730
//    If '1306557'  in gpid then grm_1 := 731 else     // 731
//    If '1306558'  in gpid then grm_1 := 732 else     // 732
//    If '1306559'  in gpid then grm_1 := 733 else     // 733
//    If '1306560'  in gpid then grm_1 := 734 else     // 734
//    If '1306561'  in gpid then grm_1 := 735 else     // 735
//    If '1306562'  in gpid then grm_1 := 736 else     // 736
//    If '1306563'  in gpid then grm_1 := 737 else     // 737
//    If '1306564'  in gpid then grm_1 := 738 else     // 738
//    If '1306565'  in gpid then grm_1 := 739 else     // 739
//    If '1306566'  in gpid then grm_1 := 740 else     // 740
//    If '1306567'  in gpid then grm_1 := 741 else     // 741
//    If '1306568'  in gpid then grm_1 := 742 else     // 742
//    If '1306569'  in gpid then grm_1 := 743 else     // 743
//    If '1306570'  in gpid then grm_1 := 744 else     // 744
//    If '1306571'  in gpid then grm_1 := 745 else     // 745
//    If '1306572'  in gpid then grm_1 := 746 else     // 746
//    If '1306573'  in gpid then grm_1 := 747 else     // 747
//    If '1306574'  in gpid then grm_1 := 748 else     // 748
//    If '1306575'  in gpid then grm_1 := 749 else     // 749
//    If '1306576'  in gpid then grm_1 := 750 else     // 750
//    If '1306577'  in gpid then grm_1 := 751 else     // 751
//    If '1306578'  in gpid then grm_1 := 752 else     // 752
//    If '1306579'  in gpid then grm_1 := 753 else     // 753
//    If '1306580'  in gpid then grm_1 := 754 else     // 754
//    If '1306581'  in gpid then grm_1 := 755 else     // 755
//    If '1306582'  in gpid then grm_1 := 756 else     // 756
//    If '1306583'  in gpid then grm_1 := 757 else     // 757
//    If '1306584'  in gpid then grm_1 := 758 else     // 758
//    If '1306585'  in gpid then grm_1 := 759 else     // 759
//    If '1306586'  in gpid then grm_1 := 760 else     // 760
//    If '1306587'  in gpid then grm_1 := 761 else     // 761
//    If '1306588'  in gpid then grm_1 := 762 else     // 762
//    If '1306589'  in gpid then grm_1 := 763 else     // 763
//    If '1306590'  in gpid then grm_1 := 764 else     // 764
//    If '1306591'  in gpid then grm_1 := 765 else     // 765
//    If '1306592'  in gpid then grm_1 := 766 else     // 766
//    If '1306593'  in gpid then grm_1 := 767 else     // 767
//    If '1306594'  in gpid then grm_1 := 768 else     // 768
//    If '1306595'  in gpid then grm_1 := 769 else     // 769
//    If '1306596'  in gpid then grm_1 := 770 else     // 770
//    If '1306597'  in gpid then grm_1 := 771 else     // 771
//    If '1306598'  in gpid then grm_1 := 772 else     // 772
//    If '1306599'  in gpid then grm_1 := 773 else     // 773
//    If '1306600'  in gpid then grm_1 := 774 else     // 774
//    If '1306601'  in gpid then grm_1 := 775 else     // 775
//    If '1306602'  in gpid then grm_1 := 776 else     // 776
//    If '1306603'  in gpid then grm_1 := 777 else     // 777
//    If '1306604'  in gpid then grm_1 := 778 else     // 778
//    If '1306605'  in gpid then grm_1 := 779 else     // 779
//    If '1306606'  in gpid then grm_1 := 780 else     // 780
//    If '1306607'  in gpid then grm_1 := 781 else     // 781
//    If '1306608'  in gpid then grm_1 := 782 else     // 782
//    If '1306609'  in gpid then grm_1 := 783 else     // 783
//    If '1306610'  in gpid then grm_1 := 784 else     // 784
//    If '1306611'  in gpid then grm_1 := 785 else     // 785
//    If '1306612'  in gpid then grm_1 := 786 else     // 7- Reforestation                                                
//    If '1306613'  in gpid then grm_1 := 787 else     // 7- Classified forest                                            
//    If '1306614'  in gpid then grm_1 := 788 else     // 7- Designated forest                                            
//    If '1306615'  in gpid then grm_1 := 789 else     // 7- Other resource production                                    
//    If '1306616'  in gpid then grm_1 := 790 else     // 790
//    If '1306617'  in gpid then grm_1 := 791 else     // 791
//    If '1306618'  in gpid then grm_1 := 792 else     // 792
//    If '1306619'  in gpid then grm_1 := 793 else     // 793
//    If '1306620'  in gpid then grm_1 := 794 else     // 7- Open space                                                   
//    If '1306621'  in gpid then grm_1 := 795 else     // 7- Open space timber                                            
//    If '1306622'  in gpid then grm_1 := 796 else     // 796
//    If '1306623'  in gpid then grm_1 := 797 else     // 797
//    If '1306624'  in gpid then grm_1 := 798 else     // 798
//    If '1306625'  in gpid then grm_1 := 799 else     // 799
//    If '1306626'  in gpid then grm_1 := 800 else     // Utility: Agricultural                                           
//    If '1306627'  in gpid then grm_1 := 801 else     // 801
//    If '1306628'  in gpid then grm_1 := 802 else     // 802
//    If '1306629'  in gpid then grm_1 := 803 else     // 803
//    If '1306630'  in gpid then grm_1 := 804 else     // 804
//    If '1306631'  in gpid then grm_1 := 805 else     // 805
//    If '1306632'  in gpid then grm_1 := 806 else     // 806
//    If '1306633'  in gpid then grm_1 := 807 else     // 807
//    If '1306634'  in gpid then grm_1 := 808 else     // 808
//    If '1306635'  in gpid then grm_1 := 809 else     // 809
//    If '1306636'  in gpid then grm_1 := 810 else     // Utility: Mineral                                                
//    If '1306637'  in gpid then grm_1 := 811 else     // 811
//    If '1306638'  in gpid then grm_1 := 812 else     // 812
//    If '1306639'  in gpid then grm_1 := 813 else     // 813
//    If '1306640'  in gpid then grm_1 := 814 else     // 814
//    If '1306641'  in gpid then grm_1 := 815 else     // 815
//    If '1306642'  in gpid then grm_1 := 816 else     // 816
//    If '1306643'  in gpid then grm_1 := 817 else     // 817
//    If '1306644'  in gpid then grm_1 := 818 else     // 818
//    If '1306645'  in gpid then grm_1 := 819 else     // 819
//    If '1306646'  in gpid then grm_1 := 820 else     // Utility: Industrial                                             
//    If '1306647'  in gpid then grm_1 := 821 else     // 821
//    If '1306648'  in gpid then grm_1 := 822 else     // 822
//    If '1306649'  in gpid then grm_1 := 823 else     // 823
//    If '1306650'  in gpid then grm_1 := 824 else     // 824
//    If '1306651'  in gpid then grm_1 := 825 else     // 825
//    If '1306652'  in gpid then grm_1 := 826 else     // 826
//    If '1306653'  in gpid then grm_1 := 827 else     // 827
//    If '1306654'  in gpid then grm_1 := 828 else     // 828
//    If '1306655'  in gpid then grm_1 := 829 else     // 829
//    If '1306656'  in gpid then grm_1 := 830 else     // Utility: Commercial                                             
//    If '1306657'  in gpid then grm_1 := 831 else     // 831
//    If '1306658'  in gpid then grm_1 := 832 else     // 832
//    If '1306659'  in gpid then grm_1 := 833 else     // 833
//    If '1306660'  in gpid then grm_1 := 834 else     // 834
//    If '1306661'  in gpid then grm_1 := 835 else     // 835
//    If '1306662'  in gpid then grm_1 := 836 else     // 836
//    If '1306663'  in gpid then grm_1 := 837 else     // 837
//    If '1306664'  in gpid then grm_1 := 838 else     // 838
//    If '1306665'  in gpid then grm_1 := 839 else     // 839
//    If '1306666'  in gpid then grm_1 := 840 else     // Utility: RR real prop-ops                                       
//    If '1306667'  in gpid then grm_1 := 841 else     // 8- Railroad/Transit transport                                   
//    If '1306668'  in gpid then grm_1 := 842 else     // 8- Motor vehicle transport                                      
//    If '1306669'  in gpid then grm_1 := 843 else     // 8- Aircraft transport                                           
//    If '1306670'  in gpid then grm_1 := 844 else     // 8- Marine craft transport                                       
//    If '1306671'  in gpid then grm_1 := 845 else     // 845- Locally Assessed Operating Property                        
//    If '1306672'  in gpid then grm_1 := 846 else     // 8- Automobile parking                                           
//    If '1306673'  in gpid then grm_1 := 847 else     // 8- Communication                                                
//    If '1306674'  in gpid then grm_1 := 848 else     // 8- Utilities                                                    
//    If '1306675'  in gpid then grm_1 := 849 else     // 8- Other transpt                                                
//    If '1306676'  in gpid then grm_1 := 850 else     // Utility: RR real prop-not ops                                   
//    If '1306677'  in gpid then grm_1 := 851 else     // 851
//    If '1306678'  in gpid then grm_1 := 852 else     // 852
//    If '1306679'  in gpid then grm_1 := 853 else     // 853
//    If '1306680'  in gpid then grm_1 := 854 else     // 854
//    If '1306681'  in gpid then grm_1 := 855 else     // 855
//    If '1306682'  in gpid then grm_1 := 856 else     // 856
//    If '1306683'  in gpid then grm_1 := 857 else     // 857
//    If '1306684'  in gpid then grm_1 := 858 else     // 858
//    If '1306685'  in gpid then grm_1 := 859 else     // 859
//    If '1306686'  in gpid then grm_1 := 860 else     // Utility: RR pers prop-ops                                       
//    If '1306687'  in gpid then grm_1 := 861 else     // 861
//    If '1306688'  in gpid then grm_1 := 862 else     // 862
//    If '1306689'  in gpid then grm_1 := 863 else     // 863
//    If '1306690'  in gpid then grm_1 := 864 else     // 864
//    If '1306691'  in gpid then grm_1 := 865 else     // 865
//    If '1306692'  in gpid then grm_1 := 866 else     // 866
//    If '1306693'  in gpid then grm_1 := 867 else     // 867- Op Prop Central Assess                                     
//    If '1306694'  in gpid then grm_1 := 868 else     // 868
//    If '1306695'  in gpid then grm_1 := 869 else     // 869
//    If '1306696'  in gpid then grm_1 := 870 else     // Utility: RR pers prop-not ops                                   
//    If '1306697'  in gpid then grm_1 := 871 else     // 871
//    If '1306698'  in gpid then grm_1 := 872 else     // 872
//    If '1306699'  in gpid then grm_1 := 873 else     // 873
//    If '1306700'  in gpid then grm_1 := 874 else     // 874
//    If '1306701'  in gpid then grm_1 := 875 else     // 875
//    If '1306702'  in gpid then grm_1 := 876 else     // 876
//    If '1306703'  in gpid then grm_1 := 877 else     // 877
//    If '1306704'  in gpid then grm_1 := 878 else     // 878
//    If '1306705'  in gpid then grm_1 := 879 else     // 879
//    If '1306706'  in gpid then grm_1 := 880 else     // Utility: Pers prop - not RR                                     
//    If '1306707'  in gpid then grm_1 := 881 else     // 881
//    If '1306708'  in gpid then grm_1 := 882 else     // 882
//    If '1306709'  in gpid then grm_1 := 883 else     // 883
//    If '1306710'  in gpid then grm_1 := 884 else     // 884
//    If '1306711'  in gpid then grm_1 := 885 else     // 885
//    If '1306712'  in gpid then grm_1 := 886 else     // 886
//    If '1306713'  in gpid then grm_1 := 887 else     // 887
//    If '1306714'  in gpid then grm_1 := 888 else     // 888
//    If '1306715'  in gpid then grm_1 := 889 else     // 889
//    If '1306716'  in gpid then grm_1 := 890 else     // 890
//    If '1306717'  in gpid then grm_1 := 891 else     // 891
//    If '1306718'  in gpid then grm_1 := 892 else     // 892
//    If '1306719'  in gpid then grm_1 := 893 else     // 893
//    If '1306720'  in gpid then grm_1 := 894 else     // 894
//    If '1306721'  in gpid then grm_1 := 895 else     // 895
//    If '1306722'  in gpid then grm_1 := 896 else     // 896
//    If '1306723'  in gpid then grm_1 := 897 else     // 897
//    If '1306724'  in gpid then grm_1 := 898 else     // 898
//    If '1306725'  in gpid then grm_1 := 899 else     // 899
//    If '1306726'  in gpid then grm_1 := 900 else     // 900
//    If '1306727'  in gpid then grm_1 := 901 else     // 901
//    If '1306728'  in gpid then grm_1 := 902 else     // 902
//    If '1306729'  in gpid then grm_1 := 903 else     // 903
//    If '1306730'  in gpid then grm_1 := 904 else     // 904
//    If '1306731'  in gpid then grm_1 := 905 else     // 905
//    If '1306732'  in gpid then grm_1 := 906 else     // 906
//    If '1306733'  in gpid then grm_1 := 907 else     // 907
//    If '1306734'  in gpid then grm_1 := 908 else     // 908
//    If '1306735'  in gpid then grm_1 := 909 else     // 909
//    If '1306736'  in gpid then grm_1 := 910 else     // 910
//    If '1306737'  in gpid then grm_1 := 911 else     // 911
//    If '1306738'  in gpid then grm_1 := 912 else     // 912
//    If '1306739'  in gpid then grm_1 := 913 else     // 913
//    If '1306740'  in gpid then grm_1 := 914 else     // 914
//    If '1306741'  in gpid then grm_1 := 915 else     // 915
//    If '1306742'  in gpid then grm_1 := 916 else     // 916
//    If '1306743'  in gpid then grm_1 := 917 else     // 917
//    If '1306744'  in gpid then grm_1 := 918 else     // 918
//    If '1306745'  in gpid then grm_1 := 919 else     // 919
//    If '1306746'  in gpid then grm_1 := 920 else     // 920
//    If '1306747'  in gpid then grm_1 := 921 else     // 921
//    If '1306748'  in gpid then grm_1 := 922 else     // 922
//    If '1306749'  in gpid then grm_1 := 923 else     // 923
//    If '1306750'  in gpid then grm_1 := 924 else     // 924
//    If '1306751'  in gpid then grm_1 := 925 else     // 925
//    If '1306752'  in gpid then grm_1 := 926 else     // 926
//    If '1306753'  in gpid then grm_1 := 927 else     // 927
//    If '1306754'  in gpid then grm_1 := 928 else     // 928
//    If '1306755'  in gpid then grm_1 := 929 else     // 929
//    If '1306756'  in gpid then grm_1 := 930 else     // 930
//    If '1306757'  in gpid then grm_1 := 931 else     // 931
//    If '1306758'  in gpid then grm_1 := 932 else     // 932
//    If '1306759'  in gpid then grm_1 := 933 else     // 933
//    If '1306760'  in gpid then grm_1 := 934 else     // 934
//    If '1306761'  in gpid then grm_1 := 935 else     // 935
//    If '1306762'  in gpid then grm_1 := 936 else     // 936
//    If '1306763'  in gpid then grm_1 := 937 else     // 937
//    If '1306764'  in gpid then grm_1 := 938 else     // 938
//    If '1306765'  in gpid then grm_1 := 939 else     // 939
//    If '1306766'  in gpid then grm_1 := 940 else     // 940
//    If '1306767'  in gpid then grm_1 := 941 else     // 941
//    If '1306768'  in gpid then grm_1 := 942 else     // 942
//    If '1306769'  in gpid then grm_1 := 943 else     // 943
//    If '1306770'  in gpid then grm_1 := 944 else     // 944/
//    If '1306771'  in gpid then grm_1 := 945 else     // 945
//    If '1306772'  in gpid then grm_1 := 946 else     // 946
//    If '1306773'  in gpid then grm_1 := 947 else     // 947
//    If '1306774'  in gpid then grm_1 := 948 else     // 948
//    If '1306775'  in gpid then grm_1 := 949 else     // 949
//    If '1306776'  in gpid then grm_1 := 950 else     // 950
//    If '1306777'  in gpid then grm_1 := 951 else     // 951
//    If '1306778'  in gpid then grm_1 := 952 else     // 952
//    If '1306779'  in gpid then grm_1 := 953 else     // 953
//    If '1306780'  in gpid then grm_1 := 954 else     // 954
//    If '1306781'  in gpid then grm_1 := 955 else     // 955
//    If '1306782'  in gpid then grm_1 := 956 else     // 956
//    If '1306783'  in gpid then grm_1 := 957 else     // 957
//    If '1306784'  in gpid then grm_1 := 958 else     // 958
//    If '1306785'  in gpid then grm_1 := 959 else     // 959
//    If '1306786'  in gpid then grm_1 := 960 else     // 960
//    If '1306787'  in gpid then grm_1 := 961 else     // 961
//    If '1306788'  in gpid then grm_1 := 962 else     // 962
//    If '1306789'  in gpid then grm_1 := 963 else     // 963
//    If '1306790'  in gpid then grm_1 := 964 else     // 964
//    If '1306791'  in gpid then grm_1 := 965 else     // 965
//    If '1306792'  in gpid then grm_1 := 966 else     // 966
//    If '1306793'  in gpid then grm_1 := 967 else     // 967
//    If '1306794'  in gpid then grm_1 := 968 else     // 968
//    If '1306795'  in gpid then grm_1 := 969 else     // 969
//    If '1306796'  in gpid then grm_1 := 970 else     // 970
//    If '1306797'  in gpid then grm_1 := 971 else     // 971
//    If '1306798'  in gpid then grm_1 := 972 else     // 972
//    If '1306799'  in gpid then grm_1 := 973 else     // 973
//    If '1306800'  in gpid then grm_1 := 974 else     // 974
//    If '1306801'  in gpid then grm_1 := 975 else     // 975
//    If '1306802'  in gpid then grm_1 := 976 else     // 976
//    If '1306803'  in gpid then grm_1 := 977 else     // 977
//    If '1306804'  in gpid then grm_1 := 978 else     // 978
//    If '1306805'  in gpid then grm_1 := 979 else     // 979
//    If '1306806'  in gpid then grm_1 := 980 else     // 980
//    If '1306807'  in gpid then grm_1 := 981 else     // 981
//    If '1306808'  in gpid then grm_1 := 982 else     // 982
//    If '1306809'  in gpid then grm_1 := 983 else     // 983
//    If '1306810'  in gpid then grm_1 := 984 else     // 984
//    If '1306811'  in gpid then grm_1 := 985 else     // 985
//    If '1306812'  in gpid then grm_1 := 986 else     // 986
//    If '1306813'  in gpid then grm_1 := 987 else     // 987
//    If '1306814'  in gpid then grm_1 := 988 else     // 988
//    If '1306815'  in gpid then grm_1 := 989 else     // 989
//    If '1306816'  in gpid then grm_1 := 990 else     // 990
//    If '1306817'  in gpid then grm_1 := 991 else     // 991
//    If '1306818'  in gpid then grm_1 := 992 else     // 992
//    If '1306819'  in gpid then grm_1 := 993 else     // 993
//    If '1306820'  in gpid then grm_1 := 994 else     // 994
//    If '1306821'  in gpid then grm_1 := 995 else     // 995
//    If '1306822'  in gpid then grm_1 := 996 else     // 996
//    If '1306823'  in gpid then grm_1 := 997 else     // 997
//    If '1306824'  in gpid then grm_1 := 998 else     // 998
//    If '1306825'  in gpid then grm_1 := 999 else     // 999 NOT COMPLETE                                                

// 1.B. DEFAULT
    grm_1 := {parcel_base.property_class};
)
    else grm_1 := {parcel_base.property_class};
// 2.A FINAL
    pcc_grm := grm_1;
    pcc_grm;
);
// GRM END


// STD START
(
// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD

// 2.A PASS 1

// 2.A.1 PASS 1 LAND - PRIMARY


// 1. GENERAL
    if pcc_land = 999 and pcc_imp = 999 then pcc_std := pcc_grm else
    if pcc_land = pcc_imp then pcc_std := pcc_land else
    if pcc_land = 0 and pcc_imp <> 0 then pcc_std := pcc_imp else
    if pcc_land <> 0 and pcc_imp = 0 then pcc_std := pcc_land else

// 2. AGRICUTURAL (100)
    if pcc_land in [110,112,115,120] and pcc_imp in [131] then pcc_std := 131 else

    if pcc_land in [110,120] and pcc_imp in [530] then pcc_std := 130 else
    if pcc_land in [101,102,103,104,105,106,107,110,112,115,118,120] and pcc_imp in [532] then pcc_std := 132 else
    if pcc_land in [118] and pcc_imp in [540,740] then pcc_std := 140 else

    if pcc_land in [111,411] and pcc_imp in [133] then pcc_std := 133 else
    if pcc_land in [111] and pcc_imp in [433] then pcc_std := 133 else
    if pcc_land in [113,413] and pcc_imp in [135] then pcc_std := 135 else
    if pcc_land in [113] and pcc_imp in [435] then pcc_std := 135 else
    if pcc_land in [116,416] and pcc_imp in [138] then pcc_std := 138 else
    if pcc_land in [116] and pcc_imp in [438] then pcc_std := 138 else
    if pcc_land in [121,421] and pcc_imp in [142] then pcc_std := 142 else
    if pcc_land in [121] and pcc_imp in [442] then pcc_std := 142 else

    if pcc_land in [110,112] and pcc_imp in [134,534] then pcc_std := 134 else
    if pcc_land in [110,115] and pcc_imp in [137,537] then pcc_std := 137 else
    if pcc_land in [120] and pcc_imp in [141,541] then pcc_std := 141 else

    if pcc_land in [114,314] and pcc_imp in [136] then pcc_std := 136 else
    if pcc_land in [114] and pcc_imp in [336] then pcc_std := 136 else
    if pcc_land in [117,317] and pcc_imp in [139] then pcc_std := 139 else
    if pcc_land in [117] and pcc_imp in [339] then pcc_std := 139 else
    if pcc_land in [122,322] and pcc_imp in [143] then pcc_std := 143 else
    if pcc_land in [122] and pcc_imp in [343] then pcc_std := 143 else

    if pcc_land in [110,112,115,120] and pcc_imp in [146,546] then pcc_std := 146 else
    if pcc_land in [110,112,115,120] and pcc_imp in [547] then pcc_std := 147 else
    if pcc_land in [110,112,115,120] and pcc_imp in [148,548] then pcc_std := 148 else

// 3. MINING
    if pcc_land in [209] and pcc_imp in [532] then pcc_std := 232 else

// 4. INDUSTRIAL (300)
    if pcc_land in [314] and pcc_imp in [336] then pcc_std := 336 else
    if pcc_land in [317] and pcc_imp in [339] then pcc_std := 339 else
    if pcc_land in [322] and pcc_imp in [343] then pcc_std := 343 else

    if pcc_land in [320] and pcc_imp in [530] then pcc_std := 330 else
    if pcc_land in [312] and pcc_imp in [532] then pcc_std := 332.12 else
    if pcc_land in [315] and pcc_imp in [532] then pcc_std := 332.15 else

    if pcc_land in [312,314] and pcc_imp in [334,534] then pcc_std := 334 else
    if pcc_land in [315,317] and pcc_imp in [337,537] then pcc_std := 337 else
    if pcc_land in [320,322] and pcc_imp in [341,541] then pcc_std := 341 else

    if pcc_land in [312,315,320] and pcc_imp in [346,546] then pcc_std := 346 else
    if pcc_land in [312,315,320] and pcc_imp in [348,548] then pcc_std := 348 else

// 5. COMMERCIAL (400)
    if pcc_land in [411] and pcc_imp in [433] then pcc_std := 433 else
    if pcc_land in [413] and pcc_imp in [435] then pcc_std := 435 else
    if pcc_land in [416] and pcc_imp in [438] then pcc_std := 438 else
    if pcc_land in [421] and pcc_imp in [442] then pcc_std := 442 else

    if pcc_land in [420] and pcc_imp in [530] then pcc_std := 430 else
    if pcc_land in [412] and pcc_imp in [532] then pcc_std := 432.12 else
    if pcc_land in [415] and pcc_imp in [532] then pcc_std := 432.15 else

    if pcc_land in [412,413] and pcc_imp in [434,534] then pcc_std := 434 else
    if pcc_land in [415,416] and pcc_imp in [437,537] then pcc_std := 437 else
    if pcc_land in [420,421] and pcc_imp in [441,541] then pcc_std := 441 else

    if pcc_land in [513,516,521] and pcc_imp in [446,546] then pcc_std := 446 else
    if pcc_land in [513,516,521] and pcc_imp in [448,548] then pcc_std := 448 else

// 6. RESIDENTIAL (500)
    if pcc_land in [512] and pcc_imp in [534] then pcc_std := 534 else
    if pcc_land in [515] and pcc_imp in [537] then pcc_std := 537 else
    if pcc_land in [520] and pcc_imp in [541] then pcc_std := 541 else

    if pcc_land in [520] and pcc_imp in [530] then pcc_std := 530 else
    if pcc_land in [512] and pcc_imp in [532] then pcc_std := 532.12 else
    if pcc_land in [515] and pcc_imp in [532] then pcc_std := 532.15 else
    if pcc_land in [512,515,520] and pcc_imp in [740] then pcc_std := 540 else

    if pcc_land in [512,515,520] and pcc_imp in [546] then pcc_std := 546 else
    if pcc_land in [512,515,520] and pcc_imp in [547] then pcc_std := 547 else
    if pcc_land in [512,515,520] and pcc_imp in [548] then pcc_std := 548 else

// 7. OTHER (700)
    if pcc_land in [711] and pcc_imp in [433] then pcc_std := 733 else
    if pcc_land in [713] and pcc_imp in [435] then pcc_std := 735 else
    if pcc_land in [716] and pcc_imp in [438] then pcc_std := 738 else
    if pcc_land in [718] and pcc_imp in [740] then pcc_std := 740 else
    if pcc_land in [721] and pcc_imp in [442] then pcc_std := 742 else

// 8. DELETE AFTER 2007
//    if pcc_imp in [960] then pcc_std := 962 else
//    if pcc_imp in [961] then pcc_std := 962 else
    if pcc_imp in [962] then pcc_std := 962 else

// 9. FINAL
    pcc_std := 0;
    pcc_std;
);



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
No Categories
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----

t is Total
c is Current
p is Previous
pp is ??
PP is [if total is not equal to 0, then pp is (previous/total) * 100; else 0]
cc is ??
cc is [if total is not equal to 0, then (current/total) * 100; else 0]

Target is 
if Count ({?Review Years}) < 5 then
    Count ({?Review Years}) * 20 - 5 else
    100

------
Grouping

WhilePrintingRecords;

// GENERAL
shared numberVar array total   := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
shared numbervar gpnum := 0;
shared stringvar array gpid    := ['','','','','','','','','','','','','','','','','','','',''];

// GRM
shared numbervar grm_1 := 0;
shared numbervar pcc_grm := 0;

// IMP
shared stringvar imp_1 := '';
shared stringvar imp_2 := '';
shared stringvar imp_3 := '';
shared numbervar pcc_imp := 0;

// LAND
shared stringvar land_1 := '';
shared stringvar land_2 := '';
shared stringvar land_3 := '';
shared numbervar pcc_land := 0;

// STD
shared numbervar pcc_std := 0;

// GROUP
shared numberVar grp := 0;


------

if t01 <> 0 then pp01 := (p01 / t01) * 100 else 0;
pp01;

shared numbervar no_cat;
shared numbervar parcels;
shared numbervar cat_66;
no_cat := parcels - {@t_total}-{@t33} - {@t36} - {@t35};
no_cat;



shared numbervar no_cat;
shared numbervar parcels;
shared numbervar cat_66;
no_cat := parcels - {@t_total}-{@t33} - {@t36} - {@t35};
no_cat;

evaluateafter({@lastrecordadj});
numbervar c33;
numbervar p33;
numbervar t33;
t33 := c33 + p33;
t33;

evaluateafter({@Running Totals});
numbervar c33;
c33;

evaluateafter({@Running Totals});
numbervar p33;
p33;

evaluateafter({@lastrecordadj});
numbervar c36;
numbervar p36;
numbervar t36;
t36 := c36 + p36;
t36;

evaluateafter({@lastrecordadj});
numbervar c35;
numbervar p35;
numbervar t35;
t35 := c35 + p35;
t35;

evaluateafter({@cc01});
numbervar p01;
numbervar t01;
numbervar pp01;
if t01 <> 0 then pp01 := (p01 / t01) * 100 else 0;
pp01;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Review Years
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Count ({?Review Years}) < 5 then
    Count ({?Review Years}) * 20 - 5 else
    100

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Shortage Calculations
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

((tonumber({@Target Percentage}) / 100) * {@t_total}) - {@c_total}


t_total
{@t01}+{@t02}+{@t03}+{@t04}+{@t05}+{@t06}+{@t07}+{@t08}+{@t09}+{@t10}+{@t11}+{@t12}+{@t13}+{@t14}+{@t15}+{@t16}+{@t17}+{@t18}+{@t19}+{@t20}+{@t21}+{@t22}+{@t23}+{@t24}+{@t25}+{@t26}+{@t27}+{@t28}+{@t29}+{@t30}+{@t31}+{@t32}+{@t34}+{@t37}

c_total
{@c01}+{@c02}+{@c03}+{@c04}+{@c05}+{@c06}+{@c07}+{@c08}+{@c09}+{@c10}+{@c11}+{@c12}+{@c13}+{@c14}+{@c15}+{@c16}+{@c17}+{@c18}+{@c19}+{@c20}+{@c21}+{@c22}+{@c23}+{@c24}+{@c25}+{@c26}+{@c27}+{@c28}+{@c29}+{@c30}+{@c31}+{@c32}+{@c33}+{@c34}+{@c37}

@c01 Means:
evaluateafter({@Running Totals});
numbervar c01;
c01;





-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PCC_Std
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

EvaluateAfter ({@GPID});
shared stringvar array gpid;
shared stringvar land_1;
shared stringvar land_2;
shared stringvar land_3;
shared numbervar pcc_land;
shared stringvar imp_1;
shared stringvar imp_2;
shared stringvar imp_3;
shared numbervar pcc_imp;
shared numbervar grm_1;
shared numbervar pcc_grm;
shared numbervar pcc_std;



// LAND START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
    then land_3 := 'L'
    else

// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD
(
// 2.A PASS 1
(
// 2.A.1 PASS 1 LAND - PRIMARY
    If '12' in gpid then land_1 := '12' else
    If '13' in gpid then land_1 := '13' else
    If '14' in gpid then land_1 := '14' else
    If '15' in gpid then land_1 := '15' else
    If '16' in gpid then land_1 := '16' else
    If '17' in gpid then land_1 := '17' else
    If '20' in gpid then land_1 := '20' else
    If '21' in gpid then land_1 := '21' else
    If '22' in gpid then land_1 := '22' else
    If '25' in gpid then land_1 := '25' else
    If '26' in gpid then land_1 := '26' else
    If '27' in gpid then land_1 := '27' else
    If '10' in gpid then land_1 := '10' else
    If '11' in gpid then land_1 := '11' else
    If '18' in gpid then land_1 := '18' else
    If '45' in gpid then land_1 := '45' else
    If '57' in gpid then land_1 := '57' else
    If '67' in gpid then land_1 := '67' else
    If '81' in gpid then land_1 := '81' else
    If '82' in gpid then land_1 := '82' else

// 2.A.2 PASS 1 LAND - SECONDARY
    If '01' in gpid then land_1 := '01' else
    If '02' in gpid then land_1 := '02' else
    If '03' in gpid then land_1 := '03' else
    If '04' in gpid then land_1 := '04' else
    If '05' in gpid then land_1 := '05' else
    If '06' in gpid then land_1 := '06' else
    If '07' in gpid then land_1 := '07' else
    If '09' in gpid then land_1 := '09' else
    If '66' in gpid then land_1 := '66' else
    If '70' in gpid then land_1 := '70' else
    If '19' in gpid then land_1 := '19' else

// 2.A.3 PASS 1 DEFAULT
    land_1 := '00';
);

// 2.B PASS 2
(
// 2.B.1 PASS 2 LAND - PRIMARY
    If '12' in gpid and land_1 <> '12' then land_2 := '12' else
    If '13' in gpid and land_1 <> '13' then land_2 := '13' else
    If '14' in gpid and land_1 <> '14' then land_2 := '14' else
    If '15' in gpid and land_1 <> '15' then land_2 := '15' else
    If '16' in gpid and land_1 <> '16' then land_2 := '16' else
    If '17' in gpid and land_1 <> '17' then land_2 := '17' else
    If '20' in gpid and land_1 <> '20' then land_2 := '20' else
    If '21' in gpid and land_1 <> '21' then land_2 := '21' else
    If '22' in gpid and land_1 <> '22' then land_2 := '22' else
    If '25' in gpid and land_1 <> '25' then land_2 := '25' else
    If '26' in gpid and land_1 <> '26' then land_2 := '26' else
    If '27' in gpid and land_1 <> '27' then land_2 := '27' else
    If '10' in gpid and land_1 <> '10' then land_2 := '10' else
    If '11' in gpid and land_1 <> '11' then land_2 := '11' else
    If '18' in gpid and land_1 <> '18' then land_2 := '18' else
    If '45' in gpid and land_1 <> '45' then land_2 := '45' else
    If '57' in gpid and land_1 <> '57' then land_2 := '57' else
    If '67' in gpid and land_1 <> '67' then land_2 := '67' else
    If '81' in gpid and land_1 <> '81' then land_2 := '81' else
    If '82' in gpid and land_1 <> '82' then land_2 := '82' else

// 2.B.2 PASS 2 LAND - SECONDARY
    If '01' in gpid and land_1 <> '01' then land_2 := '01' else
    If '02' in gpid and land_1 <> '02' then land_2 := '02' else
    If '03' in gpid and land_1 <> '03' then land_2 := '03' else
    If '04' in gpid and land_1 <> '04' then land_2 := '04' else
    If '05' in gpid and land_1 <> '05' then land_2 := '05' else
    If '06' in gpid and land_1 <> '06' then land_2 := '06' else
    If '07' in gpid and land_1 <> '07' then land_2 := '07' else
    If '09' in gpid and land_1 <> '09' then land_2 := '09' else
    If '70' in gpid and land_1 <> '70' then land_2 := '70' else
    If '19' in gpid and land_1 <> '19' then land_2 := '19' else

// 2.B.3 PASS 2 DEFAULT
    land_2 := '00';
);

// 2.B.4 PASS 2 FINAL
    land_3 := land_1 & land_2;
);
// 3.A.1 FINAL - PRIMARY
    If land_3 in ['0100','0102','0103','0104','0105','0106','0107','0109','0119'] then pcc_land := 101 else
    If land_3 in ['0200','0203','0204','0205','0206','0207','0209','0219'] then pcc_land := 102 else
    If land_3 in ['0300','0304','0305','0306','0307','0309','0319'] then pcc_land := 103 else
    If land_3 in ['0400','0405','0406','0407','0409','0419'] then pcc_land := 104 else
    If land_3 in ['0500','0506','0507','0509','0519'] then pcc_land := 105 else
    If land_3 in ['0600','0607','0609','0619'] then pcc_land := 106 else
    If land_3 in ['0700','0709','0719'] then pcc_land := 107 else
    If land_3 in ['1001','1002','1003','1004','1005','1006','1007','1009','1000','1018','1019'] then pcc_land := 110 else
    If land_3 in ['0900','0919'] then pcc_land := 209 else
    If land_3 in ['6600'] then pcc_land := 266 else
    If land_3 in ['7000'] then pcc_land := 270 else
    If land_3 in ['1400','1419'] then pcc_land := 314 else
    If land_3 in ['1700','1719'] then pcc_land := 317 else
    If land_3 in ['2219','2200'] then pcc_land := 322 else
    If land_3 in ['1100','1119'] then pcc_land := 411 else
    If land_3 in ['1300','1319'] then pcc_land := 413 else
    If land_3 in ['1600','1619'] then pcc_land := 416 else
    If land_3 in ['2119','2100'] then pcc_land := 421 else
    If land_3 in ['2719','2700'] then pcc_land := 427 else
    If land_3 in ['1200','1218'] then pcc_land := 512 else
    If land_3 in ['1500','1518'] then pcc_land := 515 else
    If land_3 in ['1820','2018','2000','2019'] then pcc_land := 520 else
    If land_3 in ['2619','2600'] then pcc_land := 526 else
    If land_3 in ['8100'] then pcc_land := 681 else
    If land_3 in ['8200'] then pcc_land := 682 else
    If land_3 in ['1800','1819'] then pcc_land := 718 else
    If land_3 in ['1900'] then pcc_land := 719 else
    If land_3 in ['5719','5700'] then pcc_land := 757 else
    If land_3 in ['4519','4500'] then pcc_land := 845 else
    If land_3 in ['6719','6700'] then pcc_land := 867 else
    If land_3 in ['2519','2500'] then pcc_land := 925 else
    If land_3 = 'L' then pcc_land := 999 else

// 3.A.2 FINAL - MIXED USE
    If land_3 in ['1101','1102','1103','1104','1105','1106','1107','1109','1110'] then pcc_land := 111 else
    If land_3 in ['1201','1202','1203','1204','1205','1206','1207','1209','1210'] then pcc_land := 112 else
    If land_3 in ['1301','1302','1303','1304','1305','1306','1307','1309','1310'] then pcc_land := 113 else
    If land_3 in ['1401','1402','1403','1404','1405','1406','1407','1409','1410'] then pcc_land := 114 else
    If land_3 in ['1501','1502','1503','1504','1505','1506','1507','1509','1510'] then pcc_land := 115 else
    If land_3 in ['1601','1602','1603','1604','1605','1606','1607','1609','1610'] then pcc_land := 116 else
    If land_3 in ['1701','1702','1703','1704','1705','1706','1707','1709','1710'] then pcc_land := 117 else
    If land_3 in ['1801','1802','1803','1804','1805','1806','1807','1809','1810'] then pcc_land := 118 else
    If land_3 in ['2001','2002','2003','2004','2005','2006','2007','2009','2010'] then pcc_land := 120 else
    If land_3 in ['2101','2102','2103','2104','2105','2106','2107','2109','2110'] then pcc_land := 121 else
    If land_3 in ['2201','2202','2203','2204','2205','2206','2207','2209','2210'] then pcc_land := 122 else
    If land_3 in ['1211','1213'] then pcc_land := 412 else
    If land_3 in ['1214'] then pcc_land := 312 else
    If land_3 in ['1516'] then pcc_land := 415 else
    If land_3 in ['1517'] then pcc_land := 315 else
    If land_3 in ['2021'] then pcc_land := 420 else
    If land_3 in ['2022'] then pcc_land := 320 else
    If land_3 in ['1118'] then pcc_land := 711 else
    If land_3 in ['1318'] then pcc_land := 713 else
    If land_3 in ['1618'] then pcc_land := 716 else
    If land_3 in ['2118'] then pcc_land := 721 else

// 4 FINAL
    pcc_land := 0;
    pcc_land;
);
// LAND END


// IMP START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
    then imp_3 := 'I'
    else

// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD
(
// 2.A. PASS 1
(
// 2.A.1 PASS 1 IMPROVEMENT - PRIMARY
    If '31' in gpid then imp_1 := '31' else
    If '33' in gpid then imp_1 := '33' else
    If '34' in gpid then imp_1 := '34' else
    If '35' in gpid then imp_1 := '35' else
    If '36' in gpid then imp_1 := '36' else
    If '37' in gpid then imp_1 := '37' else
    If '38' in gpid then imp_1 := '38' else
    If '39' in gpid then imp_1 := '39' else
    If '41' in gpid then imp_1 := '41' else
    If '42' in gpid then imp_1 := '42' else
    If '43' in gpid then imp_1 := '43' else
    If '46' in gpid then imp_1 := '46' else
    If '48' in gpid then imp_1 := '48' else
    If '49' in gpid then imp_1 := '49' else
    If '65' in gpid then imp_1 := '65' else
    If '25' in gpid then imp_1 := '25' else
    If '26' in gpid then imp_1 := '26' else
    If '27' in gpid then imp_1 := '27' else
    If '45' in gpid then imp_1 := '45' else
    If '50' in gpid then imp_1 := '50' else
    If '51' in gpid then imp_1 := '51' else
    If '57' in gpid then imp_1 := '57' else
    If '66' in gpid then imp_1 := '66' else
    If '69' in gpid then imp_1 := '69' else
    If '81' in gpid then imp_1 := '81' else
    If '82' in gpid then imp_1 := '82' else

// 2.A.2 PASS 1 IMPROVEMENT - SECONDARY
    If '30' in gpid then imp_1 := '30' else
    If '32' in gpid then imp_1 := '32' else
    If '40' in gpid then imp_1 := '40' else
    If '47' in gpid then imp_1 := '47' else

// 2.A.3 PASS 1 IMPROVEMENT - DELETE AFTER 2007
//    If '60' in gpid then imp_1 := '60' else
//    If '61' in gpid then imp_1 := '61' else
   If '62' in gpid then imp_1 := '62' else

// 2.A.4 PASS 1 DEFAULT
    imp_1 := '00';
);
// 2.B PASS 2
(
// 2.B.1 PASS 2 IMPROVEMENT - PRIMARY
    If '31' in gpid and imp_1 <> '31' then imp_2 := '31' else
    If '33' in gpid and imp_1 <> '33' then imp_2 := '33' else
    If '34' in gpid and imp_1 <> '34' then imp_2 := '34' else
    If '35' in gpid and imp_1 <> '35' then imp_2 := '35' else
    If '36' in gpid and imp_1 <> '36' then imp_2 := '36' else
    If '37' in gpid and imp_1 <> '37' then imp_2 := '37' else
    If '38' in gpid and imp_1 <> '38' then imp_2 := '38' else
    If '39' in gpid and imp_1 <> '39' then imp_2 := '39' else
    If '41' in gpid and imp_1 <> '41' then imp_2 := '41' else
    If '42' in gpid and imp_1 <> '42' then imp_2 := '42' else
    If '43' in gpid and imp_1 <> '43' then imp_2 := '43' else
    If '46' in gpid and imp_1 <> '46' then imp_2 := '46' else
    If '48' in gpid and imp_1 <> '48' then imp_2 := '48' else
    If '49' in gpid and imp_1 <> '49' then imp_2 := '49' else
    If '65' in gpid and imp_1 <> '65' then imp_2 := '65' else
    If '25' in gpid and imp_1 <> '25' then imp_2 := '25' else
    If '26' in gpid and imp_1 <> '26' then imp_2 := '26' else
    If '27' in gpid and imp_1 <> '27' then imp_2 := '27' else
    If '45' in gpid and imp_1 <> '45' then imp_2 := '45' else
    If '50' in gpid and imp_1 <> '50' then imp_2 := '50' else
    If '51' in gpid and imp_1 <> '51' then imp_2 := '51' else
    If '57' in gpid and imp_1 <> '57' then imp_2 := '57' else
    If '69' in gpid and imp_1 <> '69' then imp_2 := '69' else
    If '81' in gpid and imp_1 <> '81' then imp_2 := '81' else
    If '82' in gpid and imp_1 <> '82' then imp_2 := '82' else

// 2.B.2 PASS 2 IMPROVEMENT - SECONDARY
    If '30' in gpid and imp_1 <> '30' then imp_2 := '30' else
    If '32' in gpid and imp_1 <> '32' then imp_2 := '32' else
    If '40' in gpid and imp_1 <> '40' then imp_2 := '40' else
    If '47' in gpid and imp_1 <> '47' then imp_2 := '47' else

// 2.B.3 PASS 2 DEFAULT
    imp_2 := '00';
);

// 2.C PASS 2 FINAL
    imp_3 := imp_1 + imp_2;
);
// 3.A.1 FINAL - PRIMARY
    If imp_3 in ['3130','3100','3132','3140'] then pcc_imp := 131 else
    If imp_3 in ['6600'] then pcc_imp := 266 else
    If imp_3 in ['3600','3632'] then pcc_imp := 336 else
    If imp_3 in ['3900','3932'] then pcc_imp := 339 else
    If imp_3 in ['4300','4340'] then pcc_imp := 343 else
    If imp_3 in ['2700'] then pcc_imp := 427 else
    If imp_3 in ['3300','3332'] then pcc_imp := 433 else
    If imp_3 in ['3500','3532'] then pcc_imp := 435 else
    If imp_3 in ['3800','3832'] then pcc_imp := 438 else
    If imp_3 in ['4200','4230'] then pcc_imp := 442 else
    If imp_3 in ['5100'] then pcc_imp := 451 else
    If imp_3 in ['2600'] then pcc_imp := 526 else
    If imp_3 in ['3000','3047'] then pcc_imp := 530 else
    If imp_3 in ['3200','3240','3247','3432','3237','3732'] then pcc_imp := 532 else
    If imp_3 in ['3400'] then pcc_imp := 534 else
    If imp_3 in ['3700'] then pcc_imp := 537 else
    If imp_3 in ['3041','4100','4130'] then pcc_imp := 541 else
    If imp_3 in ['4630','4632','4640','4600','4647'] then pcc_imp := 546 else
    If imp_3 in ['4700'] then pcc_imp := 547 else
    If imp_3 in ['4830','4832','4840','4847','4800'] then pcc_imp := 548 else
    If imp_3 in ['4930','4932','4940','4947','4900'] then pcc_imp := 549 else
    If imp_3 in ['5000'] then pcc_imp := 550 else
    If imp_3 in ['5100'] then pcc_imp := 551 else
    If imp_3 in ['6530','6532','6540','6547','6500'] then pcc_imp := 565 else
    If imp_3 in ['8100'] then pcc_imp := 681 else
    If imp_3 in ['8200'] then pcc_imp := 682 else
    If imp_3 in ['4000'] then pcc_imp := 740 else
    If imp_3 in ['4500'] then pcc_imp := 845 else
    If imp_3 in ['5700'] then pcc_imp := 757 else
    If imp_3 in ['6900'] then pcc_imp := 769 else
    If imp_3 in ['6700'] then pcc_imp := 867 else
    If imp_3 in ['2500'] then pcc_imp := 925 else
    If imp_3 = 'I' then pcc_imp := 999 else

// 3.A.2 FINAL - MIXED USE
    If imp_3 = '3133' then pcc_imp := 133 else
    If imp_3 = '3134' then pcc_imp := 134 else
    If imp_3 = '3135' then pcc_imp := 135 else
    If imp_3 = '3136' then pcc_imp := 136 else
    If imp_3 = '3137' then pcc_imp := 137 else
    If imp_3 = '3138' then pcc_imp := 138 else
    If imp_3 = '3139' then pcc_imp := 139 else
    If imp_3 = '3140' then pcc_imp := 140 else
    If imp_3 = '3141' then pcc_imp := 141 else
    If imp_3 = '3142' then pcc_imp := 142 else
    If imp_3 = '3143' then pcc_imp := 143 else
    If imp_3 = '3146' then pcc_imp := 146 else
    If imp_3 = '3148' then pcc_imp := 148 else
    If imp_3 in ['3546','3846','4246'] then pcc_imp := 446 else
    If imp_3 in ['3548','3848','4248'] then pcc_imp := 448 else

    If imp_3 in ['3334','3435'] then pcc_imp := 434 else
    If imp_3 = '3436' then pcc_imp := 334 else
    If imp_3 = '3738' then pcc_imp := 437 else
    If imp_3 = '3739' then pcc_imp := 337 else
    If imp_3 = '4142' then pcc_imp := 441 else
    If imp_3 = '4143' then pcc_imp := 341 else

    If imp_3 in ['3446','3746','4146'] then pcc_imp := 546 else
    If imp_3 in ['3448','3748','4148'] then pcc_imp := 548 else

// 3.A.3 FINAL - DELETE AFTER 2007
//    If imp_3 = '6000' then pcc_imp := 960 else
//   If imp_3 = '6100' then pcc_imp := 961 else
    If imp_3 = '6200' then pcc_imp := 962 else


// 4 FINAL
    pcc_imp := 0;
    pcc_imp;
);
// IMP END


// GRM START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
then 
(
// 1.A. IF GRM COUNTY USE GRM SYSTYPE FOR PCC_STD
//    If '102500'  in gpid then grm_1 := 100 else     // 100- Agricultural Vac                                           
//    If '102501'  in gpid then grm_1 := 101 else     // 101- Irrigated Crop Land                                        
//    If '102502'  in gpid then grm_1 := 102 else     // 102- Irrigated Grazing Land                                     
//    If '102503'  in gpid then grm_1 := 103 else     // 103- Non-irrigated Crop Land                                    
//    If '102504'  in gpid then grm_1 := 104 else     // 104- Meadow Land                                                
//    If '102505'  in gpid then grm_1 := 105 else     // 105- Dry Grazing                                                
//    If '102506'  in gpid then grm_1 := 106 else     // 106- Productivity Forest Land                                   
//    If '102507'  in gpid then grm_1 := 107 else     // 107- Bare Forest Land                                           
//    If '102508'  in gpid then grm_1 := 108 else     // 108- Speculative Homesite                                       
//    If '102509'  in gpid then grm_1 := 109 else     // 109- Agri greenhouses                                           
//    If '102510'  in gpid then grm_1 := 110 else     // 110- Agri Homesite Land                                         
//    If '102511'  in gpid then grm_1 := 111 else     // 111
//    If '102512'  in gpid then grm_1 := 112 else     // 112
//    If '102513'  in gpid then grm_1 := 113 else     // 113
//    If '102514'  in gpid then grm_1 := 114 else     // 114
//    If '102515'  in gpid then grm_1 := 115 else     // 115
//    If '102516'  in gpid then grm_1 := 116 else     // 116
//    If '102517'  in gpid then grm_1 := 117 else     // 117
//    If '102518'  in gpid then grm_1 := 118 else     // 118- Other Rural Land                                           
//    If '102519'  in gpid then grm_1 := 119 else     // 119 - Waste                                                     
//    If '102520'  in gpid then grm_1 := 120 else     // 120- Agri timber                                                
//    If '102521'  in gpid then grm_1 := 121 else     // 121
//    If '102522'  in gpid then grm_1 := 122 else     // 122
//    If '102523'  in gpid then grm_1 := 123 else     // 123
//    If '102524'  in gpid then grm_1 := 124 else     // 124
//    If '102525'  in gpid then grm_1 := 125 else     // 125
//    If '102526'  in gpid then grm_1 := 126 else     // 126
//    If '102527'  in gpid then grm_1 := 127 else     // 127
//    If '102528'  in gpid then grm_1 := 128 else     // 128
//    If '102529'  in gpid then grm_1 := 129 else     // 129
//    If '102530'  in gpid then grm_1 := 130 else     // 130
//    If '102531'  in gpid then grm_1 := 131 else     // Residential Improv on Cat 10                                    
//    If '102532'  in gpid then grm_1 := 132 else     // Non-Residential Improv Cat 10                                   
//    If '102533'  in gpid then grm_1 := 133 else     // 133
//    If '102534'  in gpid then grm_1 := 134 else     // 134
//    If '102535'  in gpid then grm_1 := 135 else     // 135
//    If '102536'  in gpid then grm_1 := 136 else     // 136
//    If '102537'  in gpid then grm_1 := 137 else     // 137
//    If '102538'  in gpid then grm_1 := 138 else     // 138
//    If '102539'  in gpid then grm_1 := 139 else     // 139
//    If '102540'  in gpid then grm_1 := 140 else     // 140
//    If '102541'  in gpid then grm_1 := 141 else     // 141
//    If '102542'  in gpid then grm_1 := 142 else     // 142
//    If '102543'  in gpid then grm_1 := 143 else     // 143
//    If '102544'  in gpid then grm_1 := 144 else     // 144
//    If '102545'  in gpid then grm_1 := 145 else     // 145
//    If '102546'  in gpid then grm_1 := 146 else     // 146
//    If '102547'  in gpid then grm_1 := 147 else     // 147
//    If '102548'  in gpid then grm_1 := 148 else     // MH Real Cat 10                                                  
//    If '102549'  in gpid then grm_1 := 149 else     // 149
//    If '102550'  in gpid then grm_1 := 150 else     // 150
//    If '102551'  in gpid then grm_1 := 151 else     // 151
//    If '102552'  in gpid then grm_1 := 152 else     // 152
//    If '102553'  in gpid then grm_1 := 153 else     // 153
//    If '102554'  in gpid then grm_1 := 154 else     // 154
//    If '102555'  in gpid then grm_1 := 155 else     // 155
//    If '102556'  in gpid then grm_1 := 156 else     // 156
//    If '102557'  in gpid then grm_1 := 157 else     // 157-Equities in State Land                                      
//    If '102558'  in gpid then grm_1 := 158 else     // 158
//    If '102559'  in gpid then grm_1 := 159 else     // 159
//    If '102560'  in gpid then grm_1 := 160 else     // 160
//    If '102561'  in gpid then grm_1 := 161 else     // 161- Ag Imp/Leased Land                                         
//    If '102562'  in gpid then grm_1 := 162 else     // 162
//    If '102563'  in gpid then grm_1 := 163 else     // 163
//    If '102564'  in gpid then grm_1 := 164 else     // 164
//    If '102565'  in gpid then grm_1 := 165 else     // 165
//    If '102566'  in gpid then grm_1 := 166 else     // 166
//    If '102567'  in gpid then grm_1 := 167 else     // 167
//    If '102568'  in gpid then grm_1 := 168 else     // 168
//    If '102569'  in gpid then grm_1 := 169 else     // 169
//    If '102570'  in gpid then grm_1 := 170 else     // 170
//    If '102571'  in gpid then grm_1 := 171 else     // 171
//    If '102572'  in gpid then grm_1 := 172 else     // 172
//    If '102573'  in gpid then grm_1 := 173 else     // 173
//    If '102574'  in gpid then grm_1 := 174 else     // 174
//    If '102575'  in gpid then grm_1 := 175 else     // 175
//    If '102576'  in gpid then grm_1 := 176 else     // 176
//    If '102577'  in gpid then grm_1 := 177 else     // 177
//    If '102578'  in gpid then grm_1 := 178 else     // 178
//    If '102579'  in gpid then grm_1 := 179 else     // 179
//    If '102580'  in gpid then grm_1 := 180 else     // 180
//    If '102581'  in gpid then grm_1 := 181 else     // 181- Ag (not classified)                                        
//    If '102582'  in gpid then grm_1 := 182 else     // 182- Ag related activities                                      
//    If '102583'  in gpid then grm_1 := 183 else     // 183- Ag classified in O.S.                                      
//    If '102584'  in gpid then grm_1 := 184 else     // 184
//    If '102585'  in gpid then grm_1 := 185 else     // 185
//    If '102586'  in gpid then grm_1 := 186 else     // 186
//    If '102587'  in gpid then grm_1 := 187 else     // 187
//    If '102588'  in gpid then grm_1 := 188 else     // 188
//    If '102589'  in gpid then grm_1 := 189 else     // 189
//    If '102590'  in gpid then grm_1 := 190 else     // 190
//    If '102591'  in gpid then grm_1 := 191 else     // 191- Undetermined                                               
//    If '102592'  in gpid then grm_1 := 192 else     // 192
//    If '102593'  in gpid then grm_1 := 193 else     // 193
//    If '102594'  in gpid then grm_1 := 194 else     // 194- Open space                                                 
//    If '102595'  in gpid then grm_1 := 195 else     // 195
//    If '102596'  in gpid then grm_1 := 196 else     // 196
//    If '102597'  in gpid then grm_1 := 197 else     // 197
//    If '102598'  in gpid then grm_1 := 198 else     // 198
//    If '102599'  in gpid then grm_1 := 199 else     // 199-Other undeveloped land                                      
//    If '102600'  in gpid then grm_1 := 200 else     // 200- Mineral                                                    
//    If '102601'  in gpid then grm_1 := 201 else     // 201
//    If '102602'  in gpid then grm_1 := 202 else     // 202
//    If '102603'  in gpid then grm_1 := 203 else     // 203
//    If '102604'  in gpid then grm_1 := 204 else     // 204
//    If '102605'  in gpid then grm_1 := 205 else     // 205
//    If '102606'  in gpid then grm_1 := 206 else     // 206
//    If '102607'  in gpid then grm_1 := 207 else     // 207
//    If '102608'  in gpid then grm_1 := 208 else     // 208
//    If '102609'  in gpid then grm_1 := 209 else     // 209- Mineral land                                               
//    If '102610'  in gpid then grm_1 := 210 else     // 210
//    If '102611'  in gpid then grm_1 := 211 else     // 211
//    If '102612'  in gpid then grm_1 := 212 else     // 212
//    If '102613'  in gpid then grm_1 := 213 else     // 213
//    If '102614'  in gpid then grm_1 := 214 else     // 214
//    If '102615'  in gpid then grm_1 := 215 else     // 215
//    If '102616'  in gpid then grm_1 := 216 else     // 216
//    If '102617'  in gpid then grm_1 := 217 else     // 217
//    If '102618'  in gpid then grm_1 := 218 else     // 218
//    If '102619'  in gpid then grm_1 := 219 else     // 219
//    If '102620'  in gpid then grm_1 := 220 else     // 220
//    If '102621'  in gpid then grm_1 := 221 else     // 221
//    If '102622'  in gpid then grm_1 := 222 else     // 222
//    If '102623'  in gpid then grm_1 := 223 else     // 223
//    If '102624'  in gpid then grm_1 := 224 else     // 224
//    If '102625'  in gpid then grm_1 := 225 else     // 225
//    If '102626'  in gpid then grm_1 := 226 else     // 226
//    If '102627'  in gpid then grm_1 := 227 else     // 227
//    If '102628'  in gpid then grm_1 := 228 else     // 228
//    If '102629'  in gpid then grm_1 := 229 else     // 229
//    If '102630'  in gpid then grm_1 := 230 else     // 230
//    If '102631'  in gpid then grm_1 := 231 else     // 231
//    If '102632'  in gpid then grm_1 := 232 else     // 232
//    If '102633'  in gpid then grm_1 := 233 else     // 233
//    If '102634'  in gpid then grm_1 := 234 else     // 234
//    If '102635'  in gpid then grm_1 := 235 else     // 235
//    If '102636'  in gpid then grm_1 := 236 else     // 236
//    If '102637'  in gpid then grm_1 := 237 else     // 237
//    If '102638'  in gpid then grm_1 := 238 else     // 238
//    If '102639'  in gpid then grm_1 := 239 else     // 239
//    If '102640'  in gpid then grm_1 := 240 else     // 240
//    If '102641'  in gpid then grm_1 := 241 else     // 241
//    If '102642'  in gpid then grm_1 := 242 else     // 242
//    If '102643'  in gpid then grm_1 := 243 else     // 243
//    If '102644'  in gpid then grm_1 := 244 else     // 244
//    If '102645'  in gpid then grm_1 := 245 else     // 245
//    If '102646'  in gpid then grm_1 := 246 else     // 246
//    If '102647'  in gpid then grm_1 := 247 else     // 247
//    If '102648'  in gpid then grm_1 := 248 else     // 248
//    If '102649'  in gpid then grm_1 := 249 else     // 249
//    If '102650'  in gpid then grm_1 := 250 else     // 250
//    If '102651'  in gpid then grm_1 := 251 else     // 251
//    If '102652'  in gpid then grm_1 := 252 else     // 252
//    If '102653'  in gpid then grm_1 := 253 else     // 253
//    If '102654'  in gpid then grm_1 := 254 else     // 254
//    If '102655'  in gpid then grm_1 := 255 else     // 255
//    If '102656'  in gpid then grm_1 := 256 else     // 256
//    If '102657'  in gpid then grm_1 := 257 else     // 257
//    If '102658'  in gpid then grm_1 := 258 else     // 258
//    If '102659'  in gpid then grm_1 := 259 else     // 259
//    If '102660'  in gpid then grm_1 := 260 else     // 260
//    If '102661'  in gpid then grm_1 := 261 else     // 261
//    If '102662'  in gpid then grm_1 := 262 else     // 262
//    If '102663'  in gpid then grm_1 := 263 else     // 263
//    If '102664'  in gpid then grm_1 := 264 else     // 264
//    If '102665'  in gpid then grm_1 := 265 else     // 265
//    If '102673'  in gpid then grm_1 := 270 else     // 270- Mineral Rights                                             
//    If '1300000'  in gpid then grm_1 := 272 else     // 272
//    If '1304130'  in gpid then grm_1 := 273 else     // 273
//    If '1306099'  in gpid then grm_1 := 274 else     // 274
//    If '1306100'  in gpid then grm_1 := 275 else     // 275
//    If '1306101'  in gpid then grm_1 := 276 else     // 276
//    If '1306102'  in gpid then grm_1 := 277 else     // 277
//    If '1306103'  in gpid then grm_1 := 278 else     // 278
//    If '1306104'  in gpid then grm_1 := 279 else     // 279
//    If '1306105'  in gpid then grm_1 := 280 else     // 280
//    If '1306106'  in gpid then grm_1 := 281 else     // 281
//    If '1306107'  in gpid then grm_1 := 282 else     // 282
//    If '1306108'  in gpid then grm_1 := 283 else     // 283
//    If '1306109'  in gpid then grm_1 := 284 else     // 284
//    If '1306110'  in gpid then grm_1 := 285 else     // 285- Mining related-gravel                                      
//    If '1306111'  in gpid then grm_1 := 286 else     // 286
//    If '1306112'  in gpid then grm_1 := 287 else     // 287
//    If '1306113'  in gpid then grm_1 := 288 else     // 288
//    If '1306114'  in gpid then grm_1 := 289 else     // 289
//    If '1306115'  in gpid then grm_1 := 290 else     // 290
//    If '1306116'  in gpid then grm_1 := 291 else     // 291
//    If '1306117'  in gpid then grm_1 := 292 else     // 292
//    If '1306118'  in gpid then grm_1 := 293 else     // 293
//    If '1306119'  in gpid then grm_1 := 294 else     // 294
//    If '1306120'  in gpid then grm_1 := 295 else     // 295
//    If '1306121'  in gpid then grm_1 := 296 else     // 296
//    If '1306122'  in gpid then grm_1 := 297 else     // 297
//    If '1306123'  in gpid then grm_1 := 298 else     // 298
//    If '1306124'  in gpid then grm_1 := 299 else     // 299
//    If '1306125'  in gpid then grm_1 := 300 else     // 300- Industrial Vac land                                        
//    If '1306126'  in gpid then grm_1 := 301 else     // 301- Industrial general class                                   
//    If '1306127'  in gpid then grm_1 := 302 else     // 302
//    If '1306128'  in gpid then grm_1 := 303 else     // 303
//    If '1306129'  in gpid then grm_1 := 304 else     // 304
//    If '1306130'  in gpid then grm_1 := 305 else     // 305
//    If '1306131'  in gpid then grm_1 := 306 else     // 306
//    If '1306132'  in gpid then grm_1 := 307 else     // 307
//    If '1306133'  in gpid then grm_1 := 308 else     // 308
//    If '1306134'  in gpid then grm_1 := 309 else     // 309
//    If '1306135'  in gpid then grm_1 := 310 else     // 310- Industrial Food - drink                                    
//    If '1306136'  in gpid then grm_1 := 311 else     // 314- Rural indust land tract                                    
//    If '1306137'  in gpid then grm_1 := 312 else     // 312
//    If '1306138'  in gpid then grm_1 := 313 else     // 313
//    If '1306139'  in gpid then grm_1 := 314 else     // 314- Rural indust land tract                                    
//    If '1306140'  in gpid then grm_1 := 315 else     // 315
//    If '1306141'  in gpid then grm_1 := 316 else     // 316
//    If '1306142'  in gpid then grm_1 := 317 else     // 317- Rural indust subdivision                                   
//    If '1306143'  in gpid then grm_1 := 318 else     // 318
//    If '1306144'  in gpid then grm_1 := 319 else     // 319
//    If '1306145'  in gpid then grm_1 := 320 else     // 320 Ind foundries/hvy mfg                                       
//    If '1306146'  in gpid then grm_1 := 321 else     // 321- Food & kindred products                                    
//    If '1306147'  in gpid then grm_1 := 322 else     // 322- Indust City tract/lot                                      
//    If '1306148'  in gpid then grm_1 := 323 else     // 323- Apparel & fin. prdcts                                      
//    If '1306149'  in gpid then grm_1 := 324 else     // 324
//    If '1306150'  in gpid then grm_1 := 325 else     // 325
//    If '1306151'  in gpid then grm_1 := 326 else     // 3- Paper and allied products                                    
//    If '1306152'  in gpid then grm_1 := 327 else     // 3- Printing and publishing                                      
//    If '1306153'  in gpid then grm_1 := 328 else     // 3- Chemicals                                                    
//    If '1306154'  in gpid then grm_1 := 329 else     // 3- Petroleum refining & rel                                     
//    If '1306155'  in gpid then grm_1 := 330 else     // Ind med mfg & assembly                                          
//    If '1306156'  in gpid then grm_1 := 331 else     // 3- Rubber/misc plastic prod                                     
//    If '1306157'  in gpid then grm_1 := 332 else     // 3- Stone                                                        
//    If '1306158'  in gpid then grm_1 := 333 else     // 3- Primary metal industries                                     
//    If '1306159'  in gpid then grm_1 := 334 else     // 3- Fabricated metal products                                    
//    If '1306160'  in gpid then grm_1 := 335 else     // 3- Prof. scientific                                             
//    If '1306161'  in gpid then grm_1 := 336 else     // 336
//    If '1306162'  in gpid then grm_1 := 337 else     // 337
//    If '1306163'  in gpid then grm_1 := 338 else     // 338
//    If '1306164'  in gpid then grm_1 := 339 else     // 3- Misc manufacturing                                           
//    If '1306165'  in gpid then grm_1 := 340 else     // Industrial lt mfg & assembly                                    
//    If '1306166'  in gpid then grm_1 := 341 else     // 341
//    If '1306167'  in gpid then grm_1 := 342 else     // 342
//    If '1306168'  in gpid then grm_1 := 343 else     // 343
//    If '1306169'  in gpid then grm_1 := 344 else     // 344
//    If '1306170'  in gpid then grm_1 := 345 else     // 345
//    If '1306171'  in gpid then grm_1 := 346 else     // 346
//    If '1306172'  in gpid then grm_1 := 347 else     // 347
//    If '1306173'  in gpid then grm_1 := 348 else     // 348
//    If '1306174'  in gpid then grm_1 := 349 else     // 349
//    If '1306175'  in gpid then grm_1 := 350 else     // Industrial warehouse                                            
//    If '1306176'  in gpid then grm_1 := 351 else     // 351
//    If '1306177'  in gpid then grm_1 := 352 else     // 352
//    If '1306178'  in gpid then grm_1 := 353 else     // 353
//    If '1306179'  in gpid then grm_1 := 354 else     // 354
//    If '1306180'  in gpid then grm_1 := 355 else     // 355
//    If '1306181'  in gpid then grm_1 := 356 else     // 356
//    If '1306182'  in gpid then grm_1 := 357 else     // 357
//    If '1306183'  in gpid then grm_1 := 358 else     // 358
//    If '1306184'  in gpid then grm_1 := 359 else     // 359
//    If '1306185'  in gpid then grm_1 := 360 else     // 360-Ind Bldg on RR r/w                                          
//    If '1306186'  in gpid then grm_1 := 361 else     // 361
//    If '1306187'  in gpid then grm_1 := 362 else     // 362
//    If '1306188'  in gpid then grm_1 := 363 else     // 363
//    If '1306189'  in gpid then grm_1 := 364 else     // 364
//    If '1306190'  in gpid then grm_1 := 365 else     // 365
//    If '1306191'  in gpid then grm_1 := 366 else     // 366
//    If '1306192'  in gpid then grm_1 := 367 else     // 367
//    If '1306193'  in gpid then grm_1 := 368 else     // 368
//    If '1306194'  in gpid then grm_1 := 369 else     // 369
//    If '1306195'  in gpid then grm_1 := 370 else     // Industrial small shops                                          
//    If '1306196'  in gpid then grm_1 := 371 else     // 371
//    If '1306197'  in gpid then grm_1 := 372 else     // 372
//    If '1306198'  in gpid then grm_1 := 373 else     // 373
//    If '1306199'  in gpid then grm_1 := 374 else     // 374
//    If '1306200'  in gpid then grm_1 := 375 else     // 375
//    If '1306201'  in gpid then grm_1 := 376 else     // 376
//    If '1306202'  in gpid then grm_1 := 377 else     // 377
//    If '1306203'  in gpid then grm_1 := 378 else     // 378
//    If '1306204'  in gpid then grm_1 := 379 else     // 379
//    If '1306205'  in gpid then grm_1 := 380 else     // Industrial mines & quarries                                     
//    If '1306206'  in gpid then grm_1 := 381 else     // 381
//    If '1306207'  in gpid then grm_1 := 382 else     // 382
//    If '1306208'  in gpid then grm_1 := 383 else     // 383
//    If '1306209'  in gpid then grm_1 := 384 else     // 384
//    If '1306210'  in gpid then grm_1 := 385 else     // 385
//    If '1306211'  in gpid then grm_1 := 386 else     // 386
//    If '1306212'  in gpid then grm_1 := 387 else     // 387
//    If '1306213'  in gpid then grm_1 := 388 else     // 388
//    If '1306214'  in gpid then grm_1 := 389 else     // 389
//    If '1306215'  in gpid then grm_1 := 390 else     // Industrial grain elevators                                      
//    If '1306216'  in gpid then grm_1 := 391 else     // 3- Undeveloped land                                             
//    If '1306217'  in gpid then grm_1 := 392 else     // 392
//    If '1306218'  in gpid then grm_1 := 393 else     // 393
//    If '1306219'  in gpid then grm_1 := 394 else     // 394
//    If '1306220'  in gpid then grm_1 := 395 else     // 395
//    If '1306221'  in gpid then grm_1 := 396 else     // 396
//    If '1306222'  in gpid then grm_1 := 397 else     // 397
//    If '1306223'  in gpid then grm_1 := 398 else     // 398
//    If '1306224'  in gpid then grm_1 := 399 else     // Indust other structures                                         
//    If '1306225'  in gpid then grm_1 := 400 else     // Commercial vacant land                                          
//    If '1306226'  in gpid then grm_1 := 401 else     // Commercial general class                                        
//    If '1306227'  in gpid then grm_1 := 402 else     // Commercially classified apts                                    
//    If '1306228'  in gpid then grm_1 := 403 else     // Commercial 40+ family apts                                      
//    If '1306229'  in gpid then grm_1 := 404 else     // Commercial/Industrial Class                                     
//    If '1306230'  in gpid then grm_1 := 405 else     // 405
//    If '1306231'  in gpid then grm_1 := 406 else     // 406
//    If '1306232'  in gpid then grm_1 := 407 else     // 407
//    If '1306233'  in gpid then grm_1 := 408 else     // 408
//    If '1306234'  in gpid then grm_1 := 409 else     // 409
//    If '1306235'  in gpid then grm_1 := 410 else     // Com Motels                                                      
//    If '1306236'  in gpid then grm_1 := 411 else     // 411- Recreational                                               
//    If '1306237'  in gpid then grm_1 := 412 else     // Com Hospitals/Nurs hms                                          
//    If '1306238'  in gpid then grm_1 := 413 else     // 413- Rural commercial tracts                                    
//    If '1306239'  in gpid then grm_1 := 414 else     // 4- Res. Hotels-Condos                                           
//    If '1306240'  in gpid then grm_1 := 415 else     // 415- Mobile home parks                                          
//    If '1306241'  in gpid then grm_1 := 416 else     // 416- Rural commercial subdiv                                    
//    If '1306242'  in gpid then grm_1 := 417 else     // 417
//    If '1306243'  in gpid then grm_1 := 418 else     // 418
//    If '1306244'  in gpid then grm_1 := 419 else     // Com Other housing                                               
//    If '1306245'  in gpid then grm_1 := 420 else     // Com Small retail                                                
//    If '1306246'  in gpid then grm_1 := 421 else     // 421- Commercial lot/ac in city                                  
//    If '1306247'  in gpid then grm_1 := 422 else     // Com Discount department store                                   
//    If '1306248'  in gpid then grm_1 := 423 else     // 423
//    If '1306249'  in gpid then grm_1 := 424 else     // Com Full line dept store                                        
//    If '1306250'  in gpid then grm_1 := 425 else     // 425- Commercial Common Area                                     
//    If '1306251'  in gpid then grm_1 := 426 else     // 426- Commercial Condo                                           
//    If '1306252'  in gpid then grm_1 := 427 else     // 427-                                                            
//    If '1306253'  in gpid then grm_1 := 428 else     // 428
//    If '1306254'  in gpid then grm_1 := 429 else     // Com Other retail buildings                                      
//    If '1306255'  in gpid then grm_1 := 430 else     // Com Restaurant/bar                                              
//    If '1306256'  in gpid then grm_1 := 431 else     // 431
//    If '1306257'  in gpid then grm_1 := 432 else     // 432
//    If '1306258'  in gpid then grm_1 := 433 else     // 433
//    If '1306259'  in gpid then grm_1 := 434 else     // 434
//    If '1306260'  in gpid then grm_1 := 435 else     // Com DriveIn restaurant                                          
//    If '1306261'  in gpid then grm_1 := 436 else     // 436
//    If '1306262'  in gpid then grm_1 := 437 else     // 437
//    If '1306263'  in gpid then grm_1 := 438 else     // 438
//    If '1306264'  in gpid then grm_1 := 439 else     // Com Other food service                                          
//    If '1306265'  in gpid then grm_1 := 440 else     // Com Dry clean/laundry                                           
//    If '1306266'  in gpid then grm_1 := 441 else     // Com Funeral home                                                
//    If '1306267'  in gpid then grm_1 := 442 else     // Com Medical clinic/offices                                      
//    If '1306268'  in gpid then grm_1 := 443 else     // 443
//    If '1306269'  in gpid then grm_1 := 444 else     // Com Full service banks                                          
//    If '1306270'  in gpid then grm_1 := 445 else     // Com Savings and loans                                           
//    If '1306271'  in gpid then grm_1 := 446 else     // 446
//    If '1306272'  in gpid then grm_1 := 447 else     // Com 1 and 2 story off bldgs                                     
//    If '1306273'  in gpid then grm_1 := 448 else     // Com Office O/T 47 walkup                                        
//    If '1306274'  in gpid then grm_1 := 449 else     // Com Office O/T 47 elev                                          
//    If '1306275'  in gpid then grm_1 := 450 else     // 450
//    If '1306276'  in gpid then grm_1 := 451 else     // 4- Wholesale trade                                              
//    If '1306277'  in gpid then grm_1 := 452 else     // 4- RT--bldg matrl                                               
//    If '1306278'  in gpid then grm_1 := 453 else     // 4- RT general merchandise                                       
//    If '1306279'  in gpid then grm_1 := 454 else     // 4- RT food                                                      
//    If '1306280'  in gpid then grm_1 := 455 else     // 4- RT auto                                                      
//    If '1306281'  in gpid then grm_1 := 456 else     // 4- RT apparel and accessories                                   
//    If '1306282'  in gpid then grm_1 := 457 else     // 4- RT furniture                                                 
//    If '1306283'  in gpid then grm_1 := 458 else     // 4- RT eating and drinking                                       
//    If '1306284'  in gpid then grm_1 := 459 else     // 4- Other retail trade                                           
//    If '1306285'  in gpid then grm_1 := 460 else     // 460-Comm Imps/Railroad R/W                                      
//    If '1306286'  in gpid then grm_1 := 461 else     // 461-Comm imps/leased land                                       
//    If '1306287'  in gpid then grm_1 := 462 else     // 462-Comm imps/exempt land                                       
//    If '1306288'  in gpid then grm_1 := 463 else     // 4- Business services                                            
//    If '1306289'  in gpid then grm_1 := 464 else     // 4- Repair services                                              
//    If '1306290'  in gpid then grm_1 := 465 else     // 4- Professional services                                        
//    If '1306291'  in gpid then grm_1 := 466 else     // 4- Contract constrctn svcs                                      
//    If '1306292'  in gpid then grm_1 := 467 else     // 4- Governmental services                                        
//    If '1306293'  in gpid then grm_1 := 468 else     // 4- Educational services                                         
//    If '1306294'  in gpid then grm_1 := 469 else     // 4- Miscellaneous services                                       
//    If '1306295'  in gpid then grm_1 := 470 else     // 470
//    If '1306296'  in gpid then grm_1 := 471 else     // 471
//    If '1306297'  in gpid then grm_1 := 472 else     // 4- Public assembly                                              
//    If '1306298'  in gpid then grm_1 := 473 else     // 4- Amusements                                                   
//    If '1306299'  in gpid then grm_1 := 474 else     // 4- Recreational activities                                      
//    If '1306300'  in gpid then grm_1 := 475 else     // 4- Resorts & group camps                                        
//    If '1306301'  in gpid then grm_1 := 476 else     // 4- Parks                                                        
//    If '1306302'  in gpid then grm_1 := 477 else     // 477
//    If '1306303'  in gpid then grm_1 := 478 else     // 478
//    If '1306304'  in gpid then grm_1 := 479 else     // 4- Other cult                                                   
//    If '1306305'  in gpid then grm_1 := 480 else     // Com Warehouse                                                   
//    If '1306306'  in gpid then grm_1 := 481 else     // 481
//    If '1306307'  in gpid then grm_1 := 482 else     // Com Truck terminals                                             
//    If '1306308'  in gpid then grm_1 := 483 else     // 483
//    If '1306309'  in gpid then grm_1 := 484 else     // 484
//    If '1306310'  in gpid then grm_1 := 485 else     // 485
//    If '1306311'  in gpid then grm_1 := 486 else     // 486
//    If '1306312'  in gpid then grm_1 := 487 else     // 487
//    If '1306313'  in gpid then grm_1 := 488 else     // 488
//    If '1306314'  in gpid then grm_1 := 489 else     // 489
//    If '1306315'  in gpid then grm_1 := 490 else     // Com Marine service facility                                     
//    If '1306316'  in gpid then grm_1 := 491 else     // 4- Undeveloped land                                             
//    If '1306317'  in gpid then grm_1 := 492 else     // 492
//    If '1306318'  in gpid then grm_1 := 493 else     // 493
//    If '1306319'  in gpid then grm_1 := 494 else     // 4- Open space                                                   
//    If '1306320'  in gpid then grm_1 := 495 else     // 495
//    If '1306321'  in gpid then grm_1 := 496 else     // Com Marina                                                      
//    If '1306322'  in gpid then grm_1 := 497 else     // 497
//    If '1306323'  in gpid then grm_1 := 498 else     // 498
//    If '1306324'  in gpid then grm_1 := 499 else     // 499- Commercial other                                           
//    If '1306325'  in gpid then grm_1 := 500 else     // Residential: Vacant lot                                         
//    If '1306326'  in gpid then grm_1 := 501 else     // Res Urban 1 family                                              
//    If '1306327'  in gpid then grm_1 := 502 else     // Res Suburban 1 fam to 19.99ac                                   
//    If '1306328'  in gpid then grm_1 := 503 else     // Res Multi-family                                                
//    If '1306329'  in gpid then grm_1 := 504 else     // Res vac unplatted 30-39.9ac                                     
//    If '1306330'  in gpid then grm_1 := 505 else     // Res vac unplatted 20+Ac                                         
//    If '1306331'  in gpid then grm_1 := 506 else     // 506
//    If '1306332'  in gpid then grm_1 := 507 else     // 507
//    If '1306333'  in gpid then grm_1 := 508 else     // 508
//    If '1306334'  in gpid then grm_1 := 509 else     // 509
//    If '1306335'  in gpid then grm_1 := 510 else     // 510- Homesite non-agriculture                                   
//    If '1306336'  in gpid then grm_1 := 511 else     // 5- Household                                                    
//    If '1306337'  in gpid then grm_1 := 512 else     // 512- Rural residential tracts                                   
//    If '1306338'  in gpid then grm_1 := 513 else     // Res 1 fam unplatted 20-29.99a                                   
//    If '1306339'  in gpid then grm_1 := 514 else     // Res 1 fam unplatted 30-39.99a                                   
//    If '1306340'  in gpid then grm_1 := 515 else     // 515- Rural resid subdivisions                                   
//    If '1306341'  in gpid then grm_1 := 516 else     // 516
//    If '1306342'  in gpid then grm_1 := 517 else     // 517
//    If '1306343'  in gpid then grm_1 := 518 else     // 518- Other Rual Land Improved                                   
//    If '1306344'  in gpid then grm_1 := 519 else     // 5- Vacation and cabin                                           
//    If '1306345'  in gpid then grm_1 := 520 else     // 520- Resid lots/tracts in city                                  
//    If '1306346'  in gpid then grm_1 := 521 else     // Res 2 fam unplatted 0-9.99 ac                                   
//    If '1306347'  in gpid then grm_1 := 522 else     // Res 2 fam unplatted 10-19.99a                                   
//    If '1306348'  in gpid then grm_1 := 523 else     // Res 2 fam unplatted 20-29.99a                                   
//    If '1306349'  in gpid then grm_1 := 524 else     // Res 2 fam unplatted 30-39.99a                                   
//    If '1306350'  in gpid then grm_1 := 525 else     // 525- Common areas- condo/tnhse                                  
//    If '1306351'  in gpid then grm_1 := 526 else     // 526 - Condominium                                               
//    If '1306352'  in gpid then grm_1 := 527 else     // 527
//    If '1306353'  in gpid then grm_1 := 528 else     // 528
//    If '1306354'  in gpid then grm_1 := 529 else     // 529
//    If '1306355'  in gpid then grm_1 := 530 else     // Res 3 family dwelling                                           
//    If '1306356'  in gpid then grm_1 := 531 else     // Res 3 fam unplatted 0-9.99 ac                                   
//    If '1306357'  in gpid then grm_1 := 532 else     // Res 3 fam unplatted 10-19.99a                                   
//    If '1306358'  in gpid then grm_1 := 533 else     // Res 3 fam unplatted 20-29.99a                                   
//    If '1306359'  in gpid then grm_1 := 534 else     // Res 3 fam unplatted 30-39.99a                                   
//    If '1306360'  in gpid then grm_1 := 535 else     // Res 3 fam unplatted 40+ ac                                      
//    If '1306361'  in gpid then grm_1 := 536 else     // 536
//    If '1306362'  in gpid then grm_1 := 537 else     // 537
//    If '1306363'  in gpid then grm_1 := 538 else     // 538
//    If '1306364'  in gpid then grm_1 := 539 else     // 539
//    If '1306365'  in gpid then grm_1 := 540 else     // 540- Other Rural Land Improved                                  
//    If '1306366'  in gpid then grm_1 := 541 else     // Res mobile home on 0-9.99 ac                                    
//    If '1306367'  in gpid then grm_1 := 542 else     // Res mobile home on 10-19.99 a                                   
//    If '1306368'  in gpid then grm_1 := 543 else     // Res Trailer unplat 10-19.99 a                                   
//    If '1306369'  in gpid then grm_1 := 544 else     // Res Trailer unplat 30-39.99 a                                   
//    If '1306370'  in gpid then grm_1 := 545 else     // Res Trailer unplatted 40+ ac                                    
//    If '1306371'  in gpid then grm_1 := 546 else     // 546 - Manuf housing                                             
//    If '1306372'  in gpid then grm_1 := 547 else     // 547
//    If '1306373'  in gpid then grm_1 := 548 else     // 548- M H on Real Property                                       
//    If '1306374'  in gpid then grm_1 := 549 else     // 549- M H on Leased Land                                         
//    If '1306375'  in gpid then grm_1 := 550 else     // Res condominium                                                 
//    If '1306376'  in gpid then grm_1 := 551 else     // Res Condo unplatted 0-9.99 ac                                   
//    If '1306377'  in gpid then grm_1 := 552 else     // Res Condo unplatted 10-19.99a                                   
//    If '1306378'  in gpid then grm_1 := 553 else     // Res Condo unplatted 20-29.99a                                   
//    If '1306379'  in gpid then grm_1 := 554 else     // Res Condo unplatted 30-39.99a                                   
//    If '1306380'  in gpid then grm_1 := 555 else     // Res Condo unplatted 40+ ac                                      
//    If '1306381'  in gpid then grm_1 := 556 else     // 556
//    If '1306382'  in gpid then grm_1 := 557 else     // 557
//    If '1306383'  in gpid then grm_1 := 558 else     // 558
//    If '1306384'  in gpid then grm_1 := 559 else     // 559
//    If '1306385'  in gpid then grm_1 := 560 else     // 560
//    If '1306386'  in gpid then grm_1 := 561 else     // 561-Res imps/leased land                                        
//    If '1306387'  in gpid then grm_1 := 562 else     // 562-Res imps/exempt land                                        
//    If '1306388'  in gpid then grm_1 := 563 else     // 563
//    If '1306389'  in gpid then grm_1 := 564 else     // 564
//    If '1306390'  in gpid then grm_1 := 565 else     // 565 - Manuf housing personal                                    
//    If '1306391'  in gpid then grm_1 := 566 else     // 566
//    If '1306392'  in gpid then grm_1 := 567 else     // 567
//    If '1306393'  in gpid then grm_1 := 568 else     // 568
//    If '1306394'  in gpid then grm_1 := 569 else     // 569
//    If '1306395'  in gpid then grm_1 := 570 else     // 570
//    If '1306396'  in gpid then grm_1 := 571 else     // 571
//    If '1306397'  in gpid then grm_1 := 572 else     // 572
//    If '1306398'  in gpid then grm_1 := 573 else     // 573
//    If '1306399'  in gpid then grm_1 := 574 else     // 574
//    If '1306400'  in gpid then grm_1 := 575 else     // 575
//    If '1306401'  in gpid then grm_1 := 576 else     // 576
//    If '1306402'  in gpid then grm_1 := 577 else     // 577
//    If '1306403'  in gpid then grm_1 := 578 else     // 578
//    If '1306404'  in gpid then grm_1 := 579 else     // 579
//    If '1306405'  in gpid then grm_1 := 580 else     // 580
//    If '1306406'  in gpid then grm_1 := 581 else     // 581
//    If '1306407'  in gpid then grm_1 := 582 else     // 582
//    If '1306408'  in gpid then grm_1 := 583 else     // 583
//    If '1306409'  in gpid then grm_1 := 584 else     // 584
//    If '1306410'  in gpid then grm_1 := 585 else     // 585
//    If '1306411'  in gpid then grm_1 := 586 else     // 586
//    If '1306412'  in gpid then grm_1 := 587 else     // 587
//    If '1306413'  in gpid then grm_1 := 588 else     // 588
//    If '1306414'  in gpid then grm_1 := 589 else     // 589
//    If '1306415'  in gpid then grm_1 := 590 else     // 590
//    If '1306416'  in gpid then grm_1 := 591 else     // 5- Undeveloped land                                             
//    If '1306417'  in gpid then grm_1 := 592 else     // 592
//    If '1306418'  in gpid then grm_1 := 593 else     // 593
//    If '1306419'  in gpid then grm_1 := 594 else     // 5- Open space                                                   
//    If '1306420'  in gpid then grm_1 := 595 else     // 595
//    If '1306421'  in gpid then grm_1 := 596 else     // 596
//    If '1306422'  in gpid then grm_1 := 597 else     // 597
//    If '1306423'  in gpid then grm_1 := 598 else     // 598
//    If '1306424'  in gpid then grm_1 := 599 else     // Residential other                                               
//    If '1306425'  in gpid then grm_1 := 600 else     // 6- USA                                                          
//    If '1306426'  in gpid then grm_1 := 601 else     // 6- Federal Govt                                                 
//    If '1306427'  in gpid then grm_1 := 602 else     // 6- State Govt                                                   
//    If '1306428'  in gpid then grm_1 := 603 else     // 6- Local Govt                                                   
//    If '1306429'  in gpid then grm_1 := 604 else     // 6- Municipality                                                 
//    If '1306430'  in gpid then grm_1 := 605 else     // 6- Religious                                                    
//    If '1306431'  in gpid then grm_1 := 606 else     // 6- Educational                                                  
//    If '1306432'  in gpid then grm_1 := 607 else     // 6- Hospital District                                            
//    If '1306433'  in gpid then grm_1 := 608 else     // 6- Charities                                                    
//    If '1306434'  in gpid then grm_1 := 609 else     // 6- Other                                                        
//    If '1306435'  in gpid then grm_1 := 610 else     // 6- Churches                                                     
//    If '1306436'  in gpid then grm_1 := 611 else     // 6- Cemeteries                                                   
//    If '1306437'  in gpid then grm_1 := 612 else     // 612
//    If '1306438'  in gpid then grm_1 := 613 else     // 613
//    If '1306439'  in gpid then grm_1 := 614 else     // 614
//    If '1306440'  in gpid then grm_1 := 615 else     // 615
//    If '1306441'  in gpid then grm_1 := 616 else     // 616
//    If '1306442'  in gpid then grm_1 := 617 else     // 617
//    If '1306443'  in gpid then grm_1 := 618 else     // 618
//    If '1306444'  in gpid then grm_1 := 619 else     // 619- Public Right-of-Way                                        
//    If '1306445'  in gpid then grm_1 := 620 else     // 620
//    If '1306446'  in gpid then grm_1 := 621 else     // 621
//    If '1306447'  in gpid then grm_1 := 622 else     // 622
//    If '1306448'  in gpid then grm_1 := 623 else     // 623
//    If '1306449'  in gpid then grm_1 := 624 else     // 624- Public or exempt land                                      
//    If '1306450'  in gpid then grm_1 := 625 else     // 625
//    If '1306451'  in gpid then grm_1 := 626 else     // 626
//    If '1306452'  in gpid then grm_1 := 627 else     // 627
//    If '1306453'  in gpid then grm_1 := 628 else     // 628
//    If '1306454'  in gpid then grm_1 := 629 else     // 629
//    If '1306455'  in gpid then grm_1 := 630 else     // 630
//    If '1306456'  in gpid then grm_1 := 631 else     // 631
//    If '1306457'  in gpid then grm_1 := 632 else     // 632
//    If '1306458'  in gpid then grm_1 := 633 else     // 633
//    If '1306459'  in gpid then grm_1 := 634 else     // 634
//    If '1306460'  in gpid then grm_1 := 635 else     // 635
//    If '1306461'  in gpid then grm_1 := 636 else     // 636
//    If '1306462'  in gpid then grm_1 := 637 else     // 637
//    If '1306463'  in gpid then grm_1 := 638 else     // 638
//    If '1306464'  in gpid then grm_1 := 639 else     // 639
//    If '1306465'  in gpid then grm_1 := 640 else     // 640
//    If '1306466'  in gpid then grm_1 := 641 else     // 641
//    If '1306467'  in gpid then grm_1 := 642 else     // 642
//    If '1306468'  in gpid then grm_1 := 643 else     // 643
//    If '1306469'  in gpid then grm_1 := 644 else     // 644
//    If '1306471'  in gpid then grm_1 := 645 else     // 645
//    If '1306472'  in gpid then grm_1 := 646 else     // 646
//    If '1306473'  in gpid then grm_1 := 647 else     // 647
//    If '1306474'  in gpid then grm_1 := 648 else     // 648
//    If '1306475'  in gpid then grm_1 := 649 else     // 649
//    If '1306476'  in gpid then grm_1 := 650 else     // 650
//    If '1306477'  in gpid then grm_1 := 651 else     // 651
//    If '1306478'  in gpid then grm_1 := 652 else     // 652
//    If '1306479'  in gpid then grm_1 := 653 else     // 653
//    If '1306480'  in gpid then grm_1 := 654 else     // 654
//    If '1306481'  in gpid then grm_1 := 655 else     // 655
//    If '1306482'  in gpid then grm_1 := 656 else     // 656
//    If '1306483'  in gpid then grm_1 := 657 else     // 657
//    If '1306484'  in gpid then grm_1 := 658 else     // 658
//    If '1306485'  in gpid then grm_1 := 659 else     // 659
//    If '1306486'  in gpid then grm_1 := 660 else     // 660
//    If '1306487'  in gpid then grm_1 := 661 else     // 661- Imp/RR or Exempt Land                                      
//    If '1306488'  in gpid then grm_1 := 662 else     // 662
//    If '1306489'  in gpid then grm_1 := 663 else     // 663
//    If '1306490'  in gpid then grm_1 := 664 else     // 664
//    If '1306491'  in gpid then grm_1 := 665 else     // 665
//    If '1306492'  in gpid then grm_1 := 666 else     // 666
//    If '1306493'  in gpid then grm_1 := 667 else     // 667- Operating property                                         
//    If '1306494'  in gpid then grm_1 := 668 else     // 668
//    If '1306495'  in gpid then grm_1 := 669 else     // 669
//    If '1306496'  in gpid then grm_1 := 670 else     // 670
//    If '1306497'  in gpid then grm_1 := 671 else     // 671
//    If '1306498'  in gpid then grm_1 := 672 else     // 672
//    If '1306499'  in gpid then grm_1 := 673 else     // 673- Water                                                      
//    If '1306500'  in gpid then grm_1 := 674 else     // 674
//    If '1306501'  in gpid then grm_1 := 675 else     // 675
//    If '1306502'  in gpid then grm_1 := 676 else     // 676
//    If '1306503'  in gpid then grm_1 := 677 else     // 677
//    If '1306504'  in gpid then grm_1 := 678 else     // 678
//    If '1306505'  in gpid then grm_1 := 679 else     // 679
//    If '1306506'  in gpid then grm_1 := 680 else     // 680
//    If '1306507'  in gpid then grm_1 := 681 else     // 681 - Exempt property                                           
//    If '1306508'  in gpid then grm_1 := 682 else     // 682
//    If '1306509'  in gpid then grm_1 := 683 else     // 683
//    If '1306510'  in gpid then grm_1 := 684 else     // 684
//    If '1306511'  in gpid then grm_1 := 685 else     // 685
//    If '1306512'  in gpid then grm_1 := 686 else     // 686
//    If '1306513'  in gpid then grm_1 := 687 else     // 687
//    If '1306514'  in gpid then grm_1 := 688 else     // 688
//    If '1306515'  in gpid then grm_1 := 689 else     // 689
//    If '1306516'  in gpid then grm_1 := 690 else     // 690
//    If '1306517'  in gpid then grm_1 := 691 else     // 691
//    If '1306518'  in gpid then grm_1 := 692 else     // 692
//    If '1306519'  in gpid then grm_1 := 693 else     // 693
//    If '1306520'  in gpid then grm_1 := 694 else     // 694
//    If '1306521'  in gpid then grm_1 := 695 else     // 695
//    If '1306522'  in gpid then grm_1 := 696 else     // 696
//    If '1306523'  in gpid then grm_1 := 697 else     // 697
//    If '1306524'  in gpid then grm_1 := 698 else     // 698
//    If '1306525'  in gpid then grm_1 := 699 else     // 699 - Fish & Game                                               
//    If '1306526'  in gpid then grm_1 := 700 else     // 700
//    If '1306527'  in gpid then grm_1 := 701 else     // 701
//    If '1306528'  in gpid then grm_1 := 702 else     // 702
//    If '1306529'  in gpid then grm_1 := 703 else     // 703
//    If '1306530'  in gpid then grm_1 := 704 else     // 704
//    If '1306531'  in gpid then grm_1 := 705 else     // 705
//    If '1306532'  in gpid then grm_1 := 706 else     // 706
//    If '1306533'  in gpid then grm_1 := 707 else     // 707
//    If '1306534'  in gpid then grm_1 := 708 else     // 708
//    If '1306535'  in gpid then grm_1 := 709 else     // 709
//    If '1306536'  in gpid then grm_1 := 710 else     // 710
//    If '1306537'  in gpid then grm_1 := 711 else     // 711
//    If '1306538'  in gpid then grm_1 := 712 else     // 712
//    If '1306539'  in gpid then grm_1 := 713 else     // 713
//    If '1306540'  in gpid then grm_1 := 714 else     // 714
//    If '1306541'  in gpid then grm_1 := 715 else     // 715
//    If '1306542'  in gpid then grm_1 := 716 else     // 716
//    If '1306543'  in gpid then grm_1 := 717 else     // 717
//    If '1306544'  in gpid then grm_1 := 718 else     // 718
//    If '1306545'  in gpid then grm_1 := 719 else     // 719
//    If '1306546'  in gpid then grm_1 := 720 else     // 720
//    If '1306547'  in gpid then grm_1 := 721 else     // 721
//    If '1306548'  in gpid then grm_1 := 722 else     // 722
//    If '1306549'  in gpid then grm_1 := 723 else     // 723
//    If '1306550'  in gpid then grm_1 := 724 else     // 724
//    If '1306551'  in gpid then grm_1 := 725 else     // 725
//    If '1306552'  in gpid then grm_1 := 726 else     // 726
//    If '1306553'  in gpid then grm_1 := 727 else     // 727
//    If '1306554'  in gpid then grm_1 := 728 else     // 728
//    If '1306555'  in gpid then grm_1 := 729 else     // 729
//    If '1306556'  in gpid then grm_1 := 730 else     // 730
//    If '1306557'  in gpid then grm_1 := 731 else     // 731
//    If '1306558'  in gpid then grm_1 := 732 else     // 732
//    If '1306559'  in gpid then grm_1 := 733 else     // 733
//    If '1306560'  in gpid then grm_1 := 734 else     // 734
//    If '1306561'  in gpid then grm_1 := 735 else     // 735
//    If '1306562'  in gpid then grm_1 := 736 else     // 736
//    If '1306563'  in gpid then grm_1 := 737 else     // 737
//    If '1306564'  in gpid then grm_1 := 738 else     // 738
//    If '1306565'  in gpid then grm_1 := 739 else     // 739
//    If '1306566'  in gpid then grm_1 := 740 else     // 740
//    If '1306567'  in gpid then grm_1 := 741 else     // 741
//    If '1306568'  in gpid then grm_1 := 742 else     // 742
//    If '1306569'  in gpid then grm_1 := 743 else     // 743
//    If '1306570'  in gpid then grm_1 := 744 else     // 744
//    If '1306571'  in gpid then grm_1 := 745 else     // 745
//    If '1306572'  in gpid then grm_1 := 746 else     // 746
//    If '1306573'  in gpid then grm_1 := 747 else     // 747
//    If '1306574'  in gpid then grm_1 := 748 else     // 748
//    If '1306575'  in gpid then grm_1 := 749 else     // 749
//    If '1306576'  in gpid then grm_1 := 750 else     // 750
//    If '1306577'  in gpid then grm_1 := 751 else     // 751
//    If '1306578'  in gpid then grm_1 := 752 else     // 752
//    If '1306579'  in gpid then grm_1 := 753 else     // 753
//    If '1306580'  in gpid then grm_1 := 754 else     // 754
//    If '1306581'  in gpid then grm_1 := 755 else     // 755
//    If '1306582'  in gpid then grm_1 := 756 else     // 756
//    If '1306583'  in gpid then grm_1 := 757 else     // 757
//    If '1306584'  in gpid then grm_1 := 758 else     // 758
//    If '1306585'  in gpid then grm_1 := 759 else     // 759
//    If '1306586'  in gpid then grm_1 := 760 else     // 760
//    If '1306587'  in gpid then grm_1 := 761 else     // 761
//    If '1306588'  in gpid then grm_1 := 762 else     // 762
//    If '1306589'  in gpid then grm_1 := 763 else     // 763
//    If '1306590'  in gpid then grm_1 := 764 else     // 764
//    If '1306591'  in gpid then grm_1 := 765 else     // 765
//    If '1306592'  in gpid then grm_1 := 766 else     // 766
//    If '1306593'  in gpid then grm_1 := 767 else     // 767
//    If '1306594'  in gpid then grm_1 := 768 else     // 768
//    If '1306595'  in gpid then grm_1 := 769 else     // 769
//    If '1306596'  in gpid then grm_1 := 770 else     // 770
//    If '1306597'  in gpid then grm_1 := 771 else     // 771
//    If '1306598'  in gpid then grm_1 := 772 else     // 772
//    If '1306599'  in gpid then grm_1 := 773 else     // 773
//    If '1306600'  in gpid then grm_1 := 774 else     // 774
//    If '1306601'  in gpid then grm_1 := 775 else     // 775
//    If '1306602'  in gpid then grm_1 := 776 else     // 776
//    If '1306603'  in gpid then grm_1 := 777 else     // 777
//    If '1306604'  in gpid then grm_1 := 778 else     // 778
//    If '1306605'  in gpid then grm_1 := 779 else     // 779
//    If '1306606'  in gpid then grm_1 := 780 else     // 780
//    If '1306607'  in gpid then grm_1 := 781 else     // 781
//    If '1306608'  in gpid then grm_1 := 782 else     // 782
//    If '1306609'  in gpid then grm_1 := 783 else     // 783
//    If '1306610'  in gpid then grm_1 := 784 else     // 784
//    If '1306611'  in gpid then grm_1 := 785 else     // 785
//    If '1306612'  in gpid then grm_1 := 786 else     // 7- Reforestation                                                
//    If '1306613'  in gpid then grm_1 := 787 else     // 7- Classified forest                                            
//    If '1306614'  in gpid then grm_1 := 788 else     // 7- Designated forest                                            
//    If '1306615'  in gpid then grm_1 := 789 else     // 7- Other resource production                                    
//    If '1306616'  in gpid then grm_1 := 790 else     // 790
//    If '1306617'  in gpid then grm_1 := 791 else     // 791
//    If '1306618'  in gpid then grm_1 := 792 else     // 792
//    If '1306619'  in gpid then grm_1 := 793 else     // 793
//    If '1306620'  in gpid then grm_1 := 794 else     // 7- Open space                                                   
//    If '1306621'  in gpid then grm_1 := 795 else     // 7- Open space timber                                            
//    If '1306622'  in gpid then grm_1 := 796 else     // 796
//    If '1306623'  in gpid then grm_1 := 797 else     // 797
//    If '1306624'  in gpid then grm_1 := 798 else     // 798
//    If '1306625'  in gpid then grm_1 := 799 else     // 799
//    If '1306626'  in gpid then grm_1 := 800 else     // Utility: Agricultural                                           
//    If '1306627'  in gpid then grm_1 := 801 else     // 801
//    If '1306628'  in gpid then grm_1 := 802 else     // 802
//    If '1306629'  in gpid then grm_1 := 803 else     // 803
//    If '1306630'  in gpid then grm_1 := 804 else     // 804
//    If '1306631'  in gpid then grm_1 := 805 else     // 805
//    If '1306632'  in gpid then grm_1 := 806 else     // 806
//    If '1306633'  in gpid then grm_1 := 807 else     // 807
//    If '1306634'  in gpid then grm_1 := 808 else     // 808
//    If '1306635'  in gpid then grm_1 := 809 else     // 809
//    If '1306636'  in gpid then grm_1 := 810 else     // Utility: Mineral                                                
//    If '1306637'  in gpid then grm_1 := 811 else     // 811
//    If '1306638'  in gpid then grm_1 := 812 else     // 812
//    If '1306639'  in gpid then grm_1 := 813 else     // 813
//    If '1306640'  in gpid then grm_1 := 814 else     // 814
//    If '1306641'  in gpid then grm_1 := 815 else     // 815
//    If '1306642'  in gpid then grm_1 := 816 else     // 816
//    If '1306643'  in gpid then grm_1 := 817 else     // 817
//    If '1306644'  in gpid then grm_1 := 818 else     // 818
//    If '1306645'  in gpid then grm_1 := 819 else     // 819
//    If '1306646'  in gpid then grm_1 := 820 else     // Utility: Industrial                                             
//    If '1306647'  in gpid then grm_1 := 821 else     // 821
//    If '1306648'  in gpid then grm_1 := 822 else     // 822
//    If '1306649'  in gpid then grm_1 := 823 else     // 823
//    If '1306650'  in gpid then grm_1 := 824 else     // 824
//    If '1306651'  in gpid then grm_1 := 825 else     // 825
//    If '1306652'  in gpid then grm_1 := 826 else     // 826
//    If '1306653'  in gpid then grm_1 := 827 else     // 827
//    If '1306654'  in gpid then grm_1 := 828 else     // 828
//    If '1306655'  in gpid then grm_1 := 829 else     // 829
//    If '1306656'  in gpid then grm_1 := 830 else     // Utility: Commercial                                             
//    If '1306657'  in gpid then grm_1 := 831 else     // 831
//    If '1306658'  in gpid then grm_1 := 832 else     // 832
//    If '1306659'  in gpid then grm_1 := 833 else     // 833
//    If '1306660'  in gpid then grm_1 := 834 else     // 834
//    If '1306661'  in gpid then grm_1 := 835 else     // 835
//    If '1306662'  in gpid then grm_1 := 836 else     // 836
//    If '1306663'  in gpid then grm_1 := 837 else     // 837
//    If '1306664'  in gpid then grm_1 := 838 else     // 838
//    If '1306665'  in gpid then grm_1 := 839 else     // 839
//    If '1306666'  in gpid then grm_1 := 840 else     // Utility: RR real prop-ops                                       
//    If '1306667'  in gpid then grm_1 := 841 else     // 8- Railroad/Transit transport                                   
//    If '1306668'  in gpid then grm_1 := 842 else     // 8- Motor vehicle transport                                      
//    If '1306669'  in gpid then grm_1 := 843 else     // 8- Aircraft transport                                           
//    If '1306670'  in gpid then grm_1 := 844 else     // 8- Marine craft transport                                       
//    If '1306671'  in gpid then grm_1 := 845 else     // 845- Locally Assessed Operating Property                        
//    If '1306672'  in gpid then grm_1 := 846 else     // 8- Automobile parking                                           
//    If '1306673'  in gpid then grm_1 := 847 else     // 8- Communication                                                
//    If '1306674'  in gpid then grm_1 := 848 else     // 8- Utilities                                                    
//    If '1306675'  in gpid then grm_1 := 849 else     // 8- Other transpt                                                
//    If '1306676'  in gpid then grm_1 := 850 else     // Utility: RR real prop-not ops                                   
//    If '1306677'  in gpid then grm_1 := 851 else     // 851
//    If '1306678'  in gpid then grm_1 := 852 else     // 852
//    If '1306679'  in gpid then grm_1 := 853 else     // 853
//    If '1306680'  in gpid then grm_1 := 854 else     // 854
//    If '1306681'  in gpid then grm_1 := 855 else     // 855
//    If '1306682'  in gpid then grm_1 := 856 else     // 856
//    If '1306683'  in gpid then grm_1 := 857 else     // 857
//    If '1306684'  in gpid then grm_1 := 858 else     // 858
//    If '1306685'  in gpid then grm_1 := 859 else     // 859
//    If '1306686'  in gpid then grm_1 := 860 else     // Utility: RR pers prop-ops                                       
//    If '1306687'  in gpid then grm_1 := 861 else     // 861
//    If '1306688'  in gpid then grm_1 := 862 else     // 862
//    If '1306689'  in gpid then grm_1 := 863 else     // 863
//    If '1306690'  in gpid then grm_1 := 864 else     // 864
//    If '1306691'  in gpid then grm_1 := 865 else     // 865
//    If '1306692'  in gpid then grm_1 := 866 else     // 866
//    If '1306693'  in gpid then grm_1 := 867 else     // 867- Op Prop Central Assess                                     
//    If '1306694'  in gpid then grm_1 := 868 else     // 868
//    If '1306695'  in gpid then grm_1 := 869 else     // 869
//    If '1306696'  in gpid then grm_1 := 870 else     // Utility: RR pers prop-not ops                                   
//    If '1306697'  in gpid then grm_1 := 871 else     // 871
//    If '1306698'  in gpid then grm_1 := 872 else     // 872
//    If '1306699'  in gpid then grm_1 := 873 else     // 873
//    If '1306700'  in gpid then grm_1 := 874 else     // 874
//    If '1306701'  in gpid then grm_1 := 875 else     // 875
//    If '1306702'  in gpid then grm_1 := 876 else     // 876
//    If '1306703'  in gpid then grm_1 := 877 else     // 877
//    If '1306704'  in gpid then grm_1 := 878 else     // 878
//    If '1306705'  in gpid then grm_1 := 879 else     // 879
//    If '1306706'  in gpid then grm_1 := 880 else     // Utility: Pers prop - not RR                                     
//    If '1306707'  in gpid then grm_1 := 881 else     // 881
//    If '1306708'  in gpid then grm_1 := 882 else     // 882
//    If '1306709'  in gpid then grm_1 := 883 else     // 883
//    If '1306710'  in gpid then grm_1 := 884 else     // 884
//    If '1306711'  in gpid then grm_1 := 885 else     // 885
//    If '1306712'  in gpid then grm_1 := 886 else     // 886
//    If '1306713'  in gpid then grm_1 := 887 else     // 887
//    If '1306714'  in gpid then grm_1 := 888 else     // 888
//    If '1306715'  in gpid then grm_1 := 889 else     // 889
//    If '1306716'  in gpid then grm_1 := 890 else     // 890
//    If '1306717'  in gpid then grm_1 := 891 else     // 891
//    If '1306718'  in gpid then grm_1 := 892 else     // 892
//    If '1306719'  in gpid then grm_1 := 893 else     // 893
//    If '1306720'  in gpid then grm_1 := 894 else     // 894
//    If '1306721'  in gpid then grm_1 := 895 else     // 895
//    If '1306722'  in gpid then grm_1 := 896 else     // 896
//    If '1306723'  in gpid then grm_1 := 897 else     // 897
//    If '1306724'  in gpid then grm_1 := 898 else     // 898
//    If '1306725'  in gpid then grm_1 := 899 else     // 899
//    If '1306726'  in gpid then grm_1 := 900 else     // 900
//    If '1306727'  in gpid then grm_1 := 901 else     // 901
//    If '1306728'  in gpid then grm_1 := 902 else     // 902
//    If '1306729'  in gpid then grm_1 := 903 else     // 903
//    If '1306730'  in gpid then grm_1 := 904 else     // 904
//    If '1306731'  in gpid then grm_1 := 905 else     // 905
//    If '1306732'  in gpid then grm_1 := 906 else     // 906
//    If '1306733'  in gpid then grm_1 := 907 else     // 907
//    If '1306734'  in gpid then grm_1 := 908 else     // 908
//    If '1306735'  in gpid then grm_1 := 909 else     // 909
//    If '1306736'  in gpid then grm_1 := 910 else     // 910
//    If '1306737'  in gpid then grm_1 := 911 else     // 911
//    If '1306738'  in gpid then grm_1 := 912 else     // 912
//    If '1306739'  in gpid then grm_1 := 913 else     // 913
//    If '1306740'  in gpid then grm_1 := 914 else     // 914
//    If '1306741'  in gpid then grm_1 := 915 else     // 915
//    If '1306742'  in gpid then grm_1 := 916 else     // 916
//    If '1306743'  in gpid then grm_1 := 917 else     // 917
//    If '1306744'  in gpid then grm_1 := 918 else     // 918
//    If '1306745'  in gpid then grm_1 := 919 else     // 919
//    If '1306746'  in gpid then grm_1 := 920 else     // 920
//    If '1306747'  in gpid then grm_1 := 921 else     // 921
//    If '1306748'  in gpid then grm_1 := 922 else     // 922
//    If '1306749'  in gpid then grm_1 := 923 else     // 923
//    If '1306750'  in gpid then grm_1 := 924 else     // 924
//    If '1306751'  in gpid then grm_1 := 925 else     // 925
//    If '1306752'  in gpid then grm_1 := 926 else     // 926
//    If '1306753'  in gpid then grm_1 := 927 else     // 927
//    If '1306754'  in gpid then grm_1 := 928 else     // 928
//    If '1306755'  in gpid then grm_1 := 929 else     // 929
//    If '1306756'  in gpid then grm_1 := 930 else     // 930
//    If '1306757'  in gpid then grm_1 := 931 else     // 931
//    If '1306758'  in gpid then grm_1 := 932 else     // 932
//    If '1306759'  in gpid then grm_1 := 933 else     // 933
//    If '1306760'  in gpid then grm_1 := 934 else     // 934
//    If '1306761'  in gpid then grm_1 := 935 else     // 935
//    If '1306762'  in gpid then grm_1 := 936 else     // 936
//    If '1306763'  in gpid then grm_1 := 937 else     // 937
//    If '1306764'  in gpid then grm_1 := 938 else     // 938
//    If '1306765'  in gpid then grm_1 := 939 else     // 939
//    If '1306766'  in gpid then grm_1 := 940 else     // 940
//    If '1306767'  in gpid then grm_1 := 941 else     // 941
//    If '1306768'  in gpid then grm_1 := 942 else     // 942
//    If '1306769'  in gpid then grm_1 := 943 else     // 943
//    If '1306770'  in gpid then grm_1 := 944 else     // 944/
//    If '1306771'  in gpid then grm_1 := 945 else     // 945
//    If '1306772'  in gpid then grm_1 := 946 else     // 946
//    If '1306773'  in gpid then grm_1 := 947 else     // 947
//    If '1306774'  in gpid then grm_1 := 948 else     // 948
//    If '1306775'  in gpid then grm_1 := 949 else     // 949
//    If '1306776'  in gpid then grm_1 := 950 else     // 950
//    If '1306777'  in gpid then grm_1 := 951 else     // 951
//    If '1306778'  in gpid then grm_1 := 952 else     // 952
//    If '1306779'  in gpid then grm_1 := 953 else     // 953
//    If '1306780'  in gpid then grm_1 := 954 else     // 954
//    If '1306781'  in gpid then grm_1 := 955 else     // 955
//    If '1306782'  in gpid then grm_1 := 956 else     // 956
//    If '1306783'  in gpid then grm_1 := 957 else     // 957
//    If '1306784'  in gpid then grm_1 := 958 else     // 958
//    If '1306785'  in gpid then grm_1 := 959 else     // 959
//    If '1306786'  in gpid then grm_1 := 960 else     // 960
//    If '1306787'  in gpid then grm_1 := 961 else     // 961
//    If '1306788'  in gpid then grm_1 := 962 else     // 962
//    If '1306789'  in gpid then grm_1 := 963 else     // 963
//    If '1306790'  in gpid then grm_1 := 964 else     // 964
//    If '1306791'  in gpid then grm_1 := 965 else     // 965
//    If '1306792'  in gpid then grm_1 := 966 else     // 966
//    If '1306793'  in gpid then grm_1 := 967 else     // 967
//    If '1306794'  in gpid then grm_1 := 968 else     // 968
//    If '1306795'  in gpid then grm_1 := 969 else     // 969
//    If '1306796'  in gpid then grm_1 := 970 else     // 970
//    If '1306797'  in gpid then grm_1 := 971 else     // 971
//    If '1306798'  in gpid then grm_1 := 972 else     // 972
//    If '1306799'  in gpid then grm_1 := 973 else     // 973
//    If '1306800'  in gpid then grm_1 := 974 else     // 974
//    If '1306801'  in gpid then grm_1 := 975 else     // 975
//    If '1306802'  in gpid then grm_1 := 976 else     // 976
//    If '1306803'  in gpid then grm_1 := 977 else     // 977
//    If '1306804'  in gpid then grm_1 := 978 else     // 978
//    If '1306805'  in gpid then grm_1 := 979 else     // 979
//    If '1306806'  in gpid then grm_1 := 980 else     // 980
//    If '1306807'  in gpid then grm_1 := 981 else     // 981
//    If '1306808'  in gpid then grm_1 := 982 else     // 982
//    If '1306809'  in gpid then grm_1 := 983 else     // 983
//    If '1306810'  in gpid then grm_1 := 984 else     // 984
//    If '1306811'  in gpid then grm_1 := 985 else     // 985
//    If '1306812'  in gpid then grm_1 := 986 else     // 986
//    If '1306813'  in gpid then grm_1 := 987 else     // 987
//    If '1306814'  in gpid then grm_1 := 988 else     // 988
//    If '1306815'  in gpid then grm_1 := 989 else     // 989
//    If '1306816'  in gpid then grm_1 := 990 else     // 990
//    If '1306817'  in gpid then grm_1 := 991 else     // 991
//    If '1306818'  in gpid then grm_1 := 992 else     // 992
//    If '1306819'  in gpid then grm_1 := 993 else     // 993
//    If '1306820'  in gpid then grm_1 := 994 else     // 994
//    If '1306821'  in gpid then grm_1 := 995 else     // 995
//    If '1306822'  in gpid then grm_1 := 996 else     // 996
//    If '1306823'  in gpid then grm_1 := 997 else     // 997
//    If '1306824'  in gpid then grm_1 := 998 else     // 998
//    If '1306825'  in gpid then grm_1 := 999 else     // 999 NOT COMPLETE                                                

// 1.B. DEFAULT
    grm_1 := {parcel_base.property_class};
)
    else grm_1 := {parcel_base.property_class};
// 2.A FINAL
    pcc_grm := grm_1;
    pcc_grm;
);
// GRM END


// STD START
(
// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD

// 2.A PASS 1

// 2.A.1 PASS 1 LAND - PRIMARY


// 1. GENERAL
    if pcc_land = 999 and pcc_imp = 999 then pcc_std := pcc_grm else
    if pcc_land = pcc_imp then pcc_std := pcc_land else
    if pcc_land = 0 and pcc_imp <> 0 then pcc_std := pcc_imp else
    if pcc_land <> 0 and pcc_imp = 0 then pcc_std := pcc_land else

// 2. AGRICUTURAL (100)
    if pcc_land in [110,112,115,120] and pcc_imp in [131] then pcc_std := 131 else

    if pcc_land in [110,120] and pcc_imp in [530] then pcc_std := 130 else
    if pcc_land in [101,102,103,104,105,106,107,110,112,115,118,120] and pcc_imp in [532] then pcc_std := 132 else
    if pcc_land in [118] and pcc_imp in [540,740] then pcc_std := 140 else

    if pcc_land in [111,411] and pcc_imp in [133] then pcc_std := 133 else
    if pcc_land in [111] and pcc_imp in [433] then pcc_std := 133 else
    if pcc_land in [113,413] and pcc_imp in [135] then pcc_std := 135 else
    if pcc_land in [113] and pcc_imp in [435] then pcc_std := 135 else
    if pcc_land in [116,416] and pcc_imp in [138] then pcc_std := 138 else
    if pcc_land in [116] and pcc_imp in [438] then pcc_std := 138 else
    if pcc_land in [121,421] and pcc_imp in [142] then pcc_std := 142 else
    if pcc_land in [121] and pcc_imp in [442] then pcc_std := 142 else

    if pcc_land in [110,112] and pcc_imp in [134,534] then pcc_std := 134 else
    if pcc_land in [110,115] and pcc_imp in [137,537] then pcc_std := 137 else
    if pcc_land in [120] and pcc_imp in [141,541] then pcc_std := 141 else

    if pcc_land in [114,314] and pcc_imp in [136] then pcc_std := 136 else
    if pcc_land in [114] and pcc_imp in [336] then pcc_std := 136 else
    if pcc_land in [117,317] and pcc_imp in [139] then pcc_std := 139 else
    if pcc_land in [117] and pcc_imp in [339] then pcc_std := 139 else
    if pcc_land in [122,322] and pcc_imp in [143] then pcc_std := 143 else
    if pcc_land in [122] and pcc_imp in [343] then pcc_std := 143 else

    if pcc_land in [110,112,115,120] and pcc_imp in [146,546] then pcc_std := 146 else
    if pcc_land in [110,112,115,120] and pcc_imp in [547] then pcc_std := 147 else
    if pcc_land in [110,112,115,120] and pcc_imp in [148,548] then pcc_std := 148 else

// 3. MINING
    if pcc_land in [209] and pcc_imp in [532] then pcc_std := 232 else

// 4. INDUSTRIAL (300)
    if pcc_land in [314] and pcc_imp in [336] then pcc_std := 336 else
    if pcc_land in [317] and pcc_imp in [339] then pcc_std := 339 else
    if pcc_land in [322] and pcc_imp in [343] then pcc_std := 343 else

    if pcc_land in [320] and pcc_imp in [530] then pcc_std := 330 else
    if pcc_land in [312] and pcc_imp in [532] then pcc_std := 332.12 else
    if pcc_land in [315] and pcc_imp in [532] then pcc_std := 332.15 else

    if pcc_land in [312,314] and pcc_imp in [334,534] then pcc_std := 334 else
    if pcc_land in [315,317] and pcc_imp in [337,537] then pcc_std := 337 else
    if pcc_land in [320,322] and pcc_imp in [341,541] then pcc_std := 341 else

    if pcc_land in [312,315,320] and pcc_imp in [346,546] then pcc_std := 346 else
    if pcc_land in [312,315,320] and pcc_imp in [348,548] then pcc_std := 348 else

// 5. COMMERCIAL (400)
    if pcc_land in [411] and pcc_imp in [433] then pcc_std := 433 else
    if pcc_land in [413] and pcc_imp in [435] then pcc_std := 435 else
    if pcc_land in [416] and pcc_imp in [438] then pcc_std := 438 else
    if pcc_land in [421] and pcc_imp in [442] then pcc_std := 442 else

    if pcc_land in [420] and pcc_imp in [530] then pcc_std := 430 else
    if pcc_land in [412] and pcc_imp in [532] then pcc_std := 432.12 else
    if pcc_land in [415] and pcc_imp in [532] then pcc_std := 432.15 else

    if pcc_land in [412,413] and pcc_imp in [434,534] then pcc_std := 434 else
    if pcc_land in [415,416] and pcc_imp in [437,537] then pcc_std := 437 else
    if pcc_land in [420,421] and pcc_imp in [441,541] then pcc_std := 441 else

    if pcc_land in [513,516,521] and pcc_imp in [446,546] then pcc_std := 446 else
    if pcc_land in [513,516,521] and pcc_imp in [448,548] then pcc_std := 448 else

// 6. RESIDENTIAL (500)
    if pcc_land in [512] and pcc_imp in [534] then pcc_std := 534 else
    if pcc_land in [515] and pcc_imp in [537] then pcc_std := 537 else
    if pcc_land in [520] and pcc_imp in [541] then pcc_std := 541 else

    if pcc_land in [520] and pcc_imp in [530] then pcc_std := 530 else
    if pcc_land in [512] and pcc_imp in [532] then pcc_std := 532.12 else
    if pcc_land in [515] and pcc_imp in [532] then pcc_std := 532.15 else
    if pcc_land in [512,515,520] and pcc_imp in [740] then pcc_std := 540 else

    if pcc_land in [512,515,520] and pcc_imp in [546] then pcc_std := 546 else
    if pcc_land in [512,515,520] and pcc_imp in [547] then pcc_std := 547 else
    if pcc_land in [512,515,520] and pcc_imp in [548] then pcc_std := 548 else

// 7. OTHER (700)
    if pcc_land in [711] and pcc_imp in [433] then pcc_std := 733 else
    if pcc_land in [713] and pcc_imp in [435] then pcc_std := 735 else
    if pcc_land in [716] and pcc_imp in [438] then pcc_std := 738 else
    if pcc_land in [718] and pcc_imp in [740] then pcc_std := 740 else
    if pcc_land in [721] and pcc_imp in [442] then pcc_std := 742 else

// 8. DELETE AFTER 2007
//    if pcc_imp in [960] then pcc_std := 962 else
//    if pcc_imp in [961] then pcc_std := 962 else
    if pcc_imp in [962] then pcc_std := 962 else

// 9. FINAL
    pcc_std := 0;
    pcc_std;
);


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LastRecordedAdj
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OnLastRecord;
shared numbervar grp;

//RUNNING TOTALS
// c = current cycle
// p = previous cycle
// ## = group number
numbervar c01;
numbervar p01;
numbervar c02;
numbervar p02;
numbervar c03;
numbervar p03;
numbervar c04;
numbervar p04;
numbervar c05;
numbervar p05;
numbervar c06;
numbervar p06;
numbervar c07;
numbervar p07;
numbervar c08;
numbervar p08;
numbervar c09;
numbervar p09;
numbervar c10;
numbervar p10;
numbervar c11;
numbervar p11;
numbervar c12;
numbervar p12;
numbervar c13;
numbervar p13;
numbervar c14;
numbervar p14;
numbervar c15;
numbervar p15;
numbervar c16;
numbervar p16;
numbervar c17;
numbervar p17;
numbervar c18;
numbervar p18;
numbervar c19;
numbervar p19;
numbervar c20;
numbervar p20;
numbervar c21;
numbervar p21;
numbervar c22;
numbervar p22;
numbervar c23;
numbervar p23;
numbervar c24;
numbervar p24;
numbervar c25;
numbervar p25;
numbervar c26;
numbervar p26;
numbervar c27;
numbervar p27;
numbervar c28;
numbervar p28;
numbervar c29;
numbervar p29;
numbervar c30;
numbervar p30;
numbervar c31;
numbervar p31;
numbervar c32;
numbervar p32;
numbervar c33;
numbervar p33;
numbervar c34;
numbervar p34;
numbervar c35;
numbervar p35;
numbervar c36;
numbervar p36;
numbervar c37;
numbervar p37;

if grp = 1 and {@Current}  = 1 then c01 := c01 - 1 else
if grp = 1 and {@Previous} = 1 then p01 := p01 - 1 else
if grp = 2 and {@Current}  = 1 then c02 := c02 - 1 else
if grp = 2 and {@Previous} = 1 then p02 := p02 - 1 else
if grp = 3 and {@Current}  = 1 then c03 := c03 - 1 else
if grp = 3 and {@Previous} = 1 then p03 := p03 - 1 else
if grp = 4 and {@Current}  = 1 then c04 := c04 - 1 else
if grp = 4 and {@Previous} = 1 then p04 := p04 - 1 else
if grp = 5 and {@Current}  = 1 then c05 := c05 - 1 else
if grp = 5 and {@Previous} = 1 then p05 := p05 - 1 else
if grp = 6 and {@Current}  = 1 then c06 := c06 - 1 else
if grp = 6 and {@Previous} = 1 then p06 := p06 - 1 else
if grp = 7 and {@Current}  = 1 then c07 := c07 - 1 else
if grp = 7 and {@Previous} = 1 then p07 := p07 - 1 else
if grp = 8 and {@Current}  = 1 then c08 := c08 - 1 else
if grp = 8 and {@Previous} = 1 then p08 := p08 - 1 else
if grp = 9 and {@Current}  = 1 then c09 := c09 - 1 else
if grp = 9 and {@Previous} = 1 then p09 := p09 - 1 else

if grp = 10 and {@Current}  = 1 then c10 := c10 - 1 else
if grp = 10 and {@Previous} = 1 then p10 := p10 - 1 else
if grp = 11 and {@Current}  = 1 then c11 := c11 - 1 else
if grp = 11 and {@Previous} = 1 then p11 := p11 - 1 else
if grp = 12 and {@Current}  = 1 then c12 := c12 - 1 else
if grp = 12 and {@Previous} = 1 then p12 := p12 - 1 else
if grp = 13 and {@Current}  = 1 then c13 := c13 - 1 else
if grp = 13 and {@Previous} = 1 then p13 := p13 - 1 else
if grp = 14 and {@Current}  = 1 then c14 := c14 - 1 else
if grp = 14 and {@Previous} = 1 then p14 := p14 - 1 else
if grp = 15 and {@Current}  = 1 then c15 := c15 - 1 else
if grp = 15 and {@Previous} = 1 then p15 := p15 - 1 else
if grp = 16 and {@Current}  = 1 then c16 := c16 - 1 else
if grp = 16 and {@Previous} = 1 then p16 := p16 - 1 else
if grp = 17 and {@Current}  = 1 then c17 := c17 - 1 else
if grp = 17 and {@Previous} = 1 then p17 := p17 - 1 else
if grp = 18 and {@Current}  = 1 then c18 := c18 - 1 else
if grp = 18 and {@Previous} = 1 then p18 := p18 - 1 else
if grp = 19 and {@Current}  = 1 then c19 := c19 - 1 else
if grp = 19 and {@Previous} = 1 then p19 := p19 - 1 else

if grp = 20 and {@Current}  = 1 then c20 := c20 - 1 else
if grp = 20 and {@Previous} = 1 then p20 := p20 - 1 else
if grp = 21 and {@Current}  = 1 then c21 := c21 - 1 else
if grp = 21 and {@Previous} = 1 then p21 := p21 - 1 else
if grp = 22 and {@Current}  = 1 then c22 := c22 - 1 else
if grp = 22 and {@Previous} = 1 then p22 := p22 - 1 else
if grp = 23 and {@Current}  = 1 then c23 := c23 - 1 else
if grp = 23 and {@Previous} = 1 then p23 := p23 - 1 else
if grp = 24 and {@Current}  = 1 then c24 := c24 - 1 else
if grp = 24 and {@Previous} = 1 then p24 := p24 - 1 else
if grp = 25 and {@Current}  = 1 then c25 := c25 - 1 else
if grp = 25 and {@Previous} = 1 then p25 := p25 - 1 else
if grp = 26 and {@Current}  = 1 then c26 := c26 - 1 else
if grp = 26 and {@Previous} = 1 then p26 := p26 - 1 else
if grp = 27 and {@Current}  = 1 then c27 := c27 - 1 else
if grp = 27 and {@Previous} = 1 then p27 := p27 - 1 else
if grp = 28 and {@Current}  = 1 then c28 := c28 - 1 else
if grp = 28 and {@Previous} = 1 then p28 := p28 - 1 else
if grp = 29 and {@Current}  = 1 then c29 := c29 - 1 else
if grp = 29 and {@Previous} = 1 then p29 := p29 - 1 else

if grp = 30 and {@Current}  = 1 then c30 := c30 - 1 else
if grp = 30 and {@Previous} = 1 then p30 := p30 - 1 else
if grp = 31 and {@Current}  = 1 then c31 := c31 - 1 else
if grp = 31 and {@Previous} = 1 then p31 := p31 - 1 else
if grp = 32 and {@Current}  = 1 then c32 := c32 - 1 else
if grp = 32 and {@Previous} = 1 then p32 := p32 - 1 else
if grp = 33 and {@Current}  = 1 then c33 := c33 - 1 else
if grp = 33 and {@Previous} = 1 then p33 := p33 - 1 else
if grp = 34 and {@Current}  = 1 then c34 := c34 - 1 else
if grp = 34 and {@Previous} = 1 then p34 := p34 - 1 else
if grp = 35 and {@Current}  = 1 then c35 := c35 - 1 else
if grp = 35 and {@Previous} = 1 then p35 := p35 - 1 else
if grp = 36 and {@Current}  = 1 then c36 := c36 - 1 else
if grp = 36 and {@Previous} = 1 then p36 := p36 - 1 else

if grp = 37 and {@Current}  = 1 then c37 := c37 - 1 else
if grp = 37 and {@Previous} = 1 then p37 := p37 - 1 else

0;
//c34

//stringvar cycleck;
//if {@Review Year} = {?Review Years}
//    then     cycleck:= "Inspected" 
//    else     cycleck:="Not Inspected"; 
//else

//Group Name} & " - " & cycleck

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
County Codes
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if {parcel_base.county_number} = '01' or {parcel_base.county_number} = '1' then 'ADA' ELSE
if {parcel_base.county_number} = '02' or {parcel_base.county_number} = '2' then 'ADAMS' ELSE
if {parcel_base.county_number} = '03' or {parcel_base.county_number} = '3' then 'BANNOCK' ELSE
if {parcel_base.county_number} = '04' or {parcel_base.county_number} = '4' then 'BEAR LAKE' ELSE
if {parcel_base.county_number} = '05' or {parcel_base.county_number} = '5' then 'BENEWAH' ELSE
if {parcel_base.county_number} = '06' or {parcel_base.county_number} = '6' then 'BINGHAM' ELSE
if {parcel_base.county_number} = '07' or {parcel_base.county_number} = '7' then 'BLAINE' ELSE
if {parcel_base.county_number} = '08' or {parcel_base.county_number} = '8' then 'BOISE' ELSE
if {parcel_base.county_number} = '09' or {parcel_base.county_number} = '9' then 'BONNER' ELSE
if {parcel_base.county_number} = '10' then 'BONNEVILLE' ELSE
if {parcel_base.county_number} = '11' then 'BOUNDARY' ELSE
if {parcel_base.county_number} = '12' then 'BUTTE' ELSE
if {parcel_base.county_number} = '13' then 'CAMAS' ELSE
if {parcel_base.county_number} = '14' then 'CANYON' ELSE
if {parcel_base.county_number} = '15' then 'CARIBOU' ELSE
if {parcel_base.county_number} = '16' then 'CASSIA' ELSE
if {parcel_base.county_number} = '17' then 'CLARK' ELSE
if {parcel_base.county_number} = '18' then 'CLEARWATER' ELSE
if {parcel_base.county_number} = '19' then 'CUSTER' ELSE
if {parcel_base.county_number} = '20' then 'ELMORE' ELSE
if {parcel_base.county_number} = '21' then 'FRANKLIN' ELSE
if {parcel_base.county_number} = '22' then 'FREMONT' ELSE
if {parcel_base.county_number} = '23' then 'GEM' ELSE
if {parcel_base.county_number} = '24' then 'GOODING' ELSE
if {parcel_base.county_number} = '25' then 'IDAHO' ELSE
if {parcel_base.county_number} = '26' then 'JEFFERSON' ELSE
if {parcel_base.county_number} = '27' then 'JEROME' ELSE
if {parcel_base.county_number} = '28' then 'KOOTENAI' ELSE
if {parcel_base.county_number} = '29' then 'LATAH' ELSE
if {parcel_base.county_number} = '30' then 'LEMHI' ELSE
if {parcel_base.county_number} = '31' then 'LEWIS' ELSE
if {parcel_base.county_number} = '32' then 'LINCOLN' ELSE
if {parcel_base.county_number} = '33' then 'MADISON' ELSE
if {parcel_base.county_number} = '34' then 'MINIDOKA' ELSE
if {parcel_base.county_number} = '35' then 'NEZ PERCE' ELSE
if {parcel_base.county_number} = '36' then 'ONEIDA' ELSE
if {parcel_base.county_number} = '37' then 'OWYHEE' ELSE
if {parcel_base.county_number} = '38' then 'PAYETTE' ELSE
if {parcel_base.county_number} = '39' then 'POWER' ELSE
if {parcel_base.county_number} = '40' then 'SHOSHONE' ELSE
if {parcel_base.county_number} = '41' then 'TETON' ELSE
if {parcel_base.county_number} = '42' then 'TWIN FALLS' ELSE
if {parcel_base.county_number} = '43' then 'VALLEY' ELSE
if {parcel_base.county_number} = '44' then 'WASHINGTON' ELSE 'UNKNOWN'



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Group Code
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CRYSTAL
if isnull({val_detail.lrsn}) 
then 
    totext({parcel_base.property_class},0,'')
else
    left({val_detail.group_code},2)

SQL
SELECT 
    val_detail.lrsn,
    parcel_base.property_class,
    val_detail.group_code,
    CASE 
        WHEN val_detail.lrsn IS NULL 
            THEN CAST(parcel_base.property_class AS VARCHAR(20)) 
        ELSE 
            LEFT(val_detail.group_code, 2) 
    END AS result 

FROM 
    val_detail
    INNER JOIN parcel_base ON val_detail.lrsn = parcel_base.lrsn

ORDER BY 
    result DESC;

--After running this in SQL, removig duplicates on the result column, all it is doing is stripping the letters out of the "group_code" which is an allocations code. 
--group_code 99, result 99
--group_code 67L, result 67
--Etc.

lrsn	property_class	group_code	result
100	1306351	99      	99
527679	1200207	98      	98
31	1306362	81      	81
565357	1306493	67L     	67
7386	1306390	65H     	65
70242	1200165	62      	62
70242	1200165	61P     	61
76460	1200217	55H     	55
76542	2000107	51P     	51
82157	2000106	50H     	50
80360	2000105	49H     	49
80120	2000105	48H     	48
6328	1306373	47H     	47
535905	1306371	46H     	46
13419	1306362	45      	45
58778	1200152	44      	44
87666	1306168	43      	43
553104	1200152	42      	42
2713	1200151	41H     	41
30976	1200207	40H     	40
40621	1200207	39      	39
84457	1306352	38      	38
75301	1306373	37H     	37
29948	1306161	36      	36
70271	1200148	35      	35
539358	1200190	34H     	34
16737	1306161	33      	33
523844	1306362	32      	32
539059	1306362	31H     	31
553537	1200207	30      	30
525951	1306352	27L     	27
60081	1306351	26H     	26
81821	1200199	25      	25
6511	1306147	22      	22
83827	1306168	21      	21
46652	1200207	20H     	20
557321	1200207	19      	19
15778	1200194	18      	18
540327	1306142	17      	17
525041	1200137	16      	16
79743	1306362	15H     	15
50237	1200193	14      	14
560788	1200148	13      	13
37433	1200204	12H     	12
77678	1306263	11      	11
80257	1200204	10H     	10
29133	1200190	09      	09
65091	1200190	07      	07
79870	1200193	06      	06
62943	1200204	05      	05
82953	1200204	04      	04
64207	1200190	03      	03
25483	1306362	02      	02
13095	1306362	01      	01
28878	1306362	        	  



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Group Name
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WhilePrintingRecords;
shared numbervar grp;

If grp =  1 then '1-9, Vacant' else
If grp =  2 then '1-9, Improved' else
If grp =  3 then '11' else
If grp =  4 then ' 11/33' else 
If grp =  5 then '12' else
If grp =  6 then '12/34' else
If grp =  7 then '13' else
If grp =  8 then '13/35' else
If grp =  9 then '14' else
If grp = 10 then '14/36' else
If grp = 11 then '15' else
If grp = 12 then '15/37' else 
If grp = 13 then '16' else
If grp = 14 then '16/38' else
If grp = 15 then '17' else
If grp = 16 then '17/39' else
If grp = 17 then '18' else
If grp = 18 then '18/40' else
If grp = 19 then '20' else
If grp = 20 then '20/41' else
If grp = 21 then '21' else
If grp = 22 then '21/42' else
If grp = 23 then '22' else
If grp = 24 then '22/43' else
If grp = 25 then '25' else
If grp = 26 then '26' else
If grp = 27 then '27' else
If grp = 37 then '45' else
If grp = 28 then '46/47/65' else
If grp = 29 then '48' else
If grp = 30 then '57' else
If grp = 31 then '50' else
If grp = 32 then '51' else
If grp = 33 then 'Bad Category' else
If grp = 34 then 'COMBINED/OTHER' else
If grp = 35 then 'EXEMPT' else
If grp = 36 then 'Category 66' else'UNKNOWN'

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
"Running Totals"
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CRYSTAL
evaluateafter({@Group #});
shared numbervar grp;

//RUNNING TOTALS
// c = current cycle
// p = previous cycle
// ## = group number
numbervar c01;
numbervar p01;
numbervar c02;
numbervar p02;
numbervar c03;
numbervar p03;
numbervar c04;
numbervar p04;
numbervar c05;
numbervar p05;
numbervar c06;
numbervar p06;
numbervar c07;
numbervar p07;
numbervar c08;
numbervar p08;
numbervar c09;
numbervar p09;
numbervar c10;
numbervar p10;
numbervar c11;
numbervar p11;
numbervar c12;
numbervar p12;
numbervar c13;
numbervar p13;
numbervar c14;
numbervar p14;
numbervar c15;
numbervar p15;
numbervar c16;
numbervar p16;
numbervar c17;
numbervar p17;
numbervar c18;
numbervar p18;
numbervar c19;
numbervar p19;
numbervar c20;
numbervar p20;
numbervar c21;
numbervar p21;
numbervar c22;
numbervar p22;
numbervar c23;
numbervar p23;
numbervar c24;
numbervar p24;
numbervar c25;
numbervar p25;
numbervar c26;
numbervar p26;
numbervar c27;
numbervar p27;
numbervar c28;
numbervar p28;
numbervar c29;
numbervar p29;
numbervar c30;
numbervar p30;
numbervar c31;
numbervar p31;
numbervar c32;
numbervar p32;
numbervar c33;
numbervar p33;
numbervar c34;
numbervar p34;
numbervar c35;
numbervar p35;
numbervar c36;
numbervar p36;
numbervar c37;
numbervar p37;

if grp = 1 and {@Current}  = 1 then c01 := c01 + 1 else
if grp = 1 and {@Previous} = 1 then p01 := p01 + 1 else
if grp = 2 and {@Current}  = 1 then c02 := c02 + 1 else
if grp = 2 and {@Previous} = 1 then p02 := p02 + 1 else
if grp = 3 and {@Current}  = 1 then c03 := c03 + 1 else
if grp = 3 and {@Previous} = 1 then p03 := p03 + 1 else
if grp = 4 and {@Current}  = 1 then c04 := c04 + 1 else
if grp = 4 and {@Previous} = 1 then p04 := p04 + 1 else
if grp = 5 and {@Current}  = 1 then c05 := c05 + 1 else
if grp = 5 and {@Previous} = 1 then p05 := p05 + 1 else
if grp = 6 and {@Current}  = 1 then c06 := c06 + 1 else
if grp = 6 and {@Previous} = 1 then p06 := p06 + 1 else
if grp = 7 and {@Current}  = 1 then c07 := c07 + 1 else
if grp = 7 and {@Previous} = 1 then p07 := p07 + 1 else
if grp = 8 and {@Current}  = 1 then c08 := c08 + 1 else
if grp = 8 and {@Previous} = 1 then p08 := p08 + 1 else
if grp = 9 and {@Current}  = 1 then c09 := c09 + 1 else
if grp = 9 and {@Previous} = 1 then p09 := p09 + 1 else

if grp = 10 and {@Current}  = 1 then c10 := c10 + 1 else
if grp = 10 and {@Previous} = 1 then p10 := p10 + 1 else
if grp = 11 and {@Current}  = 1 then c11 := c11 + 1 else
if grp = 11 and {@Previous} = 1 then p11 := p11 + 1 else
if grp = 12 and {@Current}  = 1 then c12 := c12 + 1 else
if grp = 12 and {@Previous} = 1 then p12 := p12 + 1 else
if grp = 13 and {@Current}  = 1 then c13 := c13 + 1 else
if grp = 13 and {@Previous} = 1 then p13 := p13 + 1 else
if grp = 14 and {@Current}  = 1 then c14 := c14 + 1 else
if grp = 14 and {@Previous} = 1 then p14 := p14 + 1 else
if grp = 15 and {@Current}  = 1 then c15 := c15 + 1 else
if grp = 15 and {@Previous} = 1 then p15 := p15 + 1 else
if grp = 16 and {@Current}  = 1 then c16 := c16 + 1 else
if grp = 16 and {@Previous} = 1 then p16 := p16 + 1 else
if grp = 17 and {@Current}  = 1 then c17 := c17 + 1 else
if grp = 17 and {@Previous} = 1 then p17 := p17 + 1 else
if grp = 18 and {@Current}  = 1 then c18 := c18 + 1 else
if grp = 18 and {@Previous} = 1 then p18 := p18 + 1 else
if grp = 19 and {@Current}  = 1 then c19 := c19 + 1 else
if grp = 19 and {@Previous} = 1 then p19 := p19 + 1 else

if grp = 20 and {@Current}  = 1 then c20 := c20 + 1 else
if grp = 20 and {@Previous} = 1 then p20 := p20 + 1 else
if grp = 21 and {@Current}  = 1 then c21 := c21 + 1 else
if grp = 21 and {@Previous} = 1 then p21 := p21 + 1 else
if grp = 22 and {@Current}  = 1 then c22 := c22 + 1 else
if grp = 22 and {@Previous} = 1 then p22 := p22 + 1 else
if grp = 23 and {@Current}  = 1 then c23 := c23 + 1 else
if grp = 23 and {@Previous} = 1 then p23 := p23 + 1 else
if grp = 24 and {@Current}  = 1 then c24 := c24 + 1 else
if grp = 24 and {@Previous} = 1 then p24 := p24 + 1 else
if grp = 25 and {@Current}  = 1 then c25 := c25 + 1 else
if grp = 25 and {@Previous} = 1 then p25 := p25 + 1 else
if grp = 26 and {@Current}  = 1 then c26 := c26 + 1 else
if grp = 26 and {@Previous} = 1 then p26 := p26 + 1 else
if grp = 27 and {@Current}  = 1 then c27 := c27 + 1 else
if grp = 27 and {@Previous} = 1 then p27 := p27 + 1 else
if grp = 28 and {@Current}  = 1 then c28 := c28 + 1 else
if grp = 28 and {@Previous} = 1 then p28 := p28 + 1 else
if grp = 29 and {@Current}  = 1 then c29 := c29 + 1 else
if grp = 29 and {@Previous} = 1 then p29 := p29 + 1 else

if grp = 30 and {@Current}  = 1 then c30 := c30 + 1 else
if grp = 30 and {@Previous} = 1 then p30 := p30 + 1 else
if grp = 31 and {@Current}  = 1 then c31 := c31 + 1 else
if grp = 31 and {@Previous} = 1 then p31 := p31 + 1 else
if grp = 32 and {@Current}  = 1 then c32 := c32 + 1 else
if grp = 32 and {@Previous} = 1 then p32 := p32 + 1 else
if grp = 33 and {@Current}  = 1 then c33 := c33 + 1 else
if grp = 33 and {@Previous} = 1 then p33 := p33 + 1 else
if grp = 34 and {@Current}  = 1 then c34 := c34 + 1 else
if grp = 34 and {@Previous} = 1 then p34 := p34 + 1 else
if grp = 35 and {@Current}  = 1 then c35 := c35 + 1 else
if grp = 35 and {@Previous} = 1 then p35 := p35 + 1 else
if grp = 36 and {@Current}  = 1 then c36 := c36 + 1 else
if grp = 36 and {@Previous} = 1 then p36 := p36 + 1 else

if grp = 37 and {@Current}  = 1 then c37 := c37 + 1 else
if grp = 37 and {@Previous} = 1 then p37 := p37 + 1 else

0;
c34


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
"Review Year"
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CRYSTAL
if isnull({tblRy_001.RVYear})
    then '0000'
    else
if {tblRy_001.RVYear} <> 0
    then totext({tblRy_001.RVYear},0,'')
    else '0000'

SQL
SELECT 
    tblRy_001.lrsn, 
    CASE 
        WHEN tblRy_001.RVYear IS NULL 
            THEN '0000' 
        WHEN tblRy_001.RVYear = 0 
            THEN '0000' 
        ELSE 
            CAST(tblRy_001.RVYear AS VARCHAR(20)) 
    END AS RVYear, 
    tblRy_001.parcel_id, 
    tblRy_001.neighborhood, 
    tblRy_001.parcel_flags
FROM 
    tblRy_001 
WHERE 
    tblRy_001.status = 'A';



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Get a list of PINs in each cycle
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SQL

SELECT 
    CASE
        WHEN RVYear >= 2014 AND RVYear <= 2018 THEN 'Previous Cycle'      
        WHEN RVYear >= 2019 AND RVYear <= 2023 THEN 'Current Cycle'
        WHEN RVYear >= 2024 AND RVYear <= 2028 THEN 'Next Cycle'
        ELSE 'Unknown'
    END AS Reval_Cycle,
    COUNT(parcel_id) AS Parcel_Count,
    STUFF((SELECT ', ' + CAST(parcel_id AS VARCHAR(max))
           FROM tblRy_001
           WHERE status = 'A' AND RVYear = t.RVYear
           ORDER BY parcel_id
           FOR XML PATH ('')), 1, 2, '') AS Parcel_ID_List
FROM tblRy_001 t
WHERE status = 'A'
GROUP BY RVYear, 
    CASE
        WHEN RVYear >= 2014 AND RVYear <= 2018 THEN 'Previous Cycle'      
        WHEN RVYear >= 2019 AND RVYear <= 2023 THEN 'Current Cycle'
        WHEN RVYear >= 2024 AND RVYear <= 2028 THEN 'Next Cycle'
        ELSE 'Unknown'
    END;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    CASE
        WHEN RVYear >= 2014 AND RVYear <= 2018 THEN 'Previous Cycle'      
        WHEN RVYear >= 2019 AND RVYear <= 2023 THEN 'Current Cycle'
        WHEN RVYear >= 2024 AND RVYear <= 2028 THEN 'Next Cycle'
        ELSE 'Unknown'
    END AS Reval_Cycle,
    COUNT(lrsn) AS Parcel_Count,
    STUFF((SELECT ', ' + CAST(lrsn AS VARCHAR(max))
           FROM tblRy_001
           WHERE status = 'A' AND RVYear = t.RVYear
           ORDER BY lrsn
           FOR XML PATH ('')), 1, 2, '') AS LRSN_List
FROM tblRy_001 t
WHERE status = 'A'
GROUP BY RVYear, 
    CASE
        WHEN RVYear >= 2014 AND RVYear <= 2018 THEN 'Previous Cycle'      
        WHEN RVYear >= 2019 AND RVYear <= 2023 THEN 'Current Cycle'
        WHEN RVYear >= 2024 AND RVYear <= 2028 THEN 'Next Cycle'
        ELSE 'Unknown'
    END;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
COUNTS
SELECT
    CASE
        WHEN RVYear >= 2019 AND RVYear <= 2023 THEN 'Current Cycle'
        WHEN RVYear >= 2014 AND RVYear <= 2018 THEN 'Previous Cycle'
        WHEN RVYear >= 2024 AND RVYear <= 2028 THEN 'Next Cycle'
        ELSE 'Unknown'
    END AS Reval_Cycle,
    COUNT(lrsn) AS Parcel_Count
FROM tblRy_001
WHERE status = 'A'
GROUP BY RVYear;



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Group#
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WhilePrintingRecords;
shared numbervar pcc_std;
shared numbervar grp;

//1 1-9 Vacant
If pcc_std = 101 then grp := 1 else
If pcc_std = 102 then grp := 1 else
If pcc_std = 103 then grp := 1 else
If pcc_std = 104 then grp := 1 else
If pcc_std = 105 then grp := 1 else
If pcc_std = 106 then grp := 1 else
If pcc_std = 107 then grp := 1 else
If pcc_std = 209 then grp := 1 else
If pcc_std = 719 then grp := 1 else

//2 1-9 Improved
If pcc_std = 110 then grp := 2 else
If pcc_std = 131 then grp := 2 else
If pcc_std = 132 then grp := 2 else
If pcc_std = 232 then grp := 2 else

//3 11
If pcc_std = 411 then grp := 3 else

 //4 11/33
If pcc_std = 433 then grp := 4 else

//5 12
If pcc_std = 512 then grp := 5 else

//6 12/34
If pcc_std = 534 then grp := 6 else
//If pcc_std = 594 then grp := 6 else

//7 13
If pcc_std = 413 then grp := 7 else

//8 13/35
If pcc_std = 435 then grp := 8 else

//9 14
If pcc_std = 314 then grp := 9 else

//10 14/36
If pcc_std = 336 then grp := 10 else

//11 15
If pcc_std = 515 then grp := 11 else

//12 15/37
If pcc_std = 537 then grp := 12 else
If pcc_std = 597 then grp := 12 else

//13 16
If pcc_std = 416 then grp := 13 else

//14 16/38
If pcc_std = 438 then grp := 14 else

//15 17
If pcc_std = 317 then grp := 15 else

//16 17/39
If pcc_std = 339 then grp := 16 else

//17 18
If pcc_std = 718 then grp := 17 else

//18 17/40
If pcc_std = 740 then grp := 18 else

//19 20
If pcc_std = 520 then grp := 19 else

//20 20/41
If pcc_std = 541 then grp := 20 else
If pcc_std = 591 then grp := 20 else

//21 21
If pcc_std = 421 then grp := 21 else

//22 21/42
If pcc_std = 442 then grp := 22 else

//23 22
If pcc_std = 322 then grp := 23 else

//24 22/43
If pcc_std = 343 then grp := 24 else

//25 25
If pcc_std = 325 then grp := 25 else
If pcc_std = 425 then grp := 25 else
If pcc_std = 525 then grp := 25 else
If pcc_std = 925 then grp := 25 else

//26 26
If pcc_std = 526 then grp := 26 else
If pcc_std = 926 then grp := 26 else

//27 27
If pcc_std = 427 then grp := 27 else
If pcc_std = 927 then grp := 27 else
If pcc_std = 997 then grp := 27 else

//28 46/47/65
If pcc_std = 546 then grp := 28 else
If pcc_std = 549 then grp := 28 else
If pcc_std = 565 then grp := 28 else

//29 48
If pcc_std = 548 then grp := 29 else

//30 57
If pcc_std = 757 then grp := 30 else

//31 50
If pcc_std = 550 then grp := 31 else
//If pcc_std = 960 then grp := 31 else

//32 51
//If pcc_std = 461 then grp := 32 else
If pcc_std = 551 then grp := 32 else
If pcc_std = 451 then grp := 32 else
//If pcc_std = 961 then grp := 32 else

//33 62
//If pcc_std = 462 then grp := 33 else
//If pcc_std = 562 then grp := 33 else
If pcc_std = 962 then grp := 33 else

//34 Combined/Other
If pcc_std = 146 then grp := 34 else
If pcc_std = 148 then grp := 34 else
If pcc_std = 270 then grp := 34 else
If pcc_std = 441 then grp := 34 else
If pcc_std = 455 then grp := 34 else
If pcc_std = 530 then grp := 34 else
If pcc_std = 532 then grp := 34 else
If pcc_std = 542 then grp := 34 else
If pcc_std = 555 then grp := 34 else
If pcc_std = 931 then grp := 34 else
If pcc_std = 933 then grp := 34 else
If pcc_std = 934 then grp := 34 else
If pcc_std = 935 then grp := 34 else
If pcc_std = 936 then grp := 34 else
If pcc_std = 937 then grp := 34 else
If pcc_std = 938 then grp := 34 else
If pcc_std = 939 then grp := 34 else
If pcc_std = 940 then grp := 34 else
If pcc_std = 941 then grp := 34 else
If pcc_std = 942 then grp := 34 else
If pcc_std = 943 then grp := 34 else
If pcc_std = 944 then grp := 34 else
If pcc_std = 946 then grp := 34 else
If pcc_std = 948 then grp := 34 else
If pcc_std = 949 then grp := 34 else
If pcc_std = 965 then grp := 34 else
If pcc_std = 995 then grp := 34 else
If pcc_std = 999 then grp := 34 else

//35 Exempt
If pcc_std in 600 to 699 then grp := 35 else
If pcc_std = 867 then grp := 35 else

//36 Category 66
If pcc_std = 266 then grp := 36 else

//37 Category 45
If pcc_std = 845 then grp := 37 else


//Unknown
grp := 34;
grp;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Group Name
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WhilePrintingRecords;
shared numbervar grp;

If grp =  1 then '1-9, Vacant' else
If grp =  2 then '1-9, Improved' else
If grp =  3 then '11' else
If grp =  4 then ' 11/33' else 
If grp =  5 then '12' else
If grp =  6 then '12/34' else
If grp =  7 then '13' else
If grp =  8 then '13/35' else
If grp =  9 then '14' else
If grp = 10 then '14/36' else
If grp = 11 then '15' else
If grp = 12 then '15/37' else 
If grp = 13 then '16' else
If grp = 14 then '16/38' else
If grp = 15 then '17' else
If grp = 16 then '17/39' else
If grp = 17 then '18' else
If grp = 18 then '18/40' else
If grp = 19 then '20' else
If grp = 20 then '20/41' else
If grp = 21 then '21' else
If grp = 22 then '21/42' else
If grp = 23 then '22' else
If grp = 24 then '22/43' else
If grp = 25 then '25' else
If grp = 26 then '26' else
If grp = 27 then '27' else
If grp = 37 then '45' else
If grp = 28 then '46/47/65' else
If grp = 29 then '48' else
If grp = 30 then '57' else
If grp = 31 then '50' else
If grp = 32 then '51' else
If grp = 33 then 'Bad Category' else
If grp = 34 then 'COMBINED/OTHER' else
If grp = 35 then 'EXEMPT' else
If grp = 36 then 'Category 66' else'UNKNOWN'

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total No/Bad Categories & Breakdown
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total No/Bad Categories:
If grp = 33 then 'Bad Category' else
If grp = 34 then 'COMBINED/OTHER' else
If grp = 35 then 'EXEMPT' else
If grp = 36 then 'Category 66' else'UNKNOWN'
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Category Detail Breakdown
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Category Detail Breakdown

//33 62
//If pcc_std = 462 then grp := 33 else
//If pcc_std = 562 then grp := 33 else
If pcc_std = 962 then grp := 33 else

//34 Combined/Other
If pcc_std = 146 then grp := 34 else
If pcc_std = 148 then grp := 34 else
If pcc_std = 270 then grp := 34 else
If pcc_std = 441 then grp := 34 else
If pcc_std = 455 then grp := 34 else
If pcc_std = 530 then grp := 34 else
If pcc_std = 532 then grp := 34 else
If pcc_std = 542 then grp := 34 else
If pcc_std = 555 then grp := 34 else
If pcc_std = 931 then grp := 34 else
If pcc_std = 933 then grp := 34 else
If pcc_std = 934 then grp := 34 else
If pcc_std = 935 then grp := 34 else
If pcc_std = 936 then grp := 34 else
If pcc_std = 937 then grp := 34 else
If pcc_std = 938 then grp := 34 else
If pcc_std = 939 then grp := 34 else
If pcc_std = 940 then grp := 34 else
If pcc_std = 941 then grp := 34 else
If pcc_std = 942 then grp := 34 else
If pcc_std = 943 then grp := 34 else
If pcc_std = 944 then grp := 34 else
If pcc_std = 946 then grp := 34 else
If pcc_std = 948 then grp := 34 else
If pcc_std = 949 then grp := 34 else
If pcc_std = 965 then grp := 34 else
If pcc_std = 995 then grp := 34 else
If pcc_std = 999 then grp := 34 else

//35 Exempt
If pcc_std in 600 to 699 then grp := 35 else
If pcc_std = 867 then grp := 35 else

//36 Category 66
If pcc_std = 266 then grp := 36 else




-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
!!!!!!!!!!!!!!!!     What is a "pcc_std"      !!!!!!!!!!!!!!!!!!!!!!!!!!!
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

EvaluateAfter ({@GPID});
shared stringvar array gpid;
shared stringvar land_1;
shared stringvar land_2;
shared stringvar land_3;
shared numbervar pcc_land;
shared stringvar imp_1;
shared stringvar imp_2;
shared stringvar imp_3;
shared numbervar pcc_imp;
shared numbervar grm_1;
shared numbervar pcc_grm;
shared numbervar pcc_std;



// LAND START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
    then land_3 := 'L'
    else

// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD
(
// 2.A PASS 1
(
// 2.A.1 PASS 1 LAND - PRIMARY
    If '12' in gpid then land_1 := '12' else
    If '13' in gpid then land_1 := '13' else
    If '14' in gpid then land_1 := '14' else
    If '15' in gpid then land_1 := '15' else
    If '16' in gpid then land_1 := '16' else
    If '17' in gpid then land_1 := '17' else
    If '20' in gpid then land_1 := '20' else
    If '21' in gpid then land_1 := '21' else
    If '22' in gpid then land_1 := '22' else
    If '25' in gpid then land_1 := '25' else
    If '26' in gpid then land_1 := '26' else
    If '27' in gpid then land_1 := '27' else
    If '10' in gpid then land_1 := '10' else
    If '11' in gpid then land_1 := '11' else
    If '18' in gpid then land_1 := '18' else
    If '45' in gpid then land_1 := '45' else
    If '57' in gpid then land_1 := '57' else
    If '67' in gpid then land_1 := '67' else
    If '81' in gpid then land_1 := '81' else
    If '82' in gpid then land_1 := '82' else

// 2.A.2 PASS 1 LAND - SECONDARY
    If '01' in gpid then land_1 := '01' else
    If '02' in gpid then land_1 := '02' else
    If '03' in gpid then land_1 := '03' else
    If '04' in gpid then land_1 := '04' else
    If '05' in gpid then land_1 := '05' else
    If '06' in gpid then land_1 := '06' else
    If '07' in gpid then land_1 := '07' else
    If '09' in gpid then land_1 := '09' else
    If '66' in gpid then land_1 := '66' else
    If '70' in gpid then land_1 := '70' else
    If '19' in gpid then land_1 := '19' else

// 2.A.3 PASS 1 DEFAULT
    land_1 := '00';
);

// 2.B PASS 2
(
// 2.B.1 PASS 2 LAND - PRIMARY
    If '12' in gpid and land_1 <> '12' then land_2 := '12' else
    If '13' in gpid and land_1 <> '13' then land_2 := '13' else
    If '14' in gpid and land_1 <> '14' then land_2 := '14' else
    If '15' in gpid and land_1 <> '15' then land_2 := '15' else
    If '16' in gpid and land_1 <> '16' then land_2 := '16' else
    If '17' in gpid and land_1 <> '17' then land_2 := '17' else
    If '20' in gpid and land_1 <> '20' then land_2 := '20' else
    If '21' in gpid and land_1 <> '21' then land_2 := '21' else
    If '22' in gpid and land_1 <> '22' then land_2 := '22' else
    If '25' in gpid and land_1 <> '25' then land_2 := '25' else
    If '26' in gpid and land_1 <> '26' then land_2 := '26' else
    If '27' in gpid and land_1 <> '27' then land_2 := '27' else
    If '10' in gpid and land_1 <> '10' then land_2 := '10' else
    If '11' in gpid and land_1 <> '11' then land_2 := '11' else
    If '18' in gpid and land_1 <> '18' then land_2 := '18' else
    If '45' in gpid and land_1 <> '45' then land_2 := '45' else
    If '57' in gpid and land_1 <> '57' then land_2 := '57' else
    If '67' in gpid and land_1 <> '67' then land_2 := '67' else
    If '81' in gpid and land_1 <> '81' then land_2 := '81' else
    If '82' in gpid and land_1 <> '82' then land_2 := '82' else

// 2.B.2 PASS 2 LAND - SECONDARY
    If '01' in gpid and land_1 <> '01' then land_2 := '01' else
    If '02' in gpid and land_1 <> '02' then land_2 := '02' else
    If '03' in gpid and land_1 <> '03' then land_2 := '03' else
    If '04' in gpid and land_1 <> '04' then land_2 := '04' else
    If '05' in gpid and land_1 <> '05' then land_2 := '05' else
    If '06' in gpid and land_1 <> '06' then land_2 := '06' else
    If '07' in gpid and land_1 <> '07' then land_2 := '07' else
    If '09' in gpid and land_1 <> '09' then land_2 := '09' else
    If '70' in gpid and land_1 <> '70' then land_2 := '70' else
    If '19' in gpid and land_1 <> '19' then land_2 := '19' else

// 2.B.3 PASS 2 DEFAULT
    land_2 := '00';
);

// 2.B.4 PASS 2 FINAL
    land_3 := land_1 & land_2;
);
// 3.A.1 FINAL - PRIMARY
    If land_3 in ['0100','0102','0103','0104','0105','0106','0107','0109','0119'] then pcc_land := 101 else
    If land_3 in ['0200','0203','0204','0205','0206','0207','0209','0219'] then pcc_land := 102 else
    If land_3 in ['0300','0304','0305','0306','0307','0309','0319'] then pcc_land := 103 else
    If land_3 in ['0400','0405','0406','0407','0409','0419'] then pcc_land := 104 else
    If land_3 in ['0500','0506','0507','0509','0519'] then pcc_land := 105 else
    If land_3 in ['0600','0607','0609','0619'] then pcc_land := 106 else
    If land_3 in ['0700','0709','0719'] then pcc_land := 107 else
    If land_3 in ['1001','1002','1003','1004','1005','1006','1007','1009','1000','1018','1019'] then pcc_land := 110 else
    If land_3 in ['0900','0919'] then pcc_land := 209 else
    If land_3 in ['6600'] then pcc_land := 266 else
    If land_3 in ['7000'] then pcc_land := 270 else
    If land_3 in ['1400','1419'] then pcc_land := 314 else
    If land_3 in ['1700','1719'] then pcc_land := 317 else
    If land_3 in ['2219','2200'] then pcc_land := 322 else
    If land_3 in ['1100','1119'] then pcc_land := 411 else
    If land_3 in ['1300','1319'] then pcc_land := 413 else
    If land_3 in ['1600','1619'] then pcc_land := 416 else
    If land_3 in ['2119','2100'] then pcc_land := 421 else
    If land_3 in ['2719','2700'] then pcc_land := 427 else
    If land_3 in ['1200','1218'] then pcc_land := 512 else
    If land_3 in ['1500','1518'] then pcc_land := 515 else
    If land_3 in ['1820','2018','2000','2019'] then pcc_land := 520 else
    If land_3 in ['2619','2600'] then pcc_land := 526 else
    If land_3 in ['8100'] then pcc_land := 681 else
    If land_3 in ['8200'] then pcc_land := 682 else
    If land_3 in ['1800','1819'] then pcc_land := 718 else
    If land_3 in ['1900'] then pcc_land := 719 else
    If land_3 in ['5719','5700'] then pcc_land := 757 else
    If land_3 in ['4519','4500'] then pcc_land := 845 else
    If land_3 in ['6719','6700'] then pcc_land := 867 else
    If land_3 in ['2519','2500'] then pcc_land := 925 else
    If land_3 = 'L' then pcc_land := 999 else

// 3.A.2 FINAL - MIXED USE
    If land_3 in ['1101','1102','1103','1104','1105','1106','1107','1109','1110'] then pcc_land := 111 else
    If land_3 in ['1201','1202','1203','1204','1205','1206','1207','1209','1210'] then pcc_land := 112 else
    If land_3 in ['1301','1302','1303','1304','1305','1306','1307','1309','1310'] then pcc_land := 113 else
    If land_3 in ['1401','1402','1403','1404','1405','1406','1407','1409','1410'] then pcc_land := 114 else
    If land_3 in ['1501','1502','1503','1504','1505','1506','1507','1509','1510'] then pcc_land := 115 else
    If land_3 in ['1601','1602','1603','1604','1605','1606','1607','1609','1610'] then pcc_land := 116 else
    If land_3 in ['1701','1702','1703','1704','1705','1706','1707','1709','1710'] then pcc_land := 117 else
    If land_3 in ['1801','1802','1803','1804','1805','1806','1807','1809','1810'] then pcc_land := 118 else
    If land_3 in ['2001','2002','2003','2004','2005','2006','2007','2009','2010'] then pcc_land := 120 else
    If land_3 in ['2101','2102','2103','2104','2105','2106','2107','2109','2110'] then pcc_land := 121 else
    If land_3 in ['2201','2202','2203','2204','2205','2206','2207','2209','2210'] then pcc_land := 122 else
    If land_3 in ['1211','1213'] then pcc_land := 412 else
    If land_3 in ['1214'] then pcc_land := 312 else
    If land_3 in ['1516'] then pcc_land := 415 else
    If land_3 in ['1517'] then pcc_land := 315 else
    If land_3 in ['2021'] then pcc_land := 420 else
    If land_3 in ['2022'] then pcc_land := 320 else
    If land_3 in ['1118'] then pcc_land := 711 else
    If land_3 in ['1318'] then pcc_land := 713 else
    If land_3 in ['1618'] then pcc_land := 716 else
    If land_3 in ['2118'] then pcc_land := 721 else

// 4 FINAL
    pcc_land := 0;
    pcc_land;
);
// LAND END


// IMP START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
    then imp_3 := 'I'
    else

// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD
(
// 2.A. PASS 1
(
// 2.A.1 PASS 1 IMPROVEMENT - PRIMARY
    If '31' in gpid then imp_1 := '31' else
    If '33' in gpid then imp_1 := '33' else
    If '34' in gpid then imp_1 := '34' else
    If '35' in gpid then imp_1 := '35' else
    If '36' in gpid then imp_1 := '36' else
    If '37' in gpid then imp_1 := '37' else
    If '38' in gpid then imp_1 := '38' else
    If '39' in gpid then imp_1 := '39' else
    If '41' in gpid then imp_1 := '41' else
    If '42' in gpid then imp_1 := '42' else
    If '43' in gpid then imp_1 := '43' else
    If '46' in gpid then imp_1 := '46' else
    If '48' in gpid then imp_1 := '48' else
    If '49' in gpid then imp_1 := '49' else
    If '65' in gpid then imp_1 := '65' else
    If '25' in gpid then imp_1 := '25' else
    If '26' in gpid then imp_1 := '26' else
    If '27' in gpid then imp_1 := '27' else
    If '45' in gpid then imp_1 := '45' else
    If '50' in gpid then imp_1 := '50' else
    If '51' in gpid then imp_1 := '51' else
    If '57' in gpid then imp_1 := '57' else
    If '66' in gpid then imp_1 := '66' else
    If '69' in gpid then imp_1 := '69' else
    If '81' in gpid then imp_1 := '81' else
    If '82' in gpid then imp_1 := '82' else

// 2.A.2 PASS 1 IMPROVEMENT - SECONDARY
    If '30' in gpid then imp_1 := '30' else
    If '32' in gpid then imp_1 := '32' else
    If '40' in gpid then imp_1 := '40' else
    If '47' in gpid then imp_1 := '47' else

// 2.A.3 PASS 1 IMPROVEMENT - DELETE AFTER 2007
//    If '60' in gpid then imp_1 := '60' else
//    If '61' in gpid then imp_1 := '61' else
   If '62' in gpid then imp_1 := '62' else

// 2.A.4 PASS 1 DEFAULT
    imp_1 := '00';
);
// 2.B PASS 2
(
// 2.B.1 PASS 2 IMPROVEMENT - PRIMARY
    If '31' in gpid and imp_1 <> '31' then imp_2 := '31' else
    If '33' in gpid and imp_1 <> '33' then imp_2 := '33' else
    If '34' in gpid and imp_1 <> '34' then imp_2 := '34' else
    If '35' in gpid and imp_1 <> '35' then imp_2 := '35' else
    If '36' in gpid and imp_1 <> '36' then imp_2 := '36' else
    If '37' in gpid and imp_1 <> '37' then imp_2 := '37' else
    If '38' in gpid and imp_1 <> '38' then imp_2 := '38' else
    If '39' in gpid and imp_1 <> '39' then imp_2 := '39' else
    If '41' in gpid and imp_1 <> '41' then imp_2 := '41' else
    If '42' in gpid and imp_1 <> '42' then imp_2 := '42' else
    If '43' in gpid and imp_1 <> '43' then imp_2 := '43' else
    If '46' in gpid and imp_1 <> '46' then imp_2 := '46' else
    If '48' in gpid and imp_1 <> '48' then imp_2 := '48' else
    If '49' in gpid and imp_1 <> '49' then imp_2 := '49' else
    If '65' in gpid and imp_1 <> '65' then imp_2 := '65' else
    If '25' in gpid and imp_1 <> '25' then imp_2 := '25' else
    If '26' in gpid and imp_1 <> '26' then imp_2 := '26' else
    If '27' in gpid and imp_1 <> '27' then imp_2 := '27' else
    If '45' in gpid and imp_1 <> '45' then imp_2 := '45' else
    If '50' in gpid and imp_1 <> '50' then imp_2 := '50' else
    If '51' in gpid and imp_1 <> '51' then imp_2 := '51' else
    If '57' in gpid and imp_1 <> '57' then imp_2 := '57' else
    If '69' in gpid and imp_1 <> '69' then imp_2 := '69' else
    If '81' in gpid and imp_1 <> '81' then imp_2 := '81' else
    If '82' in gpid and imp_1 <> '82' then imp_2 := '82' else

// 2.B.2 PASS 2 IMPROVEMENT - SECONDARY
    If '30' in gpid and imp_1 <> '30' then imp_2 := '30' else
    If '32' in gpid and imp_1 <> '32' then imp_2 := '32' else
    If '40' in gpid and imp_1 <> '40' then imp_2 := '40' else
    If '47' in gpid and imp_1 <> '47' then imp_2 := '47' else

// 2.B.3 PASS 2 DEFAULT
    imp_2 := '00';
);

// 2.C PASS 2 FINAL
    imp_3 := imp_1 + imp_2;
);
// 3.A.1 FINAL - PRIMARY
    If imp_3 in ['3130','3100','3132','3140'] then pcc_imp := 131 else
    If imp_3 in ['6600'] then pcc_imp := 266 else
    If imp_3 in ['3600','3632'] then pcc_imp := 336 else
    If imp_3 in ['3900','3932'] then pcc_imp := 339 else
    If imp_3 in ['4300','4340'] then pcc_imp := 343 else
    If imp_3 in ['2700'] then pcc_imp := 427 else
    If imp_3 in ['3300','3332'] then pcc_imp := 433 else
    If imp_3 in ['3500','3532'] then pcc_imp := 435 else
    If imp_3 in ['3800','3832'] then pcc_imp := 438 else
    If imp_3 in ['4200','4230'] then pcc_imp := 442 else
    If imp_3 in ['5100'] then pcc_imp := 451 else
    If imp_3 in ['2600'] then pcc_imp := 526 else
    If imp_3 in ['3000','3047'] then pcc_imp := 530 else
    If imp_3 in ['3200','3240','3247','3432','3237','3732'] then pcc_imp := 532 else
    If imp_3 in ['3400'] then pcc_imp := 534 else
    If imp_3 in ['3700'] then pcc_imp := 537 else
    If imp_3 in ['3041','4100','4130'] then pcc_imp := 541 else
    If imp_3 in ['4630','4632','4640','4600','4647'] then pcc_imp := 546 else
    If imp_3 in ['4700'] then pcc_imp := 547 else
    If imp_3 in ['4830','4832','4840','4847','4800'] then pcc_imp := 548 else
    If imp_3 in ['4930','4932','4940','4947','4900'] then pcc_imp := 549 else
    If imp_3 in ['5000'] then pcc_imp := 550 else
    If imp_3 in ['5100'] then pcc_imp := 551 else
    If imp_3 in ['6530','6532','6540','6547','6500'] then pcc_imp := 565 else
    If imp_3 in ['8100'] then pcc_imp := 681 else
    If imp_3 in ['8200'] then pcc_imp := 682 else
    If imp_3 in ['4000'] then pcc_imp := 740 else
    If imp_3 in ['4500'] then pcc_imp := 845 else
    If imp_3 in ['5700'] then pcc_imp := 757 else
    If imp_3 in ['6900'] then pcc_imp := 769 else
    If imp_3 in ['6700'] then pcc_imp := 867 else
    If imp_3 in ['2500'] then pcc_imp := 925 else
    If imp_3 = 'I' then pcc_imp := 999 else

// 3.A.2 FINAL - MIXED USE
    If imp_3 = '3133' then pcc_imp := 133 else
    If imp_3 = '3134' then pcc_imp := 134 else
    If imp_3 = '3135' then pcc_imp := 135 else
    If imp_3 = '3136' then pcc_imp := 136 else
    If imp_3 = '3137' then pcc_imp := 137 else
    If imp_3 = '3138' then pcc_imp := 138 else
    If imp_3 = '3139' then pcc_imp := 139 else
    If imp_3 = '3140' then pcc_imp := 140 else
    If imp_3 = '3141' then pcc_imp := 141 else
    If imp_3 = '3142' then pcc_imp := 142 else
    If imp_3 = '3143' then pcc_imp := 143 else
    If imp_3 = '3146' then pcc_imp := 146 else
    If imp_3 = '3148' then pcc_imp := 148 else
    If imp_3 in ['3546','3846','4246'] then pcc_imp := 446 else
    If imp_3 in ['3548','3848','4248'] then pcc_imp := 448 else

    If imp_3 in ['3334','3435'] then pcc_imp := 434 else
    If imp_3 = '3436' then pcc_imp := 334 else
    If imp_3 = '3738' then pcc_imp := 437 else
    If imp_3 = '3739' then pcc_imp := 337 else
    If imp_3 = '4142' then pcc_imp := 441 else
    If imp_3 = '4143' then pcc_imp := 341 else

    If imp_3 in ['3446','3746','4146'] then pcc_imp := 546 else
    If imp_3 in ['3448','3748','4148'] then pcc_imp := 548 else

// 3.A.3 FINAL - DELETE AFTER 2007
//    If imp_3 = '6000' then pcc_imp := 960 else
//   If imp_3 = '6100' then pcc_imp := 961 else
    If imp_3 = '6200' then pcc_imp := 962 else


// 4 FINAL
    pcc_imp := 0;
    pcc_imp;
);
// IMP END


// GRM START
(
// 1. PARCELS NOT YET CERTIFIED IN PROVAL
if isnull({val_detail.lrsn}) 
then 
(
// 1.A. IF GRM COUNTY USE GRM SYSTYPE FOR PCC_STD
//    If '102500'  in gpid then grm_1 := 100 else     // 100- Agricultural Vac                                           
//    If '102501'  in gpid then grm_1 := 101 else     // 101- Irrigated Crop Land                                        
//    If '102502'  in gpid then grm_1 := 102 else     // 102- Irrigated Grazing Land                                     
//    If '102503'  in gpid then grm_1 := 103 else     // 103- Non-irrigated Crop Land                                    
//    If '102504'  in gpid then grm_1 := 104 else     // 104- Meadow Land                                                
//    If '102505'  in gpid then grm_1 := 105 else     // 105- Dry Grazing                                                
//    If '102506'  in gpid then grm_1 := 106 else     // 106- Productivity Forest Land                                   
//    If '102507'  in gpid then grm_1 := 107 else     // 107- Bare Forest Land                                           
//    If '102508'  in gpid then grm_1 := 108 else     // 108- Speculative Homesite                                       
//    If '102509'  in gpid then grm_1 := 109 else     // 109- Agri greenhouses                                           
//    If '102510'  in gpid then grm_1 := 110 else     // 110- Agri Homesite Land                                         
//    If '102511'  in gpid then grm_1 := 111 else     // 111
//    If '102512'  in gpid then grm_1 := 112 else     // 112
//    If '102513'  in gpid then grm_1 := 113 else     // 113
//    If '102514'  in gpid then grm_1 := 114 else     // 114
//    If '102515'  in gpid then grm_1 := 115 else     // 115
//    If '102516'  in gpid then grm_1 := 116 else     // 116
//    If '102517'  in gpid then grm_1 := 117 else     // 117
//    If '102518'  in gpid then grm_1 := 118 else     // 118- Other Rural Land                                           
//    If '102519'  in gpid then grm_1 := 119 else     // 119 - Waste                                                     
//    If '102520'  in gpid then grm_1 := 120 else     // 120- Agri timber                                                
//    If '102521'  in gpid then grm_1 := 121 else     // 121
//    If '102522'  in gpid then grm_1 := 122 else     // 122
//    If '102523'  in gpid then grm_1 := 123 else     // 123
//    If '102524'  in gpid then grm_1 := 124 else     // 124
//    If '102525'  in gpid then grm_1 := 125 else     // 125
//    If '102526'  in gpid then grm_1 := 126 else     // 126
//    If '102527'  in gpid then grm_1 := 127 else     // 127
//    If '102528'  in gpid then grm_1 := 128 else     // 128
//    If '102529'  in gpid then grm_1 := 129 else     // 129
//    If '102530'  in gpid then grm_1 := 130 else     // 130
//    If '102531'  in gpid then grm_1 := 131 else     // Residential Improv on Cat 10                                    
//    If '102532'  in gpid then grm_1 := 132 else     // Non-Residential Improv Cat 10                                   
//    If '102533'  in gpid then grm_1 := 133 else     // 133
//    If '102534'  in gpid then grm_1 := 134 else     // 134
//    If '102535'  in gpid then grm_1 := 135 else     // 135
//    If '102536'  in gpid then grm_1 := 136 else     // 136
//    If '102537'  in gpid then grm_1 := 137 else     // 137
//    If '102538'  in gpid then grm_1 := 138 else     // 138
//    If '102539'  in gpid then grm_1 := 139 else     // 139
//    If '102540'  in gpid then grm_1 := 140 else     // 140
//    If '102541'  in gpid then grm_1 := 141 else     // 141
//    If '102542'  in gpid then grm_1 := 142 else     // 142
//    If '102543'  in gpid then grm_1 := 143 else     // 143
//    If '102544'  in gpid then grm_1 := 144 else     // 144
//    If '102545'  in gpid then grm_1 := 145 else     // 145
//    If '102546'  in gpid then grm_1 := 146 else     // 146
//    If '102547'  in gpid then grm_1 := 147 else     // 147
//    If '102548'  in gpid then grm_1 := 148 else     // MH Real Cat 10                                                  
//    If '102549'  in gpid then grm_1 := 149 else     // 149
//    If '102550'  in gpid then grm_1 := 150 else     // 150
//    If '102551'  in gpid then grm_1 := 151 else     // 151
//    If '102552'  in gpid then grm_1 := 152 else     // 152
//    If '102553'  in gpid then grm_1 := 153 else     // 153
//    If '102554'  in gpid then grm_1 := 154 else     // 154
//    If '102555'  in gpid then grm_1 := 155 else     // 155
//    If '102556'  in gpid then grm_1 := 156 else     // 156
//    If '102557'  in gpid then grm_1 := 157 else     // 157-Equities in State Land                                      
//    If '102558'  in gpid then grm_1 := 158 else     // 158
//    If '102559'  in gpid then grm_1 := 159 else     // 159
//    If '102560'  in gpid then grm_1 := 160 else     // 160
//    If '102561'  in gpid then grm_1 := 161 else     // 161- Ag Imp/Leased Land                                         
//    If '102562'  in gpid then grm_1 := 162 else     // 162
//    If '102563'  in gpid then grm_1 := 163 else     // 163
//    If '102564'  in gpid then grm_1 := 164 else     // 164
//    If '102565'  in gpid then grm_1 := 165 else     // 165
//    If '102566'  in gpid then grm_1 := 166 else     // 166
//    If '102567'  in gpid then grm_1 := 167 else     // 167
//    If '102568'  in gpid then grm_1 := 168 else     // 168
//    If '102569'  in gpid then grm_1 := 169 else     // 169
//    If '102570'  in gpid then grm_1 := 170 else     // 170
//    If '102571'  in gpid then grm_1 := 171 else     // 171
//    If '102572'  in gpid then grm_1 := 172 else     // 172
//    If '102573'  in gpid then grm_1 := 173 else     // 173
//    If '102574'  in gpid then grm_1 := 174 else     // 174
//    If '102575'  in gpid then grm_1 := 175 else     // 175
//    If '102576'  in gpid then grm_1 := 176 else     // 176
//    If '102577'  in gpid then grm_1 := 177 else     // 177
//    If '102578'  in gpid then grm_1 := 178 else     // 178
//    If '102579'  in gpid then grm_1 := 179 else     // 179
//    If '102580'  in gpid then grm_1 := 180 else     // 180
//    If '102581'  in gpid then grm_1 := 181 else     // 181- Ag (not classified)                                        
//    If '102582'  in gpid then grm_1 := 182 else     // 182- Ag related activities                                      
//    If '102583'  in gpid then grm_1 := 183 else     // 183- Ag classified in O.S.                                      
//    If '102584'  in gpid then grm_1 := 184 else     // 184
//    If '102585'  in gpid then grm_1 := 185 else     // 185
//    If '102586'  in gpid then grm_1 := 186 else     // 186
//    If '102587'  in gpid then grm_1 := 187 else     // 187
//    If '102588'  in gpid then grm_1 := 188 else     // 188
//    If '102589'  in gpid then grm_1 := 189 else     // 189
//    If '102590'  in gpid then grm_1 := 190 else     // 190
//    If '102591'  in gpid then grm_1 := 191 else     // 191- Undetermined                                               
//    If '102592'  in gpid then grm_1 := 192 else     // 192
//    If '102593'  in gpid then grm_1 := 193 else     // 193
//    If '102594'  in gpid then grm_1 := 194 else     // 194- Open space                                                 
//    If '102595'  in gpid then grm_1 := 195 else     // 195
//    If '102596'  in gpid then grm_1 := 196 else     // 196
//    If '102597'  in gpid then grm_1 := 197 else     // 197
//    If '102598'  in gpid then grm_1 := 198 else     // 198
//    If '102599'  in gpid then grm_1 := 199 else     // 199-Other undeveloped land                                      
//    If '102600'  in gpid then grm_1 := 200 else     // 200- Mineral                                                    
//    If '102601'  in gpid then grm_1 := 201 else     // 201
//    If '102602'  in gpid then grm_1 := 202 else     // 202
//    If '102603'  in gpid then grm_1 := 203 else     // 203
//    If '102604'  in gpid then grm_1 := 204 else     // 204
//    If '102605'  in gpid then grm_1 := 205 else     // 205
//    If '102606'  in gpid then grm_1 := 206 else     // 206
//    If '102607'  in gpid then grm_1 := 207 else     // 207
//    If '102608'  in gpid then grm_1 := 208 else     // 208
//    If '102609'  in gpid then grm_1 := 209 else     // 209- Mineral land                                               
//    If '102610'  in gpid then grm_1 := 210 else     // 210
//    If '102611'  in gpid then grm_1 := 211 else     // 211
//    If '102612'  in gpid then grm_1 := 212 else     // 212
//    If '102613'  in gpid then grm_1 := 213 else     // 213
//    If '102614'  in gpid then grm_1 := 214 else     // 214
//    If '102615'  in gpid then grm_1 := 215 else     // 215
//    If '102616'  in gpid then grm_1 := 216 else     // 216
//    If '102617'  in gpid then grm_1 := 217 else     // 217
//    If '102618'  in gpid then grm_1 := 218 else     // 218
//    If '102619'  in gpid then grm_1 := 219 else     // 219
//    If '102620'  in gpid then grm_1 := 220 else     // 220
//    If '102621'  in gpid then grm_1 := 221 else     // 221
//    If '102622'  in gpid then grm_1 := 222 else     // 222
//    If '102623'  in gpid then grm_1 := 223 else     // 223
//    If '102624'  in gpid then grm_1 := 224 else     // 224
//    If '102625'  in gpid then grm_1 := 225 else     // 225
//    If '102626'  in gpid then grm_1 := 226 else     // 226
//    If '102627'  in gpid then grm_1 := 227 else     // 227
//    If '102628'  in gpid then grm_1 := 228 else     // 228
//    If '102629'  in gpid then grm_1 := 229 else     // 229
//    If '102630'  in gpid then grm_1 := 230 else     // 230
//    If '102631'  in gpid then grm_1 := 231 else     // 231
//    If '102632'  in gpid then grm_1 := 232 else     // 232
//    If '102633'  in gpid then grm_1 := 233 else     // 233
//    If '102634'  in gpid then grm_1 := 234 else     // 234
//    If '102635'  in gpid then grm_1 := 235 else     // 235
//    If '102636'  in gpid then grm_1 := 236 else     // 236
//    If '102637'  in gpid then grm_1 := 237 else     // 237
//    If '102638'  in gpid then grm_1 := 238 else     // 238
//    If '102639'  in gpid then grm_1 := 239 else     // 239
//    If '102640'  in gpid then grm_1 := 240 else     // 240
//    If '102641'  in gpid then grm_1 := 241 else     // 241
//    If '102642'  in gpid then grm_1 := 242 else     // 242
//    If '102643'  in gpid then grm_1 := 243 else     // 243
//    If '102644'  in gpid then grm_1 := 244 else     // 244
//    If '102645'  in gpid then grm_1 := 245 else     // 245
//    If '102646'  in gpid then grm_1 := 246 else     // 246
//    If '102647'  in gpid then grm_1 := 247 else     // 247
//    If '102648'  in gpid then grm_1 := 248 else     // 248
//    If '102649'  in gpid then grm_1 := 249 else     // 249
//    If '102650'  in gpid then grm_1 := 250 else     // 250
//    If '102651'  in gpid then grm_1 := 251 else     // 251
//    If '102652'  in gpid then grm_1 := 252 else     // 252
//    If '102653'  in gpid then grm_1 := 253 else     // 253
//    If '102654'  in gpid then grm_1 := 254 else     // 254
//    If '102655'  in gpid then grm_1 := 255 else     // 255
//    If '102656'  in gpid then grm_1 := 256 else     // 256
//    If '102657'  in gpid then grm_1 := 257 else     // 257
//    If '102658'  in gpid then grm_1 := 258 else     // 258
//    If '102659'  in gpid then grm_1 := 259 else     // 259
//    If '102660'  in gpid then grm_1 := 260 else     // 260
//    If '102661'  in gpid then grm_1 := 261 else     // 261
//    If '102662'  in gpid then grm_1 := 262 else     // 262
//    If '102663'  in gpid then grm_1 := 263 else     // 263
//    If '102664'  in gpid then grm_1 := 264 else     // 264
//    If '102665'  in gpid then grm_1 := 265 else     // 265
//    If '102673'  in gpid then grm_1 := 270 else     // 270- Mineral Rights                                             
//    If '1300000'  in gpid then grm_1 := 272 else     // 272
//    If '1304130'  in gpid then grm_1 := 273 else     // 273
//    If '1306099'  in gpid then grm_1 := 274 else     // 274
//    If '1306100'  in gpid then grm_1 := 275 else     // 275
//    If '1306101'  in gpid then grm_1 := 276 else     // 276
//    If '1306102'  in gpid then grm_1 := 277 else     // 277
//    If '1306103'  in gpid then grm_1 := 278 else     // 278
//    If '1306104'  in gpid then grm_1 := 279 else     // 279
//    If '1306105'  in gpid then grm_1 := 280 else     // 280
//    If '1306106'  in gpid then grm_1 := 281 else     // 281
//    If '1306107'  in gpid then grm_1 := 282 else     // 282
//    If '1306108'  in gpid then grm_1 := 283 else     // 283
//    If '1306109'  in gpid then grm_1 := 284 else     // 284
//    If '1306110'  in gpid then grm_1 := 285 else     // 285- Mining related-gravel                                      
//    If '1306111'  in gpid then grm_1 := 286 else     // 286
//    If '1306112'  in gpid then grm_1 := 287 else     // 287
//    If '1306113'  in gpid then grm_1 := 288 else     // 288
//    If '1306114'  in gpid then grm_1 := 289 else     // 289
//    If '1306115'  in gpid then grm_1 := 290 else     // 290
//    If '1306116'  in gpid then grm_1 := 291 else     // 291
//    If '1306117'  in gpid then grm_1 := 292 else     // 292
//    If '1306118'  in gpid then grm_1 := 293 else     // 293
//    If '1306119'  in gpid then grm_1 := 294 else     // 294
//    If '1306120'  in gpid then grm_1 := 295 else     // 295
//    If '1306121'  in gpid then grm_1 := 296 else     // 296
//    If '1306122'  in gpid then grm_1 := 297 else     // 297
//    If '1306123'  in gpid then grm_1 := 298 else     // 298
//    If '1306124'  in gpid then grm_1 := 299 else     // 299
//    If '1306125'  in gpid then grm_1 := 300 else     // 300- Industrial Vac land                                        
//    If '1306126'  in gpid then grm_1 := 301 else     // 301- Industrial general class                                   
//    If '1306127'  in gpid then grm_1 := 302 else     // 302
//    If '1306128'  in gpid then grm_1 := 303 else     // 303
//    If '1306129'  in gpid then grm_1 := 304 else     // 304
//    If '1306130'  in gpid then grm_1 := 305 else     // 305
//    If '1306131'  in gpid then grm_1 := 306 else     // 306
//    If '1306132'  in gpid then grm_1 := 307 else     // 307
//    If '1306133'  in gpid then grm_1 := 308 else     // 308
//    If '1306134'  in gpid then grm_1 := 309 else     // 309
//    If '1306135'  in gpid then grm_1 := 310 else     // 310- Industrial Food - drink                                    
//    If '1306136'  in gpid then grm_1 := 311 else     // 314- Rural indust land tract                                    
//    If '1306137'  in gpid then grm_1 := 312 else     // 312
//    If '1306138'  in gpid then grm_1 := 313 else     // 313
//    If '1306139'  in gpid then grm_1 := 314 else     // 314- Rural indust land tract                                    
//    If '1306140'  in gpid then grm_1 := 315 else     // 315
//    If '1306141'  in gpid then grm_1 := 316 else     // 316
//    If '1306142'  in gpid then grm_1 := 317 else     // 317- Rural indust subdivision                                   
//    If '1306143'  in gpid then grm_1 := 318 else     // 318
//    If '1306144'  in gpid then grm_1 := 319 else     // 319
//    If '1306145'  in gpid then grm_1 := 320 else     // 320 Ind foundries/hvy mfg                                       
//    If '1306146'  in gpid then grm_1 := 321 else     // 321- Food & kindred products                                    
//    If '1306147'  in gpid then grm_1 := 322 else     // 322- Indust City tract/lot                                      
//    If '1306148'  in gpid then grm_1 := 323 else     // 323- Apparel & fin. prdcts                                      
//    If '1306149'  in gpid then grm_1 := 324 else     // 324
//    If '1306150'  in gpid then grm_1 := 325 else     // 325
//    If '1306151'  in gpid then grm_1 := 326 else     // 3- Paper and allied products                                    
//    If '1306152'  in gpid then grm_1 := 327 else     // 3- Printing and publishing                                      
//    If '1306153'  in gpid then grm_1 := 328 else     // 3- Chemicals                                                    
//    If '1306154'  in gpid then grm_1 := 329 else     // 3- Petroleum refining & rel                                     
//    If '1306155'  in gpid then grm_1 := 330 else     // Ind med mfg & assembly                                          
//    If '1306156'  in gpid then grm_1 := 331 else     // 3- Rubber/misc plastic prod                                     
//    If '1306157'  in gpid then grm_1 := 332 else     // 3- Stone                                                        
//    If '1306158'  in gpid then grm_1 := 333 else     // 3- Primary metal industries                                     
//    If '1306159'  in gpid then grm_1 := 334 else     // 3- Fabricated metal products                                    
//    If '1306160'  in gpid then grm_1 := 335 else     // 3- Prof. scientific                                             
//    If '1306161'  in gpid then grm_1 := 336 else     // 336
//    If '1306162'  in gpid then grm_1 := 337 else     // 337
//    If '1306163'  in gpid then grm_1 := 338 else     // 338
//    If '1306164'  in gpid then grm_1 := 339 else     // 3- Misc manufacturing                                           
//    If '1306165'  in gpid then grm_1 := 340 else     // Industrial lt mfg & assembly                                    
//    If '1306166'  in gpid then grm_1 := 341 else     // 341
//    If '1306167'  in gpid then grm_1 := 342 else     // 342
//    If '1306168'  in gpid then grm_1 := 343 else     // 343
//    If '1306169'  in gpid then grm_1 := 344 else     // 344
//    If '1306170'  in gpid then grm_1 := 345 else     // 345
//    If '1306171'  in gpid then grm_1 := 346 else     // 346
//    If '1306172'  in gpid then grm_1 := 347 else     // 347
//    If '1306173'  in gpid then grm_1 := 348 else     // 348
//    If '1306174'  in gpid then grm_1 := 349 else     // 349
//    If '1306175'  in gpid then grm_1 := 350 else     // Industrial warehouse                                            
//    If '1306176'  in gpid then grm_1 := 351 else     // 351
//    If '1306177'  in gpid then grm_1 := 352 else     // 352
//    If '1306178'  in gpid then grm_1 := 353 else     // 353
//    If '1306179'  in gpid then grm_1 := 354 else     // 354
//    If '1306180'  in gpid then grm_1 := 355 else     // 355
//    If '1306181'  in gpid then grm_1 := 356 else     // 356
//    If '1306182'  in gpid then grm_1 := 357 else     // 357
//    If '1306183'  in gpid then grm_1 := 358 else     // 358
//    If '1306184'  in gpid then grm_1 := 359 else     // 359
//    If '1306185'  in gpid then grm_1 := 360 else     // 360-Ind Bldg on RR r/w                                          
//    If '1306186'  in gpid then grm_1 := 361 else     // 361
//    If '1306187'  in gpid then grm_1 := 362 else     // 362
//    If '1306188'  in gpid then grm_1 := 363 else     // 363
//    If '1306189'  in gpid then grm_1 := 364 else     // 364
//    If '1306190'  in gpid then grm_1 := 365 else     // 365
//    If '1306191'  in gpid then grm_1 := 366 else     // 366
//    If '1306192'  in gpid then grm_1 := 367 else     // 367
//    If '1306193'  in gpid then grm_1 := 368 else     // 368
//    If '1306194'  in gpid then grm_1 := 369 else     // 369
//    If '1306195'  in gpid then grm_1 := 370 else     // Industrial small shops                                          
//    If '1306196'  in gpid then grm_1 := 371 else     // 371
//    If '1306197'  in gpid then grm_1 := 372 else     // 372
//    If '1306198'  in gpid then grm_1 := 373 else     // 373
//    If '1306199'  in gpid then grm_1 := 374 else     // 374
//    If '1306200'  in gpid then grm_1 := 375 else     // 375
//    If '1306201'  in gpid then grm_1 := 376 else     // 376
//    If '1306202'  in gpid then grm_1 := 377 else     // 377
//    If '1306203'  in gpid then grm_1 := 378 else     // 378
//    If '1306204'  in gpid then grm_1 := 379 else     // 379
//    If '1306205'  in gpid then grm_1 := 380 else     // Industrial mines & quarries                                     
//    If '1306206'  in gpid then grm_1 := 381 else     // 381
//    If '1306207'  in gpid then grm_1 := 382 else     // 382
//    If '1306208'  in gpid then grm_1 := 383 else     // 383
//    If '1306209'  in gpid then grm_1 := 384 else     // 384
//    If '1306210'  in gpid then grm_1 := 385 else     // 385
//    If '1306211'  in gpid then grm_1 := 386 else     // 386
//    If '1306212'  in gpid then grm_1 := 387 else     // 387
//    If '1306213'  in gpid then grm_1 := 388 else     // 388
//    If '1306214'  in gpid then grm_1 := 389 else     // 389
//    If '1306215'  in gpid then grm_1 := 390 else     // Industrial grain elevators                                      
//    If '1306216'  in gpid then grm_1 := 391 else     // 3- Undeveloped land                                             
//    If '1306217'  in gpid then grm_1 := 392 else     // 392
//    If '1306218'  in gpid then grm_1 := 393 else     // 393
//    If '1306219'  in gpid then grm_1 := 394 else     // 394
//    If '1306220'  in gpid then grm_1 := 395 else     // 395
//    If '1306221'  in gpid then grm_1 := 396 else     // 396
//    If '1306222'  in gpid then grm_1 := 397 else     // 397
//    If '1306223'  in gpid then grm_1 := 398 else     // 398
//    If '1306224'  in gpid then grm_1 := 399 else     // Indust other structures                                         
//    If '1306225'  in gpid then grm_1 := 400 else     // Commercial vacant land                                          
//    If '1306226'  in gpid then grm_1 := 401 else     // Commercial general class                                        
//    If '1306227'  in gpid then grm_1 := 402 else     // Commercially classified apts                                    
//    If '1306228'  in gpid then grm_1 := 403 else     // Commercial 40+ family apts                                      
//    If '1306229'  in gpid then grm_1 := 404 else     // Commercial/Industrial Class                                     
//    If '1306230'  in gpid then grm_1 := 405 else     // 405
//    If '1306231'  in gpid then grm_1 := 406 else     // 406
//    If '1306232'  in gpid then grm_1 := 407 else     // 407
//    If '1306233'  in gpid then grm_1 := 408 else     // 408
//    If '1306234'  in gpid then grm_1 := 409 else     // 409
//    If '1306235'  in gpid then grm_1 := 410 else     // Com Motels                                                      
//    If '1306236'  in gpid then grm_1 := 411 else     // 411- Recreational                                               
//    If '1306237'  in gpid then grm_1 := 412 else     // Com Hospitals/Nurs hms                                          
//    If '1306238'  in gpid then grm_1 := 413 else     // 413- Rural commercial tracts                                    
//    If '1306239'  in gpid then grm_1 := 414 else     // 4- Res. Hotels-Condos                                           
//    If '1306240'  in gpid then grm_1 := 415 else     // 415- Mobile home parks                                          
//    If '1306241'  in gpid then grm_1 := 416 else     // 416- Rural commercial subdiv                                    
//    If '1306242'  in gpid then grm_1 := 417 else     // 417
//    If '1306243'  in gpid then grm_1 := 418 else     // 418
//    If '1306244'  in gpid then grm_1 := 419 else     // Com Other housing                                               
//    If '1306245'  in gpid then grm_1 := 420 else     // Com Small retail                                                
//    If '1306246'  in gpid then grm_1 := 421 else     // 421- Commercial lot/ac in city                                  
//    If '1306247'  in gpid then grm_1 := 422 else     // Com Discount department store                                   
//    If '1306248'  in gpid then grm_1 := 423 else     // 423
//    If '1306249'  in gpid then grm_1 := 424 else     // Com Full line dept store                                        
//    If '1306250'  in gpid then grm_1 := 425 else     // 425- Commercial Common Area                                     
//    If '1306251'  in gpid then grm_1 := 426 else     // 426- Commercial Condo                                           
//    If '1306252'  in gpid then grm_1 := 427 else     // 427-                                                            
//    If '1306253'  in gpid then grm_1 := 428 else     // 428
//    If '1306254'  in gpid then grm_1 := 429 else     // Com Other retail buildings                                      
//    If '1306255'  in gpid then grm_1 := 430 else     // Com Restaurant/bar                                              
//    If '1306256'  in gpid then grm_1 := 431 else     // 431
//    If '1306257'  in gpid then grm_1 := 432 else     // 432
//    If '1306258'  in gpid then grm_1 := 433 else     // 433
//    If '1306259'  in gpid then grm_1 := 434 else     // 434
//    If '1306260'  in gpid then grm_1 := 435 else     // Com DriveIn restaurant                                          
//    If '1306261'  in gpid then grm_1 := 436 else     // 436
//    If '1306262'  in gpid then grm_1 := 437 else     // 437
//    If '1306263'  in gpid then grm_1 := 438 else     // 438
//    If '1306264'  in gpid then grm_1 := 439 else     // Com Other food service                                          
//    If '1306265'  in gpid then grm_1 := 440 else     // Com Dry clean/laundry                                           
//    If '1306266'  in gpid then grm_1 := 441 else     // Com Funeral home                                                
//    If '1306267'  in gpid then grm_1 := 442 else     // Com Medical clinic/offices                                      
//    If '1306268'  in gpid then grm_1 := 443 else     // 443
//    If '1306269'  in gpid then grm_1 := 444 else     // Com Full service banks                                          
//    If '1306270'  in gpid then grm_1 := 445 else     // Com Savings and loans                                           
//    If '1306271'  in gpid then grm_1 := 446 else     // 446
//    If '1306272'  in gpid then grm_1 := 447 else     // Com 1 and 2 story off bldgs                                     
//    If '1306273'  in gpid then grm_1 := 448 else     // Com Office O/T 47 walkup                                        
//    If '1306274'  in gpid then grm_1 := 449 else     // Com Office O/T 47 elev                                          
//    If '1306275'  in gpid then grm_1 := 450 else     // 450
//    If '1306276'  in gpid then grm_1 := 451 else     // 4- Wholesale trade                                              
//    If '1306277'  in gpid then grm_1 := 452 else     // 4- RT--bldg matrl                                               
//    If '1306278'  in gpid then grm_1 := 453 else     // 4- RT general merchandise                                       
//    If '1306279'  in gpid then grm_1 := 454 else     // 4- RT food                                                      
//    If '1306280'  in gpid then grm_1 := 455 else     // 4- RT auto                                                      
//    If '1306281'  in gpid then grm_1 := 456 else     // 4- RT apparel and accessories                                   
//    If '1306282'  in gpid then grm_1 := 457 else     // 4- RT furniture                                                 
//    If '1306283'  in gpid then grm_1 := 458 else     // 4- RT eating and drinking                                       
//    If '1306284'  in gpid then grm_1 := 459 else     // 4- Other retail trade                                           
//    If '1306285'  in gpid then grm_1 := 460 else     // 460-Comm Imps/Railroad R/W                                      
//    If '1306286'  in gpid then grm_1 := 461 else     // 461-Comm imps/leased land                                       
//    If '1306287'  in gpid then grm_1 := 462 else     // 462-Comm imps/exempt land                                       
//    If '1306288'  in gpid then grm_1 := 463 else     // 4- Business services                                            
//    If '1306289'  in gpid then grm_1 := 464 else     // 4- Repair services                                              
//    If '1306290'  in gpid then grm_1 := 465 else     // 4- Professional services                                        
//    If '1306291'  in gpid then grm_1 := 466 else     // 4- Contract constrctn svcs                                      
//    If '1306292'  in gpid then grm_1 := 467 else     // 4- Governmental services                                        
//    If '1306293'  in gpid then grm_1 := 468 else     // 4- Educational services                                         
//    If '1306294'  in gpid then grm_1 := 469 else     // 4- Miscellaneous services                                       
//    If '1306295'  in gpid then grm_1 := 470 else     // 470
//    If '1306296'  in gpid then grm_1 := 471 else     // 471
//    If '1306297'  in gpid then grm_1 := 472 else     // 4- Public assembly                                              
//    If '1306298'  in gpid then grm_1 := 473 else     // 4- Amusements                                                   
//    If '1306299'  in gpid then grm_1 := 474 else     // 4- Recreational activities                                      
//    If '1306300'  in gpid then grm_1 := 475 else     // 4- Resorts & group camps                                        
//    If '1306301'  in gpid then grm_1 := 476 else     // 4- Parks                                                        
//    If '1306302'  in gpid then grm_1 := 477 else     // 477
//    If '1306303'  in gpid then grm_1 := 478 else     // 478
//    If '1306304'  in gpid then grm_1 := 479 else     // 4- Other cult                                                   
//    If '1306305'  in gpid then grm_1 := 480 else     // Com Warehouse                                                   
//    If '1306306'  in gpid then grm_1 := 481 else     // 481
//    If '1306307'  in gpid then grm_1 := 482 else     // Com Truck terminals                                             
//    If '1306308'  in gpid then grm_1 := 483 else     // 483
//    If '1306309'  in gpid then grm_1 := 484 else     // 484
//    If '1306310'  in gpid then grm_1 := 485 else     // 485
//    If '1306311'  in gpid then grm_1 := 486 else     // 486
//    If '1306312'  in gpid then grm_1 := 487 else     // 487
//    If '1306313'  in gpid then grm_1 := 488 else     // 488
//    If '1306314'  in gpid then grm_1 := 489 else     // 489
//    If '1306315'  in gpid then grm_1 := 490 else     // Com Marine service facility                                     
//    If '1306316'  in gpid then grm_1 := 491 else     // 4- Undeveloped land                                             
//    If '1306317'  in gpid then grm_1 := 492 else     // 492
//    If '1306318'  in gpid then grm_1 := 493 else     // 493
//    If '1306319'  in gpid then grm_1 := 494 else     // 4- Open space                                                   
//    If '1306320'  in gpid then grm_1 := 495 else     // 495
//    If '1306321'  in gpid then grm_1 := 496 else     // Com Marina                                                      
//    If '1306322'  in gpid then grm_1 := 497 else     // 497
//    If '1306323'  in gpid then grm_1 := 498 else     // 498
//    If '1306324'  in gpid then grm_1 := 499 else     // 499- Commercial other                                           
//    If '1306325'  in gpid then grm_1 := 500 else     // Residential: Vacant lot                                         
//    If '1306326'  in gpid then grm_1 := 501 else     // Res Urban 1 family                                              
//    If '1306327'  in gpid then grm_1 := 502 else     // Res Suburban 1 fam to 19.99ac                                   
//    If '1306328'  in gpid then grm_1 := 503 else     // Res Multi-family                                                
//    If '1306329'  in gpid then grm_1 := 504 else     // Res vac unplatted 30-39.9ac                                     
//    If '1306330'  in gpid then grm_1 := 505 else     // Res vac unplatted 20+Ac                                         
//    If '1306331'  in gpid then grm_1 := 506 else     // 506
//    If '1306332'  in gpid then grm_1 := 507 else     // 507
//    If '1306333'  in gpid then grm_1 := 508 else     // 508
//    If '1306334'  in gpid then grm_1 := 509 else     // 509
//    If '1306335'  in gpid then grm_1 := 510 else     // 510- Homesite non-agriculture                                   
//    If '1306336'  in gpid then grm_1 := 511 else     // 5- Household                                                    
//    If '1306337'  in gpid then grm_1 := 512 else     // 512- Rural residential tracts                                   
//    If '1306338'  in gpid then grm_1 := 513 else     // Res 1 fam unplatted 20-29.99a                                   
//    If '1306339'  in gpid then grm_1 := 514 else     // Res 1 fam unplatted 30-39.99a                                   
//    If '1306340'  in gpid then grm_1 := 515 else     // 515- Rural resid subdivisions                                   
//    If '1306341'  in gpid then grm_1 := 516 else     // 516
//    If '1306342'  in gpid then grm_1 := 517 else     // 517
//    If '1306343'  in gpid then grm_1 := 518 else     // 518- Other Rual Land Improved                                   
//    If '1306344'  in gpid then grm_1 := 519 else     // 5- Vacation and cabin                                           
//    If '1306345'  in gpid then grm_1 := 520 else     // 520- Resid lots/tracts in city                                  
//    If '1306346'  in gpid then grm_1 := 521 else     // Res 2 fam unplatted 0-9.99 ac                                   
//    If '1306347'  in gpid then grm_1 := 522 else     // Res 2 fam unplatted 10-19.99a                                   
//    If '1306348'  in gpid then grm_1 := 523 else     // Res 2 fam unplatted 20-29.99a                                   
//    If '1306349'  in gpid then grm_1 := 524 else     // Res 2 fam unplatted 30-39.99a                                   
//    If '1306350'  in gpid then grm_1 := 525 else     // 525- Common areas- condo/tnhse                                  
//    If '1306351'  in gpid then grm_1 := 526 else     // 526 - Condominium                                               
//    If '1306352'  in gpid then grm_1 := 527 else     // 527
//    If '1306353'  in gpid then grm_1 := 528 else     // 528
//    If '1306354'  in gpid then grm_1 := 529 else     // 529
//    If '1306355'  in gpid then grm_1 := 530 else     // Res 3 family dwelling                                           
//    If '1306356'  in gpid then grm_1 := 531 else     // Res 3 fam unplatted 0-9.99 ac                                   
//    If '1306357'  in gpid then grm_1 := 532 else     // Res 3 fam unplatted 10-19.99a                                   
//    If '1306358'  in gpid then grm_1 := 533 else     // Res 3 fam unplatted 20-29.99a                                   
//    If '1306359'  in gpid then grm_1 := 534 else     // Res 3 fam unplatted 30-39.99a                                   
//    If '1306360'  in gpid then grm_1 := 535 else     // Res 3 fam unplatted 40+ ac                                      
//    If '1306361'  in gpid then grm_1 := 536 else     // 536
//    If '1306362'  in gpid then grm_1 := 537 else     // 537
//    If '1306363'  in gpid then grm_1 := 538 else     // 538
//    If '1306364'  in gpid then grm_1 := 539 else     // 539
//    If '1306365'  in gpid then grm_1 := 540 else     // 540- Other Rural Land Improved                                  
//    If '1306366'  in gpid then grm_1 := 541 else     // Res mobile home on 0-9.99 ac                                    
//    If '1306367'  in gpid then grm_1 := 542 else     // Res mobile home on 10-19.99 a                                   
//    If '1306368'  in gpid then grm_1 := 543 else     // Res Trailer unplat 10-19.99 a                                   
//    If '1306369'  in gpid then grm_1 := 544 else     // Res Trailer unplat 30-39.99 a                                   
//    If '1306370'  in gpid then grm_1 := 545 else     // Res Trailer unplatted 40+ ac                                    
//    If '1306371'  in gpid then grm_1 := 546 else     // 546 - Manuf housing                                             
//    If '1306372'  in gpid then grm_1 := 547 else     // 547
//    If '1306373'  in gpid then grm_1 := 548 else     // 548- M H on Real Property                                       
//    If '1306374'  in gpid then grm_1 := 549 else     // 549- M H on Leased Land                                         
//    If '1306375'  in gpid then grm_1 := 550 else     // Res condominium                                                 
//    If '1306376'  in gpid then grm_1 := 551 else     // Res Condo unplatted 0-9.99 ac                                   
//    If '1306377'  in gpid then grm_1 := 552 else     // Res Condo unplatted 10-19.99a                                   
//    If '1306378'  in gpid then grm_1 := 553 else     // Res Condo unplatted 20-29.99a                                   
//    If '1306379'  in gpid then grm_1 := 554 else     // Res Condo unplatted 30-39.99a                                   
//    If '1306380'  in gpid then grm_1 := 555 else     // Res Condo unplatted 40+ ac                                      
//    If '1306381'  in gpid then grm_1 := 556 else     // 556
//    If '1306382'  in gpid then grm_1 := 557 else     // 557
//    If '1306383'  in gpid then grm_1 := 558 else     // 558
//    If '1306384'  in gpid then grm_1 := 559 else     // 559
//    If '1306385'  in gpid then grm_1 := 560 else     // 560
//    If '1306386'  in gpid then grm_1 := 561 else     // 561-Res imps/leased land                                        
//    If '1306387'  in gpid then grm_1 := 562 else     // 562-Res imps/exempt land                                        
//    If '1306388'  in gpid then grm_1 := 563 else     // 563
//    If '1306389'  in gpid then grm_1 := 564 else     // 564
//    If '1306390'  in gpid then grm_1 := 565 else     // 565 - Manuf housing personal                                    
//    If '1306391'  in gpid then grm_1 := 566 else     // 566
//    If '1306392'  in gpid then grm_1 := 567 else     // 567
//    If '1306393'  in gpid then grm_1 := 568 else     // 568
//    If '1306394'  in gpid then grm_1 := 569 else     // 569
//    If '1306395'  in gpid then grm_1 := 570 else     // 570
//    If '1306396'  in gpid then grm_1 := 571 else     // 571
//    If '1306397'  in gpid then grm_1 := 572 else     // 572
//    If '1306398'  in gpid then grm_1 := 573 else     // 573
//    If '1306399'  in gpid then grm_1 := 574 else     // 574
//    If '1306400'  in gpid then grm_1 := 575 else     // 575
//    If '1306401'  in gpid then grm_1 := 576 else     // 576
//    If '1306402'  in gpid then grm_1 := 577 else     // 577
//    If '1306403'  in gpid then grm_1 := 578 else     // 578
//    If '1306404'  in gpid then grm_1 := 579 else     // 579
//    If '1306405'  in gpid then grm_1 := 580 else     // 580
//    If '1306406'  in gpid then grm_1 := 581 else     // 581
//    If '1306407'  in gpid then grm_1 := 582 else     // 582
//    If '1306408'  in gpid then grm_1 := 583 else     // 583
//    If '1306409'  in gpid then grm_1 := 584 else     // 584
//    If '1306410'  in gpid then grm_1 := 585 else     // 585
//    If '1306411'  in gpid then grm_1 := 586 else     // 586
//    If '1306412'  in gpid then grm_1 := 587 else     // 587
//    If '1306413'  in gpid then grm_1 := 588 else     // 588
//    If '1306414'  in gpid then grm_1 := 589 else     // 589
//    If '1306415'  in gpid then grm_1 := 590 else     // 590
//    If '1306416'  in gpid then grm_1 := 591 else     // 5- Undeveloped land                                             
//    If '1306417'  in gpid then grm_1 := 592 else     // 592
//    If '1306418'  in gpid then grm_1 := 593 else     // 593
//    If '1306419'  in gpid then grm_1 := 594 else     // 5- Open space                                                   
//    If '1306420'  in gpid then grm_1 := 595 else     // 595
//    If '1306421'  in gpid then grm_1 := 596 else     // 596
//    If '1306422'  in gpid then grm_1 := 597 else     // 597
//    If '1306423'  in gpid then grm_1 := 598 else     // 598
//    If '1306424'  in gpid then grm_1 := 599 else     // Residential other                                               
//    If '1306425'  in gpid then grm_1 := 600 else     // 6- USA                                                          
//    If '1306426'  in gpid then grm_1 := 601 else     // 6- Federal Govt                                                 
//    If '1306427'  in gpid then grm_1 := 602 else     // 6- State Govt                                                   
//    If '1306428'  in gpid then grm_1 := 603 else     // 6- Local Govt                                                   
//    If '1306429'  in gpid then grm_1 := 604 else     // 6- Municipality                                                 
//    If '1306430'  in gpid then grm_1 := 605 else     // 6- Religious                                                    
//    If '1306431'  in gpid then grm_1 := 606 else     // 6- Educational                                                  
//    If '1306432'  in gpid then grm_1 := 607 else     // 6- Hospital District                                            
//    If '1306433'  in gpid then grm_1 := 608 else     // 6- Charities                                                    
//    If '1306434'  in gpid then grm_1 := 609 else     // 6- Other                                                        
//    If '1306435'  in gpid then grm_1 := 610 else     // 6- Churches                                                     
//    If '1306436'  in gpid then grm_1 := 611 else     // 6- Cemeteries                                                   
//    If '1306437'  in gpid then grm_1 := 612 else     // 612
//    If '1306438'  in gpid then grm_1 := 613 else     // 613
//    If '1306439'  in gpid then grm_1 := 614 else     // 614
//    If '1306440'  in gpid then grm_1 := 615 else     // 615
//    If '1306441'  in gpid then grm_1 := 616 else     // 616
//    If '1306442'  in gpid then grm_1 := 617 else     // 617
//    If '1306443'  in gpid then grm_1 := 618 else     // 618
//    If '1306444'  in gpid then grm_1 := 619 else     // 619- Public Right-of-Way                                        
//    If '1306445'  in gpid then grm_1 := 620 else     // 620
//    If '1306446'  in gpid then grm_1 := 621 else     // 621
//    If '1306447'  in gpid then grm_1 := 622 else     // 622
//    If '1306448'  in gpid then grm_1 := 623 else     // 623
//    If '1306449'  in gpid then grm_1 := 624 else     // 624- Public or exempt land                                      
//    If '1306450'  in gpid then grm_1 := 625 else     // 625
//    If '1306451'  in gpid then grm_1 := 626 else     // 626
//    If '1306452'  in gpid then grm_1 := 627 else     // 627
//    If '1306453'  in gpid then grm_1 := 628 else     // 628
//    If '1306454'  in gpid then grm_1 := 629 else     // 629
//    If '1306455'  in gpid then grm_1 := 630 else     // 630
//    If '1306456'  in gpid then grm_1 := 631 else     // 631
//    If '1306457'  in gpid then grm_1 := 632 else     // 632
//    If '1306458'  in gpid then grm_1 := 633 else     // 633
//    If '1306459'  in gpid then grm_1 := 634 else     // 634
//    If '1306460'  in gpid then grm_1 := 635 else     // 635
//    If '1306461'  in gpid then grm_1 := 636 else     // 636
//    If '1306462'  in gpid then grm_1 := 637 else     // 637
//    If '1306463'  in gpid then grm_1 := 638 else     // 638
//    If '1306464'  in gpid then grm_1 := 639 else     // 639
//    If '1306465'  in gpid then grm_1 := 640 else     // 640
//    If '1306466'  in gpid then grm_1 := 641 else     // 641
//    If '1306467'  in gpid then grm_1 := 642 else     // 642
//    If '1306468'  in gpid then grm_1 := 643 else     // 643
//    If '1306469'  in gpid then grm_1 := 644 else     // 644
//    If '1306471'  in gpid then grm_1 := 645 else     // 645
//    If '1306472'  in gpid then grm_1 := 646 else     // 646
//    If '1306473'  in gpid then grm_1 := 647 else     // 647
//    If '1306474'  in gpid then grm_1 := 648 else     // 648
//    If '1306475'  in gpid then grm_1 := 649 else     // 649
//    If '1306476'  in gpid then grm_1 := 650 else     // 650
//    If '1306477'  in gpid then grm_1 := 651 else     // 651
//    If '1306478'  in gpid then grm_1 := 652 else     // 652
//    If '1306479'  in gpid then grm_1 := 653 else     // 653
//    If '1306480'  in gpid then grm_1 := 654 else     // 654
//    If '1306481'  in gpid then grm_1 := 655 else     // 655
//    If '1306482'  in gpid then grm_1 := 656 else     // 656
//    If '1306483'  in gpid then grm_1 := 657 else     // 657
//    If '1306484'  in gpid then grm_1 := 658 else     // 658
//    If '1306485'  in gpid then grm_1 := 659 else     // 659
//    If '1306486'  in gpid then grm_1 := 660 else     // 660
//    If '1306487'  in gpid then grm_1 := 661 else     // 661- Imp/RR or Exempt Land                                      
//    If '1306488'  in gpid then grm_1 := 662 else     // 662
//    If '1306489'  in gpid then grm_1 := 663 else     // 663
//    If '1306490'  in gpid then grm_1 := 664 else     // 664
//    If '1306491'  in gpid then grm_1 := 665 else     // 665
//    If '1306492'  in gpid then grm_1 := 666 else     // 666
//    If '1306493'  in gpid then grm_1 := 667 else     // 667- Operating property                                         
//    If '1306494'  in gpid then grm_1 := 668 else     // 668
//    If '1306495'  in gpid then grm_1 := 669 else     // 669
//    If '1306496'  in gpid then grm_1 := 670 else     // 670
//    If '1306497'  in gpid then grm_1 := 671 else     // 671
//    If '1306498'  in gpid then grm_1 := 672 else     // 672
//    If '1306499'  in gpid then grm_1 := 673 else     // 673- Water                                                      
//    If '1306500'  in gpid then grm_1 := 674 else     // 674
//    If '1306501'  in gpid then grm_1 := 675 else     // 675
//    If '1306502'  in gpid then grm_1 := 676 else     // 676
//    If '1306503'  in gpid then grm_1 := 677 else     // 677
//    If '1306504'  in gpid then grm_1 := 678 else     // 678
//    If '1306505'  in gpid then grm_1 := 679 else     // 679
//    If '1306506'  in gpid then grm_1 := 680 else     // 680
//    If '1306507'  in gpid then grm_1 := 681 else     // 681 - Exempt property                                           
//    If '1306508'  in gpid then grm_1 := 682 else     // 682
//    If '1306509'  in gpid then grm_1 := 683 else     // 683
//    If '1306510'  in gpid then grm_1 := 684 else     // 684
//    If '1306511'  in gpid then grm_1 := 685 else     // 685
//    If '1306512'  in gpid then grm_1 := 686 else     // 686
//    If '1306513'  in gpid then grm_1 := 687 else     // 687
//    If '1306514'  in gpid then grm_1 := 688 else     // 688
//    If '1306515'  in gpid then grm_1 := 689 else     // 689
//    If '1306516'  in gpid then grm_1 := 690 else     // 690
//    If '1306517'  in gpid then grm_1 := 691 else     // 691
//    If '1306518'  in gpid then grm_1 := 692 else     // 692
//    If '1306519'  in gpid then grm_1 := 693 else     // 693
//    If '1306520'  in gpid then grm_1 := 694 else     // 694
//    If '1306521'  in gpid then grm_1 := 695 else     // 695
//    If '1306522'  in gpid then grm_1 := 696 else     // 696
//    If '1306523'  in gpid then grm_1 := 697 else     // 697
//    If '1306524'  in gpid then grm_1 := 698 else     // 698
//    If '1306525'  in gpid then grm_1 := 699 else     // 699 - Fish & Game                                               
//    If '1306526'  in gpid then grm_1 := 700 else     // 700
//    If '1306527'  in gpid then grm_1 := 701 else     // 701
//    If '1306528'  in gpid then grm_1 := 702 else     // 702
//    If '1306529'  in gpid then grm_1 := 703 else     // 703
//    If '1306530'  in gpid then grm_1 := 704 else     // 704
//    If '1306531'  in gpid then grm_1 := 705 else     // 705
//    If '1306532'  in gpid then grm_1 := 706 else     // 706
//    If '1306533'  in gpid then grm_1 := 707 else     // 707
//    If '1306534'  in gpid then grm_1 := 708 else     // 708
//    If '1306535'  in gpid then grm_1 := 709 else     // 709
//    If '1306536'  in gpid then grm_1 := 710 else     // 710
//    If '1306537'  in gpid then grm_1 := 711 else     // 711
//    If '1306538'  in gpid then grm_1 := 712 else     // 712
//    If '1306539'  in gpid then grm_1 := 713 else     // 713
//    If '1306540'  in gpid then grm_1 := 714 else     // 714
//    If '1306541'  in gpid then grm_1 := 715 else     // 715
//    If '1306542'  in gpid then grm_1 := 716 else     // 716
//    If '1306543'  in gpid then grm_1 := 717 else     // 717
//    If '1306544'  in gpid then grm_1 := 718 else     // 718
//    If '1306545'  in gpid then grm_1 := 719 else     // 719
//    If '1306546'  in gpid then grm_1 := 720 else     // 720
//    If '1306547'  in gpid then grm_1 := 721 else     // 721
//    If '1306548'  in gpid then grm_1 := 722 else     // 722
//    If '1306549'  in gpid then grm_1 := 723 else     // 723
//    If '1306550'  in gpid then grm_1 := 724 else     // 724
//    If '1306551'  in gpid then grm_1 := 725 else     // 725
//    If '1306552'  in gpid then grm_1 := 726 else     // 726
//    If '1306553'  in gpid then grm_1 := 727 else     // 727
//    If '1306554'  in gpid then grm_1 := 728 else     // 728
//    If '1306555'  in gpid then grm_1 := 729 else     // 729
//    If '1306556'  in gpid then grm_1 := 730 else     // 730
//    If '1306557'  in gpid then grm_1 := 731 else     // 731
//    If '1306558'  in gpid then grm_1 := 732 else     // 732
//    If '1306559'  in gpid then grm_1 := 733 else     // 733
//    If '1306560'  in gpid then grm_1 := 734 else     // 734
//    If '1306561'  in gpid then grm_1 := 735 else     // 735
//    If '1306562'  in gpid then grm_1 := 736 else     // 736
//    If '1306563'  in gpid then grm_1 := 737 else     // 737
//    If '1306564'  in gpid then grm_1 := 738 else     // 738
//    If '1306565'  in gpid then grm_1 := 739 else     // 739
//    If '1306566'  in gpid then grm_1 := 740 else     // 740
//    If '1306567'  in gpid then grm_1 := 741 else     // 741
//    If '1306568'  in gpid then grm_1 := 742 else     // 742
//    If '1306569'  in gpid then grm_1 := 743 else     // 743
//    If '1306570'  in gpid then grm_1 := 744 else     // 744
//    If '1306571'  in gpid then grm_1 := 745 else     // 745
//    If '1306572'  in gpid then grm_1 := 746 else     // 746
//    If '1306573'  in gpid then grm_1 := 747 else     // 747
//    If '1306574'  in gpid then grm_1 := 748 else     // 748
//    If '1306575'  in gpid then grm_1 := 749 else     // 749
//    If '1306576'  in gpid then grm_1 := 750 else     // 750
//    If '1306577'  in gpid then grm_1 := 751 else     // 751
//    If '1306578'  in gpid then grm_1 := 752 else     // 752
//    If '1306579'  in gpid then grm_1 := 753 else     // 753
//    If '1306580'  in gpid then grm_1 := 754 else     // 754
//    If '1306581'  in gpid then grm_1 := 755 else     // 755
//    If '1306582'  in gpid then grm_1 := 756 else     // 756
//    If '1306583'  in gpid then grm_1 := 757 else     // 757
//    If '1306584'  in gpid then grm_1 := 758 else     // 758
//    If '1306585'  in gpid then grm_1 := 759 else     // 759
//    If '1306586'  in gpid then grm_1 := 760 else     // 760
//    If '1306587'  in gpid then grm_1 := 761 else     // 761
//    If '1306588'  in gpid then grm_1 := 762 else     // 762
//    If '1306589'  in gpid then grm_1 := 763 else     // 763
//    If '1306590'  in gpid then grm_1 := 764 else     // 764
//    If '1306591'  in gpid then grm_1 := 765 else     // 765
//    If '1306592'  in gpid then grm_1 := 766 else     // 766
//    If '1306593'  in gpid then grm_1 := 767 else     // 767
//    If '1306594'  in gpid then grm_1 := 768 else     // 768
//    If '1306595'  in gpid then grm_1 := 769 else     // 769
//    If '1306596'  in gpid then grm_1 := 770 else     // 770
//    If '1306597'  in gpid then grm_1 := 771 else     // 771
//    If '1306598'  in gpid then grm_1 := 772 else     // 772
//    If '1306599'  in gpid then grm_1 := 773 else     // 773
//    If '1306600'  in gpid then grm_1 := 774 else     // 774
//    If '1306601'  in gpid then grm_1 := 775 else     // 775
//    If '1306602'  in gpid then grm_1 := 776 else     // 776
//    If '1306603'  in gpid then grm_1 := 777 else     // 777
//    If '1306604'  in gpid then grm_1 := 778 else     // 778
//    If '1306605'  in gpid then grm_1 := 779 else     // 779
//    If '1306606'  in gpid then grm_1 := 780 else     // 780
//    If '1306607'  in gpid then grm_1 := 781 else     // 781
//    If '1306608'  in gpid then grm_1 := 782 else     // 782
//    If '1306609'  in gpid then grm_1 := 783 else     // 783
//    If '1306610'  in gpid then grm_1 := 784 else     // 784
//    If '1306611'  in gpid then grm_1 := 785 else     // 785
//    If '1306612'  in gpid then grm_1 := 786 else     // 7- Reforestation                                                
//    If '1306613'  in gpid then grm_1 := 787 else     // 7- Classified forest                                            
//    If '1306614'  in gpid then grm_1 := 788 else     // 7- Designated forest                                            
//    If '1306615'  in gpid then grm_1 := 789 else     // 7- Other resource production                                    
//    If '1306616'  in gpid then grm_1 := 790 else     // 790
//    If '1306617'  in gpid then grm_1 := 791 else     // 791
//    If '1306618'  in gpid then grm_1 := 792 else     // 792
//    If '1306619'  in gpid then grm_1 := 793 else     // 793
//    If '1306620'  in gpid then grm_1 := 794 else     // 7- Open space                                                   
//    If '1306621'  in gpid then grm_1 := 795 else     // 7- Open space timber                                            
//    If '1306622'  in gpid then grm_1 := 796 else     // 796
//    If '1306623'  in gpid then grm_1 := 797 else     // 797
//    If '1306624'  in gpid then grm_1 := 798 else     // 798
//    If '1306625'  in gpid then grm_1 := 799 else     // 799
//    If '1306626'  in gpid then grm_1 := 800 else     // Utility: Agricultural                                           
//    If '1306627'  in gpid then grm_1 := 801 else     // 801
//    If '1306628'  in gpid then grm_1 := 802 else     // 802
//    If '1306629'  in gpid then grm_1 := 803 else     // 803
//    If '1306630'  in gpid then grm_1 := 804 else     // 804
//    If '1306631'  in gpid then grm_1 := 805 else     // 805
//    If '1306632'  in gpid then grm_1 := 806 else     // 806
//    If '1306633'  in gpid then grm_1 := 807 else     // 807
//    If '1306634'  in gpid then grm_1 := 808 else     // 808
//    If '1306635'  in gpid then grm_1 := 809 else     // 809
//    If '1306636'  in gpid then grm_1 := 810 else     // Utility: Mineral                                                
//    If '1306637'  in gpid then grm_1 := 811 else     // 811
//    If '1306638'  in gpid then grm_1 := 812 else     // 812
//    If '1306639'  in gpid then grm_1 := 813 else     // 813
//    If '1306640'  in gpid then grm_1 := 814 else     // 814
//    If '1306641'  in gpid then grm_1 := 815 else     // 815
//    If '1306642'  in gpid then grm_1 := 816 else     // 816
//    If '1306643'  in gpid then grm_1 := 817 else     // 817
//    If '1306644'  in gpid then grm_1 := 818 else     // 818
//    If '1306645'  in gpid then grm_1 := 819 else     // 819
//    If '1306646'  in gpid then grm_1 := 820 else     // Utility: Industrial                                             
//    If '1306647'  in gpid then grm_1 := 821 else     // 821
//    If '1306648'  in gpid then grm_1 := 822 else     // 822
//    If '1306649'  in gpid then grm_1 := 823 else     // 823
//    If '1306650'  in gpid then grm_1 := 824 else     // 824
//    If '1306651'  in gpid then grm_1 := 825 else     // 825
//    If '1306652'  in gpid then grm_1 := 826 else     // 826
//    If '1306653'  in gpid then grm_1 := 827 else     // 827
//    If '1306654'  in gpid then grm_1 := 828 else     // 828
//    If '1306655'  in gpid then grm_1 := 829 else     // 829
//    If '1306656'  in gpid then grm_1 := 830 else     // Utility: Commercial                                             
//    If '1306657'  in gpid then grm_1 := 831 else     // 831
//    If '1306658'  in gpid then grm_1 := 832 else     // 832
//    If '1306659'  in gpid then grm_1 := 833 else     // 833
//    If '1306660'  in gpid then grm_1 := 834 else     // 834
//    If '1306661'  in gpid then grm_1 := 835 else     // 835
//    If '1306662'  in gpid then grm_1 := 836 else     // 836
//    If '1306663'  in gpid then grm_1 := 837 else     // 837
//    If '1306664'  in gpid then grm_1 := 838 else     // 838
//    If '1306665'  in gpid then grm_1 := 839 else     // 839
//    If '1306666'  in gpid then grm_1 := 840 else     // Utility: RR real prop-ops                                       
//    If '1306667'  in gpid then grm_1 := 841 else     // 8- Railroad/Transit transport                                   
//    If '1306668'  in gpid then grm_1 := 842 else     // 8- Motor vehicle transport                                      
//    If '1306669'  in gpid then grm_1 := 843 else     // 8- Aircraft transport                                           
//    If '1306670'  in gpid then grm_1 := 844 else     // 8- Marine craft transport                                       
//    If '1306671'  in gpid then grm_1 := 845 else     // 845- Locally Assessed Operating Property                        
//    If '1306672'  in gpid then grm_1 := 846 else     // 8- Automobile parking                                           
//    If '1306673'  in gpid then grm_1 := 847 else     // 8- Communication                                                
//    If '1306674'  in gpid then grm_1 := 848 else     // 8- Utilities                                                    
//    If '1306675'  in gpid then grm_1 := 849 else     // 8- Other transpt                                                
//    If '1306676'  in gpid then grm_1 := 850 else     // Utility: RR real prop-not ops                                   
//    If '1306677'  in gpid then grm_1 := 851 else     // 851
//    If '1306678'  in gpid then grm_1 := 852 else     // 852
//    If '1306679'  in gpid then grm_1 := 853 else     // 853
//    If '1306680'  in gpid then grm_1 := 854 else     // 854
//    If '1306681'  in gpid then grm_1 := 855 else     // 855
//    If '1306682'  in gpid then grm_1 := 856 else     // 856
//    If '1306683'  in gpid then grm_1 := 857 else     // 857
//    If '1306684'  in gpid then grm_1 := 858 else     // 858
//    If '1306685'  in gpid then grm_1 := 859 else     // 859
//    If '1306686'  in gpid then grm_1 := 860 else     // Utility: RR pers prop-ops                                       
//    If '1306687'  in gpid then grm_1 := 861 else     // 861
//    If '1306688'  in gpid then grm_1 := 862 else     // 862
//    If '1306689'  in gpid then grm_1 := 863 else     // 863
//    If '1306690'  in gpid then grm_1 := 864 else     // 864
//    If '1306691'  in gpid then grm_1 := 865 else     // 865
//    If '1306692'  in gpid then grm_1 := 866 else     // 866
//    If '1306693'  in gpid then grm_1 := 867 else     // 867- Op Prop Central Assess                                     
//    If '1306694'  in gpid then grm_1 := 868 else     // 868
//    If '1306695'  in gpid then grm_1 := 869 else     // 869
//    If '1306696'  in gpid then grm_1 := 870 else     // Utility: RR pers prop-not ops                                   
//    If '1306697'  in gpid then grm_1 := 871 else     // 871
//    If '1306698'  in gpid then grm_1 := 872 else     // 872
//    If '1306699'  in gpid then grm_1 := 873 else     // 873
//    If '1306700'  in gpid then grm_1 := 874 else     // 874
//    If '1306701'  in gpid then grm_1 := 875 else     // 875
//    If '1306702'  in gpid then grm_1 := 876 else     // 876
//    If '1306703'  in gpid then grm_1 := 877 else     // 877
//    If '1306704'  in gpid then grm_1 := 878 else     // 878
//    If '1306705'  in gpid then grm_1 := 879 else     // 879
//    If '1306706'  in gpid then grm_1 := 880 else     // Utility: Pers prop - not RR                                     
//    If '1306707'  in gpid then grm_1 := 881 else     // 881
//    If '1306708'  in gpid then grm_1 := 882 else     // 882
//    If '1306709'  in gpid then grm_1 := 883 else     // 883
//    If '1306710'  in gpid then grm_1 := 884 else     // 884
//    If '1306711'  in gpid then grm_1 := 885 else     // 885
//    If '1306712'  in gpid then grm_1 := 886 else     // 886
//    If '1306713'  in gpid then grm_1 := 887 else     // 887
//    If '1306714'  in gpid then grm_1 := 888 else     // 888
//    If '1306715'  in gpid then grm_1 := 889 else     // 889
//    If '1306716'  in gpid then grm_1 := 890 else     // 890
//    If '1306717'  in gpid then grm_1 := 891 else     // 891
//    If '1306718'  in gpid then grm_1 := 892 else     // 892
//    If '1306719'  in gpid then grm_1 := 893 else     // 893
//    If '1306720'  in gpid then grm_1 := 894 else     // 894
//    If '1306721'  in gpid then grm_1 := 895 else     // 895
//    If '1306722'  in gpid then grm_1 := 896 else     // 896
//    If '1306723'  in gpid then grm_1 := 897 else     // 897
//    If '1306724'  in gpid then grm_1 := 898 else     // 898
//    If '1306725'  in gpid then grm_1 := 899 else     // 899
//    If '1306726'  in gpid then grm_1 := 900 else     // 900
//    If '1306727'  in gpid then grm_1 := 901 else     // 901
//    If '1306728'  in gpid then grm_1 := 902 else     // 902
//    If '1306729'  in gpid then grm_1 := 903 else     // 903
//    If '1306730'  in gpid then grm_1 := 904 else     // 904
//    If '1306731'  in gpid then grm_1 := 905 else     // 905
//    If '1306732'  in gpid then grm_1 := 906 else     // 906
//    If '1306733'  in gpid then grm_1 := 907 else     // 907
//    If '1306734'  in gpid then grm_1 := 908 else     // 908
//    If '1306735'  in gpid then grm_1 := 909 else     // 909
//    If '1306736'  in gpid then grm_1 := 910 else     // 910
//    If '1306737'  in gpid then grm_1 := 911 else     // 911
//    If '1306738'  in gpid then grm_1 := 912 else     // 912
//    If '1306739'  in gpid then grm_1 := 913 else     // 913
//    If '1306740'  in gpid then grm_1 := 914 else     // 914
//    If '1306741'  in gpid then grm_1 := 915 else     // 915
//    If '1306742'  in gpid then grm_1 := 916 else     // 916
//    If '1306743'  in gpid then grm_1 := 917 else     // 917
//    If '1306744'  in gpid then grm_1 := 918 else     // 918
//    If '1306745'  in gpid then grm_1 := 919 else     // 919
//    If '1306746'  in gpid then grm_1 := 920 else     // 920
//    If '1306747'  in gpid then grm_1 := 921 else     // 921
//    If '1306748'  in gpid then grm_1 := 922 else     // 922
//    If '1306749'  in gpid then grm_1 := 923 else     // 923
//    If '1306750'  in gpid then grm_1 := 924 else     // 924
//    If '1306751'  in gpid then grm_1 := 925 else     // 925
//    If '1306752'  in gpid then grm_1 := 926 else     // 926
//    If '1306753'  in gpid then grm_1 := 927 else     // 927
//    If '1306754'  in gpid then grm_1 := 928 else     // 928
//    If '1306755'  in gpid then grm_1 := 929 else     // 929
//    If '1306756'  in gpid then grm_1 := 930 else     // 930
//    If '1306757'  in gpid then grm_1 := 931 else     // 931
//    If '1306758'  in gpid then grm_1 := 932 else     // 932
//    If '1306759'  in gpid then grm_1 := 933 else     // 933
//    If '1306760'  in gpid then grm_1 := 934 else     // 934
//    If '1306761'  in gpid then grm_1 := 935 else     // 935
//    If '1306762'  in gpid then grm_1 := 936 else     // 936
//    If '1306763'  in gpid then grm_1 := 937 else     // 937
//    If '1306764'  in gpid then grm_1 := 938 else     // 938
//    If '1306765'  in gpid then grm_1 := 939 else     // 939
//    If '1306766'  in gpid then grm_1 := 940 else     // 940
//    If '1306767'  in gpid then grm_1 := 941 else     // 941
//    If '1306768'  in gpid then grm_1 := 942 else     // 942
//    If '1306769'  in gpid then grm_1 := 943 else     // 943
//    If '1306770'  in gpid then grm_1 := 944 else     // 944/
//    If '1306771'  in gpid then grm_1 := 945 else     // 945
//    If '1306772'  in gpid then grm_1 := 946 else     // 946
//    If '1306773'  in gpid then grm_1 := 947 else     // 947
//    If '1306774'  in gpid then grm_1 := 948 else     // 948
//    If '1306775'  in gpid then grm_1 := 949 else     // 949
//    If '1306776'  in gpid then grm_1 := 950 else     // 950
//    If '1306777'  in gpid then grm_1 := 951 else     // 951
//    If '1306778'  in gpid then grm_1 := 952 else     // 952
//    If '1306779'  in gpid then grm_1 := 953 else     // 953
//    If '1306780'  in gpid then grm_1 := 954 else     // 954
//    If '1306781'  in gpid then grm_1 := 955 else     // 955
//    If '1306782'  in gpid then grm_1 := 956 else     // 956
//    If '1306783'  in gpid then grm_1 := 957 else     // 957
//    If '1306784'  in gpid then grm_1 := 958 else     // 958
//    If '1306785'  in gpid then grm_1 := 959 else     // 959
//    If '1306786'  in gpid then grm_1 := 960 else     // 960
//    If '1306787'  in gpid then grm_1 := 961 else     // 961
//    If '1306788'  in gpid then grm_1 := 962 else     // 962
//    If '1306789'  in gpid then grm_1 := 963 else     // 963
//    If '1306790'  in gpid then grm_1 := 964 else     // 964
//    If '1306791'  in gpid then grm_1 := 965 else     // 965
//    If '1306792'  in gpid then grm_1 := 966 else     // 966
//    If '1306793'  in gpid then grm_1 := 967 else     // 967
//    If '1306794'  in gpid then grm_1 := 968 else     // 968
//    If '1306795'  in gpid then grm_1 := 969 else     // 969
//    If '1306796'  in gpid then grm_1 := 970 else     // 970
//    If '1306797'  in gpid then grm_1 := 971 else     // 971
//    If '1306798'  in gpid then grm_1 := 972 else     // 972
//    If '1306799'  in gpid then grm_1 := 973 else     // 973
//    If '1306800'  in gpid then grm_1 := 974 else     // 974
//    If '1306801'  in gpid then grm_1 := 975 else     // 975
//    If '1306802'  in gpid then grm_1 := 976 else     // 976
//    If '1306803'  in gpid then grm_1 := 977 else     // 977
//    If '1306804'  in gpid then grm_1 := 978 else     // 978
//    If '1306805'  in gpid then grm_1 := 979 else     // 979
//    If '1306806'  in gpid then grm_1 := 980 else     // 980
//    If '1306807'  in gpid then grm_1 := 981 else     // 981
//    If '1306808'  in gpid then grm_1 := 982 else     // 982
//    If '1306809'  in gpid then grm_1 := 983 else     // 983
//    If '1306810'  in gpid then grm_1 := 984 else     // 984
//    If '1306811'  in gpid then grm_1 := 985 else     // 985
//    If '1306812'  in gpid then grm_1 := 986 else     // 986
//    If '1306813'  in gpid then grm_1 := 987 else     // 987
//    If '1306814'  in gpid then grm_1 := 988 else     // 988
//    If '1306815'  in gpid then grm_1 := 989 else     // 989
//    If '1306816'  in gpid then grm_1 := 990 else     // 990
//    If '1306817'  in gpid then grm_1 := 991 else     // 991
//    If '1306818'  in gpid then grm_1 := 992 else     // 992
//    If '1306819'  in gpid then grm_1 := 993 else     // 993
//    If '1306820'  in gpid then grm_1 := 994 else     // 994
//    If '1306821'  in gpid then grm_1 := 995 else     // 995
//    If '1306822'  in gpid then grm_1 := 996 else     // 996
//    If '1306823'  in gpid then grm_1 := 997 else     // 997
//    If '1306824'  in gpid then grm_1 := 998 else     // 998
//    If '1306825'  in gpid then grm_1 := 999 else     // 999 NOT COMPLETE                                                

// 1.B. DEFAULT
    grm_1 := {parcel_base.property_class};
)
    else grm_1 := {parcel_base.property_class};
// 2.A FINAL
    pcc_grm := grm_1;
    pcc_grm;
);
// GRM END


// STD START
(
// 2. USE GROUP CODES FROM LAST CERTIFICATION TO DETERMINE PCC_STD

// 2.A PASS 1

// 2.A.1 PASS 1 LAND - PRIMARY


// 1. GENERAL
    if pcc_land = 999 and pcc_imp = 999 then pcc_std := pcc_grm else
    if pcc_land = pcc_imp then pcc_std := pcc_land else
    if pcc_land = 0 and pcc_imp <> 0 then pcc_std := pcc_imp else
    if pcc_land <> 0 and pcc_imp = 0 then pcc_std := pcc_land else

// 2. AGRICUTURAL (100)
    if pcc_land in [110,112,115,120] and pcc_imp in [131] then pcc_std := 131 else

    if pcc_land in [110,120] and pcc_imp in [530] then pcc_std := 130 else
    if pcc_land in [101,102,103,104,105,106,107,110,112,115,118,120] and pcc_imp in [532] then pcc_std := 132 else
    if pcc_land in [118] and pcc_imp in [540,740] then pcc_std := 140 else

    if pcc_land in [111,411] and pcc_imp in [133] then pcc_std := 133 else
    if pcc_land in [111] and pcc_imp in [433] then pcc_std := 133 else
    if pcc_land in [113,413] and pcc_imp in [135] then pcc_std := 135 else
    if pcc_land in [113] and pcc_imp in [435] then pcc_std := 135 else
    if pcc_land in [116,416] and pcc_imp in [138] then pcc_std := 138 else
    if pcc_land in [116] and pcc_imp in [438] then pcc_std := 138 else
    if pcc_land in [121,421] and pcc_imp in [142] then pcc_std := 142 else
    if pcc_land in [121] and pcc_imp in [442] then pcc_std := 142 else

    if pcc_land in [110,112] and pcc_imp in [134,534] then pcc_std := 134 else
    if pcc_land in [110,115] and pcc_imp in [137,537] then pcc_std := 137 else
    if pcc_land in [120] and pcc_imp in [141,541] then pcc_std := 141 else

    if pcc_land in [114,314] and pcc_imp in [136] then pcc_std := 136 else
    if pcc_land in [114] and pcc_imp in [336] then pcc_std := 136 else
    if pcc_land in [117,317] and pcc_imp in [139] then pcc_std := 139 else
    if pcc_land in [117] and pcc_imp in [339] then pcc_std := 139 else
    if pcc_land in [122,322] and pcc_imp in [143] then pcc_std := 143 else
    if pcc_land in [122] and pcc_imp in [343] then pcc_std := 143 else

    if pcc_land in [110,112,115,120] and pcc_imp in [146,546] then pcc_std := 146 else
    if pcc_land in [110,112,115,120] and pcc_imp in [547] then pcc_std := 147 else
    if pcc_land in [110,112,115,120] and pcc_imp in [148,548] then pcc_std := 148 else

// 3. MINING
    if pcc_land in [209] and pcc_imp in [532] then pcc_std := 232 else

// 4. INDUSTRIAL (300)
    if pcc_land in [314] and pcc_imp in [336] then pcc_std := 336 else
    if pcc_land in [317] and pcc_imp in [339] then pcc_std := 339 else
    if pcc_land in [322] and pcc_imp in [343] then pcc_std := 343 else

    if pcc_land in [320] and pcc_imp in [530] then pcc_std := 330 else
    if pcc_land in [312] and pcc_imp in [532] then pcc_std := 332.12 else
    if pcc_land in [315] and pcc_imp in [532] then pcc_std := 332.15 else

    if pcc_land in [312,314] and pcc_imp in [334,534] then pcc_std := 334 else
    if pcc_land in [315,317] and pcc_imp in [337,537] then pcc_std := 337 else
    if pcc_land in [320,322] and pcc_imp in [341,541] then pcc_std := 341 else

    if pcc_land in [312,315,320] and pcc_imp in [346,546] then pcc_std := 346 else
    if pcc_land in [312,315,320] and pcc_imp in [348,548] then pcc_std := 348 else

// 5. COMMERCIAL (400)
    if pcc_land in [411] and pcc_imp in [433] then pcc_std := 433 else
    if pcc_land in [413] and pcc_imp in [435] then pcc_std := 435 else
    if pcc_land in [416] and pcc_imp in [438] then pcc_std := 438 else
    if pcc_land in [421] and pcc_imp in [442] then pcc_std := 442 else

    if pcc_land in [420] and pcc_imp in [530] then pcc_std := 430 else
    if pcc_land in [412] and pcc_imp in [532] then pcc_std := 432.12 else
    if pcc_land in [415] and pcc_imp in [532] then pcc_std := 432.15 else

    if pcc_land in [412,413] and pcc_imp in [434,534] then pcc_std := 434 else
    if pcc_land in [415,416] and pcc_imp in [437,537] then pcc_std := 437 else
    if pcc_land in [420,421] and pcc_imp in [441,541] then pcc_std := 441 else

    if pcc_land in [513,516,521] and pcc_imp in [446,546] then pcc_std := 446 else
    if pcc_land in [513,516,521] and pcc_imp in [448,548] then pcc_std := 448 else

// 6. RESIDENTIAL (500)
    if pcc_land in [512] and pcc_imp in [534] then pcc_std := 534 else
    if pcc_land in [515] and pcc_imp in [537] then pcc_std := 537 else
    if pcc_land in [520] and pcc_imp in [541] then pcc_std := 541 else

    if pcc_land in [520] and pcc_imp in [530] then pcc_std := 530 else
    if pcc_land in [512] and pcc_imp in [532] then pcc_std := 532.12 else
    if pcc_land in [515] and pcc_imp in [532] then pcc_std := 532.15 else
    if pcc_land in [512,515,520] and pcc_imp in [740] then pcc_std := 540 else

    if pcc_land in [512,515,520] and pcc_imp in [546] then pcc_std := 546 else
    if pcc_land in [512,515,520] and pcc_imp in [547] then pcc_std := 547 else
    if pcc_land in [512,515,520] and pcc_imp in [548] then pcc_std := 548 else

// 7. OTHER (700)
    if pcc_land in [711] and pcc_imp in [433] then pcc_std := 733 else
    if pcc_land in [713] and pcc_imp in [435] then pcc_std := 735 else
    if pcc_land in [716] and pcc_imp in [438] then pcc_std := 738 else
    if pcc_land in [718] and pcc_imp in [740] then pcc_std := 740 else
    if pcc_land in [721] and pcc_imp in [442] then pcc_std := 742 else

// 8. DELETE AFTER 2007
//    if pcc_imp in [960] then pcc_std := 962 else
//    if pcc_imp in [961] then pcc_std := 962 else
    if pcc_imp in [962] then pcc_std := 962 else

// 9. FINAL
    pcc_std := 0;
    pcc_std;
);








*/






