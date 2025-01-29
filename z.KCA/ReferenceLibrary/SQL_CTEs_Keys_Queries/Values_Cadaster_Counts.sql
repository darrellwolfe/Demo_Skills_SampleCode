-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

group_code
tbl_element_desc AS Imp_GroupCode_Desc

*/


SELECT 
CAR.Assessmentyear
, CONCAT ('01/01/',CAR.AssessmentYear) AS AssessmentDate
, CAR.Descr
, CAI.TranDate
, CASE
    WHEN CAI.GeoCd >= 9000 THEN 'Manufactured_Homes'
    WHEN CAI.GeoCd >= 6003 THEN 'District_6'
    WHEN CAI.GeoCd = 6002 THEN 'Manufactured_Homes'
    WHEN CAI.GeoCd = 6001 THEN 'District_6'
    WHEN CAI.GeoCd = 6000 THEN 'Manufactured_Homes'
    WHEN CAI.GeoCd >= 5003 THEN 'District_5'
    WHEN CAI.GeoCd = 5002 THEN 'Manufactured_Homes'
    WHEN CAI.GeoCd = 5001 THEN 'District_5'
    WHEN CAI.GeoCd = 5000 THEN 'Manufactured_Homes'
    WHEN CAI.GeoCd >= 4000 THEN 'District_4'
    WHEN CAI.GeoCd >= 3000 THEN 'District_3'
    WHEN CAI.GeoCd >= 2000 THEN 'District_2'
    WHEN CAI.GeoCd >= 1021 THEN 'District_1'
    WHEN CAI.GeoCd = 1020 THEN 'Manufactured_Homes'
    WHEN CAI.GeoCd >= 1001 THEN 'District_1'
    WHEN CAI.GeoCd = 1000 THEN 'Manufactured_Homes'
    WHEN CAI.GeoCd >= 451 THEN 'Commercial'
    WHEN CAI.GeoCd = 450 THEN 'Specialized_Cell_Towers'
    WHEN CAI.GeoCd >= 1 THEN 'Commercial'
    WHEN CAI.GeoCd = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District
, CAI.GeoCd
, CAI.RevObjId
, CAI.PIN
, CAI.AIN
, CAI.ClassCd -- Not what I wanted
, CAI.TAGDescr

FROM 
CadInV AS CAI
JOIN 
CADLEVEL AS CAL ON CAI.CadLevelId = CAL.ID
JOIN 
CADROLL AS CAR ON CAL.CadRollId = CAR.Id

WHERE CAI.EffStatus = 'A'
