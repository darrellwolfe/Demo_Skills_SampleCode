


--------------------------------
--Variables BEGIN
--------------------------------
DECLARE @Year INT = 2024; -- Input year

-- Use CONCAT to create date strings for the start and end of the year
DECLARE @LastYearCertFrom INT = CONCAT(@Year - 1, '0101');
DECLARE @LastYearCertTo INT = CONCAT(@Year - 1, '1231');

-- Date and time for January 1 of the input year
DECLARE @Jan1ThisYear1 DATETIME = CONCAT(@Year, '-01-01 00:00:00');
DECLARE @Jan1ThisYear2 DATETIME = CONCAT(@Year, '-01-01 23:59:59');

-- Use CONCAT to create certification date strings for the current year
DECLARE @ThisYearCertFrom INT = CONCAT(@Year, '0101');
DECLARE @ThisYearCertTo INT = CONCAT(@Year, '1231');

-- Use CONCAT for creating range values for MPPV
DECLARE @ThisYearMPPVFrom INT = CONCAT(@Year, '00000');
DECLARE @ThisYearMPPVTo INT = CONCAT(@Year, '99999');

-- Declare cadaster year as the input year
DECLARE @CadasterYear INT = @Year;

DECLARE @NoteYear VARCHAR(10) = CONCAT('%',@Year,'%');






SELECT *





FROM tPPAsset AS pp
WHERE mEffStatus = 'A' 
--AND mPropertyId = 510587 -- Use as Test
And mbegTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo
And mendTaxYear BETWEEN @ThisYearMPPVFrom AND @ThisYearMPPVTo
And mPropertyId = 557278