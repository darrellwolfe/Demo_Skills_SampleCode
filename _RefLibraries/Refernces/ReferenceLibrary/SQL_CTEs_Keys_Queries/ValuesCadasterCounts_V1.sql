-- !preview conn=conn

SELECT 
  CAR.Assessmentyear
,  CAR.Descr
,  COUNT(DISTINCT CAI.AIN)  -- Replace AIN with the actual column name
FROM 
  CadInV AS CAI
JOIN 
  CADLEVEL AS CAL ON CAI.CadLevelId = CAL.ID
JOIN 
  CADROLL AS CAR ON CAL.CadRollId = CAR.Id
GROUP BY 
  CAR.Assessmentyear
,  CAR.Descr;