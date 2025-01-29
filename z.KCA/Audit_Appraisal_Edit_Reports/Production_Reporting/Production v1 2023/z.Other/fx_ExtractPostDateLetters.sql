-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
LTRIM(RTRIM())

Cannot use this, with read-only access to the db,
but this would have been awesome. 

*/


CREATE FUNCTION dbo.ExtractPostDateLetters (@input NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @datePattern NVARCHAR(20) = '%[0-9]/[0-9][0-9]%'
    DECLARE @startIndex INT = PATINDEX(@datePattern, @input)
    DECLARE @result NVARCHAR(MAX) = ''

    IF @startIndex > 0
    BEGIN
        -- Find the end of the date pattern
        SET @startIndex = @startIndex + LEN(SUBSTRING(@input, @startIndex, PATINDEX('%[^0-9/]%', SUBSTRING(@input, @startIndex, LEN(@input))) + 1)) - 1
        
        -- Extract the letters after the date
        SET @result = SUBSTRING(@input, @startIndex + 1, PATINDEX('%[^A-Z]%', SUBSTRING(@input, @startIndex + 1, LEN(@input))) - 1)
    END

    RETURN LTRIM(RTRIM(@result))
END


SELECT
    ColumnName,
    dbo.ExtractPostDateLetters(ColumnName) AS PostDateLetters
FROM
    YourTableName
