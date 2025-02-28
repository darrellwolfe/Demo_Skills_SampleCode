DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

-- DECLARE @Year INT = 2024; -- Input year

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




Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrev2 int = @Year - 2; -- Input the year here
Declare @YearPrev3 int = @Year - 3; -- Input the year here
Declare @YearPrev4 int = @Year - 4; -- Input the year here
Declare @YearPrev5 int = @Year - 5; -- Input the year here


Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous2 varchar(8) = Cast(@YearPrev2 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous3 varchar(8) = Cast(@YearPrev3 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous4 varchar(8) = Cast(@YearPrev4 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous5 varchar(8) = Cast(@YearPrev5 as varchar) + '0101'; -- Generates '20230101' for the previous year


Declare @ValEffDateCurrent date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @ValEffDatePrevious date = CAST(CAST(@YearPrev as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious2 date = CAST(CAST(@YearPrev2 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious3 date = CAST(CAST(@YearPrev3 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious4 date = CAST(CAST(@YearPrev4 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious5 date = CAST(CAST(@YearPrev5 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year


Declare @EffYearLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious2 varchar(8) = Cast(@YearPrev2 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious3 varchar(8) = Cast(@YearPrev3 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious4 varchar(8) = Cast(@YearPrev4 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious5 varchar(8) = Cast(@YearPrev5 as varchar) + '%'; -- Generates '2023%' for the previous year



EXAMPLE

Case

    -- MM/D/YYYY
    When Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)
        )

    -- MM/DD/YYYY (most specific)
    When Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)
        )

    -- M/D/YYYY
    When Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9]/[0-9]/[0-9][0-9][0-9][0-9]%', NCCurrentText)
        )

    -- MM/DD/YY
    When Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9][0-9]/[0-9][0-9]%', NCCurrentText)
        )

    -- MM/D/YY
    When Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9][0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)
        )

    -- M/D/YY
    When Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText) > 0 Then
        Substring(
            NCCurrentText,
            Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText),
            CHARINDEX(' ', NCCurrentText + ' ', Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)) 
              - Patindex('%[0-9]/[0-9]/[0-9][0-9]%', NCCurrentText)
        )

    Else
        NULL

End AS ExtractedDate2













