-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
*/


DECLARE @TaxYear INT = 2024;

SELECT DISTINCT
r.Id, r.AssessmentYear, r.Descr AS AssessmentType,
l.Id, l.CadRollId, l.RollLevel
--i.Id
--, i.EffStatus, i.TranId, i.CadLevelId
--, i.RevObjEffStatus, i.PIN, i.AIN, i.GeoCd, i.TAGDescr AS TAG
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId

--Where AssessmentYear = 2023
Where AssessmentYear = @TaxYear
