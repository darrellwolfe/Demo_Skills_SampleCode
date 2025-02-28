
--
-- This script should be ran BEFORE creating the Main cadastre's
--
UPDATE valuetypes
	SET RuleNumber = 99 where RuleNumber = 9
go
UPDATE valuetypes
	SET RuleNumber = 99 where valtype in (462,463)
go


--
-- This script should be ran BEFORE creating the Supplemental cadastre's
--
UPDATE valuetypes
	SET RuleNumber = 9 where RuleNumber = 99
go
UPDATE valuetypes
	SET RuleNumber = 13 where valtype in (462,463)
go
