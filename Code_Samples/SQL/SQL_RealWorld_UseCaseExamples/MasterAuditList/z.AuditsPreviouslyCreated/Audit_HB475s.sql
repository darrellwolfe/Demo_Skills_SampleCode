-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
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
p.neighborhood AS [GEO],
p.lrsn,
TRIM(p.pin) AS [PIN], 
TRIM(p.ain) AS [AIN], 
TRIM(p.ClassCD) AS [PCC],
p.DisplayName,
a.group_code AS [Allocation],
m.memo_text,
pt.permit_ref,
pt.inactivedate,
pt.permit_desc


FROM KCv_PARCELMASTER1 AS p
JOIN allocations AS a ON p.lrsn = a.lrsn 
AND a.status='A'
AND a.group_code = '81'
LEFT JOIN memos AS m ON p.lrsn = m.lrsn
AND m.memo_id = 'NC23'
AND m.memo_line_number = '2'
LEFT JOIN permits AS pt ON p.lrsn = pt.lrsn
AND pt.permit_type IN ('1','2')

WHERE p.EffStatus= 'A'
AND p.neighborhood > '999'
AND (p.DisplayName NOT LIKE 'IDAHO DEPT%'
  AND p.DisplayName NOT LIKE '%CITY OF%'
  AND p.DisplayName NOT LIKE '%COUNTY%'
  AND p.DisplayName NOT LIKE '%U S%'
  AND p.DisplayName NOT LIKE '%WATER%'
  AND p.DisplayName NOT LIKE '%TRIBE%'
  AND p.DisplayName NOT LIKE 'IDAHO TRANSPORTATION DEPARTMENT'
  AND p.DisplayName NOT LIKE 'IDAHO FISH AND GAME COMMISSION'
  AND p.DisplayName NOT LIKE 'IDAHO DEPARTMENT OF PARKS AND RECREATION'
  AND p.DisplayName NOT LIKE 'TWINLOW CAMPING COMMISSION'
  AND p.DisplayName NOT LIKE '%CHURCH%'
  AND p.DisplayName NOT LIKE '%MASONIC%'
  AND p.DisplayName NOT LIKE '%SEWER%'
  AND p.DisplayName NOT LIKE '%HIGHWAY%'
  AND p.DisplayName NOT LIKE '%IMMACULATE CONCEPTION%'
  AND p.DisplayName NOT LIKE '%NORTH IDAHO COMMUNITY%'
  AND p.DisplayName NOT LIKE '%ST VINCENT DE PAUL%'
  AND p.DisplayName NOT LIKE '%IRRIGATION%'
  AND p.DisplayName NOT LIKE '%UPPER COLUMBIA CORP%'
  AND p.DisplayName NOT LIKE '%CATHOLIC%'
  AND p.DisplayName NOT LIKE '%FIRE%'
  AND p.DisplayName NOT LIKE '%IDAHO YOUTH RANCH%'
  AND p.DisplayName NOT LIKE '%SCOUTS%'
  AND p.DisplayName NOT LIKE '%COMM CENTER%'
  AND p.DisplayName NOT LIKE 'CALVARY RATHDRUM INC'
  AND p.DisplayName NOT LIKE '%ASSN%'
  AND p.DisplayName NOT LIKE '%ASSOC%'
  AND p.DisplayName NOT LIKE 'SALVATION ARMY THE'
  AND p.DisplayName NOT LIKE '%COMMUNITY%'
  AND p.DisplayName NOT LIKE '%LEGION POST%'
  AND p.DisplayName NOT LIKE '%SCHOOL%'
  AND p.DisplayName NOT LIKE '%ACADEMY%'
  AND p.DisplayName NOT LIKE '%COLLEGE%'
  AND p.DisplayName NOT LIKE '%MONASTERY%'
  AND p.DisplayName NOT LIKE 'HABITAT FOR HUMANITY OF NORTH IDAHO INC'
  AND p.DisplayName NOT LIKE '%FOUNDATION%'
  AND p.DisplayName NOT LIKE '%COMMITTEE%'
  AND p.DisplayName NOT LIKE '%URBAN RENEWAL%'
  AND p.DisplayName NOT LIKE 'HOUSING COMPANY THE'
  AND p.DisplayName NOT LIKE '%GRANGE%'
  AND p.DisplayName NOT LIKE '%DIOCESE%'
  AND p.DisplayName NOT LIKE '%GOOD SAMARITAN%'
  AND p.DisplayName NOT LIKE 'WASHINGTON STATE PARKS REC'
  AND p.DisplayName NOT LIKE '%CEMETERY%'
  AND p.DisplayName NOT LIKE 'DOMINICAN SISTERS OF IDAHO INC')
