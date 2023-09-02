/*
SELECT 
r.Id, r.AssessmentYear, r.Descr AS AssessmentType,
l.Id, l.CadRollId, l.RollLevel,
i.Id, i.EffStatus, i.TranId, i.CadLevelId, i.RevObjEffStatus, i.PIN, i.AIN, i.GeoCd, i.TAGDescr AS TAG
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId

Select *
From CadRoll
Order by Id DESC

Select *
From CadLevel
Order by CreateLevelDate DESC, LastBuildDate DESC

Select *
From CadInv
Order by CreateLevelDate DESC, LastBuildDate DESC


*/

Select *
From CadLevel
Order by CreateLevelDate DESC, LastBuildDate DESC