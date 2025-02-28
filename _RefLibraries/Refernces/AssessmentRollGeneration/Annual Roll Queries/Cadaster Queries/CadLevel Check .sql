

DECLARE @EffYear INT = 2024;

Select 
l.Id AS CadLevelID
,l.cadrollid
,r.AssessmentYear
,r.Descr

From CadLevel AS l
Join CadRoll AS r
    On r.Id = l.CadRollId
    And r.AssessmentYear = @EffYear

--Where l.AssessmentYear = @EffYear


