DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 4, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year


DECLARE @CollectionDate VARCHAR(10) = CONCAT(@Year - 20, '-01-01');


SELECT
e.lrsn,
--e.extension,
e.data_source_code,
e.appraiser,
e.appraisal_date,
--e.data_collector,
--e.collection_date

FROM extensions AS e

WHERE e.extension = 'L00'
AND e.status = 'A'
--AND e.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
--AND e.collection_date > '2000-01-01'
AND e.collection_date > @CollectionDate