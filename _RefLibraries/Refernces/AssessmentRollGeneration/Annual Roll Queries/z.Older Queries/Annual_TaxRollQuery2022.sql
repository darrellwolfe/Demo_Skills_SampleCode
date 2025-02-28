/*
AsTxDBProd
GRM_Main

Cadastre Tax Roll Report
under const

*/
SELECT 
r.Id, r.AssessmentYear, r.Descr AS AssessmentType,
l.Id, l.CadRollId, l.RollLevel,
i.Id, i.EffStatus, i.TranId, i.CadLevelId, i.RevObjEffStatus, i.PIN, i.AIN, i.GeoCd, i.TAGDescr AS TAG
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId

/*   
CadRoll Table Id (r.Id) is the id for the specific tax roll desired. See CadRoll table or Schema in the Comptroller Reporting folder.
WHERE r.Id= '558'
WHERE r.Id IN ('558', '556', '555', '554')

*/

WHERE r.Id IN ('558', '556', '555', '554')

GROUP BY r.Id, r.AssessmentYear, r.Descr, l.Id, l.CadRollId, l.RollLevel, i.Id, i.EffStatus, i.TranId, i.CadLevelId, i.RevObjEffStatus, i.PIN, i.AIN, i.GeoCd, i.TAGDescr
ORDER BY r.Id, i.GeoCd, i.PIN;
