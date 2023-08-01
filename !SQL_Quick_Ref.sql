/*
SQL Quick Reference Materials from W3Schools

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Most Common References
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- <- ROW_NUMBER
ROW_NUMBER() OVER (PARTITION BY ### ORDER BY ### DESC) AS RowNum

Explained: ROW_NUMBER() OVER (PARTITION BY #GroupByColumn# ORDER BY #FilterOutColumn# DESC) AS RowNum
Example: ROW_NUMBER() OVER (PARTITION BY pm.lrsn ORDER BY v.Last_Updated DESC) AS RowNum

-- <- TRIM
TRIM() 

LTRIM(RTRIM()) <- For SQL Server before 2017 
  vs 
TRIM() <- For SQL Server after 2017

-- <- CTEs
-- -- WITH CTE_NameYouAssign AS (
Example:
  WITH
    CTE_1 AS (),
    CTE_2 AS (),
    CTE_3 AS ()

  SELECT DISTINCT *
  FROM CTE_1 AS 1
  LEFT JOIN CTE_2 AS 2 ON 1.lrsn=2.RevObjId
  LEFT JOIN CTE_3 AS 3 ON 1.lrsn=3.RevObjId

  WHERE... 

-- <- CASE_Single

CASE
  WHEN field1 = 'value1' THEN 'Category1'
  ELSE 'Other'
END AS [YourNewColumnName]

-- <- CASE_Multiple

CASE
  WHEN field1 = 'value1' THEN 'Category1'
  WHEN field1 = 'value2' THEN 'Category2'
  WHEN field1 = 'value3' THEN 'Category3'
  ELSE 'Other'
END AS [YourNewColumnName]


--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Common Syntax References
--------------------------------------------------------------------------------------------------------------------------------------------------------

ASC	Sorts the result set in ascending order
DESC	Sorts the result set in descending order
DISTINCT	Selects only distinct (different) values
BETWEEN	Selects values within a given range
CASE	Creates different outputs based on conditions
LIKE	Searches for a specified pattern in a column
LIMIT	Specifies the number of records to return in the result set
NOT	Only includes rows where a condition is not true
NOT NULL	A constraint that enforces a column to not accept NULL values
UNION	Combines the result set of two or more SELECT statements (only distinct values)
UNION ALL	Combines the result set of two or more SELECT statements (allows duplicate values)



--------------------------------------------------------------------------------------------------------------------------------------------------------
--GPT-4 Explains 
LTRIM(RTRIM()) vs TRIM()

The difference between `LTRIM(RTRIM(pm.pin)) AS [PIN]` and `TRIM(pm.pin) AS [PIN]` in SQL Server comes down to the versions of SQL Server you are using.

Before SQL Server 2017, the `TRIM` function did not exist. So, to remove both leading and trailing spaces, you had to use `LTRIM(RTRIM(pm.pin)) AS [PIN]`. This first applies the `RTRIM` function to remove trailing spaces and then the `LTRIM` function to remove leading spaces.

Starting from SQL Server 2017, Microsoft introduced the `TRIM` function, which removes both leading and trailing spaces from a string. So, in SQL Server 2017 and later versions, you can simply use `TRIM(pm.pin) AS [PIN]` to achieve the same result as `LTRIM(RTRIM(pm.pin)) AS [PIN]`. 

In terms of functionality, there's no practical difference between the two in SQL Server 2017 and later -- they both remove leading and trailing spaces. However, `TRIM` is more concise and easier to read. So if you're using a newer version of SQL Server, I'd recommend using `TRIM` for simplicity.

Do keep in mind that if your scripts need to be backward compatible with versions of SQL Server prior to 2017, you should stick with using `LTRIM(RTRIM())`.

--------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------
TABLE QUERIES - BASICS OF THE CODE YOU NEED TO GRAB INFORMATION FROM A SQL DATABASE, MOST MATERIALS FROM W3 SCHOOLS
https://www.w3schools.com/sql/sql_quickref.asp
--------------------------------------------------------------------------------------------------------------------------------------------------------



--**-- SELECT TYPES

--SELECT
	SELECT column_name(s)
FROM table_name

--SELECT *	
	SELECT *
FROM table_name

--SELECT DISTINCT	
	SELECT DISTINCT column_name(s)
FROM table_name

--SELECT INTO	
	SELECT *
INTO new_table_name [IN externaldatabase]
FROM old_table_name
or

SELECT column_name(s)
INTO new_table_name [IN externaldatabase]
FROM old_table_name

--SELECT TOP	
	SELECT TOP number|percent column_name(s)
FROM table_name

--**--JOIN TYPES

--INNER JOIN	
	SELECT column_name(s)
FROM table_name1
INNER JOIN table_name2
ON table_name1.column_name=table_name2.column_name

--LEFT JOIN	
	SELECT column_name(s)
FROM table_name1
LEFT JOIN table_name2
ON table_name1.column_name=table_name2.column_name

--RIGHT JOIN	
	SELECT column_name(s)
FROM table_name1
RIGHT JOIN table_name2
ON table_name1.column_name=table_name2.column_name

--FULL JOIN	
	SELECT column_name(s)
FROM table_name1
FULL JOIN table_name2
ON table_name1.column_name=table_name2.column_name


--**-- CONDITIONS

--WHERE
	SELECT column_name(s)
FROM table_name
WHERE column_name operator value

--IN
	SELECT column_name(s)
FROM table_name
WHERE column_name
IN (value1,value2,..)

--AS (alias)	
SELECT column_name AS column_alias
FROM table_name
or

SELECT column_name
FROM table_name  AS table_alias

--AND / OR	
SELECT column_name(s)
FROM table_name
WHERE condition
AND|OR condition

--BETWEEN
	SELECT column_name(s)
FROM table_name
WHERE column_name
BETWEEN value1 AND value2

--LIKE
	SELECT column_name(s)
FROM table_name
WHERE column_name LIKE pattern

--**-- ORDERING RESULTS OF QUERY (FOR SELECT, DIFFERENT THAN GROUP BY)

--ORDER BY	
	SELECT column_name(s)
FROM table_name
ORDER BY column_name [ASC|DESC]


--**-- AGGREGATES 


--GROUP BY	
	SELECT column_name, aggregate_function(column_name)
FROM table_name
WHERE column_name operator value
GROUP BY column_name

--HAVING
	SELECT column_name, aggregate_function(column_name)
FROM table_name
WHERE column_name operator value
GROUP BY column_name
HAVING aggregate_function(column_name) operator value


--**--SUB QUERIES

--EXISTS
--The SQL EXISTS Operator
--The EXISTS operator is used to test for the existence of any record in a subquery.
--The EXISTS operator returns TRUE if the subquery returns one or more records.

IF EXISTS (SELECT * FROM table_name WHERE id = ?)
BEGIN
--do what needs to be done if exists
END
ELSE
BEGIN
--do what needs to be done if not
END

--CTE ((WITH common_table_expression)) (Transact-SQL)
https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16

WITH CTE_NameYouAssign
AS (
SELECT
   column1
   column2
   column3
   ROW_NUMBER() OVER (PARTITION BY column3 ORDER BY column1 DESC) AS RowNum
FROM TableNameYouAreReferencing AS aliashere
WHERE columnwhatever = 'some condition'
) 

SELECT DISTINCT
a.column1
a.column2
a.column3
a.column4
a.column5
b.column -- from CTE above, uses table join alias below, this is the part that confused me. 

FROM primarytable AS a
LEFT OUTER JOIN CTE_NameYouAssign AS b ON a.columnkey=b.columnkey
WHERE a.column1 = 'some condition'
AND a.column2 = 'some condition'
ORDER BY columnwhatever;



--**-- COMBINING QUERIES

--**-- APPEND TWO MATCHING TABLES (LIKE APPEND IN POWER QUERY)
--UNION
	SELECT column_name(s) FROM table_name1
UNION
SELECT column_name(s) FROM table_name2

--UNION ALL	
	SELECT column_name(s) FROM table_name1
UNION ALL
SELECT column_name(s) FROM table_name2




--------------------------------------------------------------------------------------------------------------------------------------------------------
QUERY-ONLY ABOVE THIS LINE
DATABASE ALTERING CODE BELOW THIS LINE, USE CAUTION, RUN IN TEST BEFORE COMMITTING CHANGES

FOR PRACTICE OR PERSONAL USE SEE:
SQL Server 2022 Express is a free edition of SQL Server, ideal for development and production for desktop, web, and small server applications.
https://www.microsoft.com/en-us/sql-server/sql-server-downloads?rtc=1

--------------------------------------------------------------------------------------------------------------------------------------------------------

--** DATABASE & TABLE MAINTENCE
--**--DATABASE MAINTENCE
--CREATE DATABASE	
CREATE DATABASE database_name

--DROP DATABASE	
DROP DATABASE database_name



--**--TABLE MAINTENCE

--CREATE TABLE	
	CREATE TABLE table_name
(
column_name1 data_type,
column_name2 data_type,
column_name3 data_type,
...
)

--CREATE INDEX	
	CREATE INDEX index_name
ON table_name (column_name)
or

CREATE UNIQUE INDEX index_name
ON table_name (column_name)

--INSERT INTO	
	INSERT INTO table_name
VALUES (value1, value2, value3,....)
or

INSERT INTO table_name
(column1, column2, column3,...)
VALUES (value1, value2, value3,....)


--CREATE VIEW	
	CREATE VIEW view_name AS
SELECT column_name(s)
FROM table_name
WHERE condition


--DELETE
	DELETE FROM table_name
WHERE some_column=some_value
or

DELETE FROM table_name
(Note: Deletes the entire table!!)

DELETE * FROM table_name
(Note: Deletes the entire table!!)

--DROP INDEX	
	DROP INDEX table_name.index_name (SQL Server)
DROP INDEX index_name ON table_name (MS Access)
DROP INDEX index_name (DB2/Oracle)
ALTER TABLE table_name
DROP INDEX index_name (MySQL)


--DROP TABLE	
DROP TABLE table_name


--ALTER TABLE	
ALTER TABLE table_name
ADD column_name datatype
or

--ALTER TABLE table_name
DROP COLUMN column_name

--TRUNCATE TABLE	
TRUNCATE TABLE table_name

--UPDATE
	UPDATE table_name
SET column1=value, column2=value,...
WHERE some_column=some_value





--------------------------------------------------------------------------------------------------------------------------------------------------------
SQL Keywords Reference
https://www.w3schools.com/sql/sql_ref_keywords.asp
--------------------------------------------------------------------------------------------------------------------------------------------------------
Keyword Description
ADD	Adds a column in an existing table
ADD CONSTRAINT	Adds a constraint after a table is already created
ALL	Returns true if all of the subquery values meet the condition
ALTER	Adds, deletes, or modifies columns in a table, or changes the data type of a column in a table
ALTER COLUMN	Changes the data type of a column in a table
ALTER TABLE	Adds, deletes, or modifies columns in a table
AND	Only includes rows where both conditions is true
ANY	Returns true if any of the subquery values meet the condition
AS	Renames a column or table with an alias
ASC	Sorts the result set in ascending order
BACKUP DATABASE	Creates a back up of an existing database
BETWEEN	Selects values within a given range
CASE	Creates different outputs based on conditions
CHECK	A constraint that limits the value that can be placed in a column
COLUMN	Changes the data type of a column or deletes a column in a table
CONSTRAINT	Adds or deletes a constraint
CREATE	Creates a database, index, view, table, or procedure
CREATE DATABASE	Creates a new SQL database
CREATE INDEX	Creates an index on a table (allows duplicate values)
CREATE OR REPLACE VIEW	Updates a view
CREATE TABLE	Creates a new table in the database
CREATE PROCEDURE	Creates a stored procedure
CREATE UNIQUE INDEX	Creates a unique index on a table (no duplicate values)
CREATE VIEW	Creates a view based on the result set of a SELECT statement
DATABASE	Creates or deletes an SQL database
DEFAULT	A constraint that provides a default value for a column
DELETE	Deletes rows from a table
DESC	Sorts the result set in descending order
DISTINCT	Selects only distinct (different) values
DROP	Deletes a column, constraint, database, index, table, or view
DROP COLUMN	Deletes a column in a table
DROP CONSTRAINT	Deletes a UNIQUE, PRIMARY KEY, FOREIGN KEY, or CHECK constraint
DROP DATABASE	Deletes an existing SQL database
DROP DEFAULT	Deletes a DEFAULT constraint
DROP INDEX	Deletes an index in a table
DROP TABLE	Deletes an existing table in the database
DROP VIEW	Deletes a view
EXEC	Executes a stored procedure
EXISTS	Tests for the existence of any record in a subquery
FOREIGN KEY	A constraint that is a key used to link two tables together
FROM	Specifies which table to select or delete data from
FULL OUTER JOIN	Returns all rows when there is a match in either left table or right table
GROUP BY	Groups the result set (used with aggregate functions: COUNT, MAX, MIN, SUM, AVG)
HAVING	Used instead of WHERE with aggregate functions
IN	Allows you to specify multiple values in a WHERE clause
INDEX	Creates or deletes an index in a table
INNER JOIN	Returns rows that have matching values in both tables
INSERT INTO	Inserts new rows in a table
INSERT INTO SELECT	Copies data from one table into another table
IS NULL	Tests for empty values
IS NOT NULL	Tests for non-empty values
JOIN	Joins tables
LEFT JOIN	Returns all rows from the left table, and the matching rows from the right table
LIKE	Searches for a specified pattern in a column
LIMIT	Specifies the number of records to return in the result set
NOT	Only includes rows where a condition is not true
NOT NULL	A constraint that enforces a column to not accept NULL values
OR	Includes rows where either condition is true
ORDER BY	Sorts the result set in ascending or descending order
OUTER JOIN	Returns all rows when there is a match in either left table or right table
PRIMARY KEY	A constraint that uniquely identifies each record in a database table
PROCEDURE	A stored procedure
RIGHT JOIN	Returns all rows from the right table, and the matching rows from the left table
ROWNUM	Specifies the number of records to return in the result set
SELECT	Selects data from a database
SELECT DISTINCT	Selects only distinct (different) values
SELECT INTO	Copies data from one table into a new table
SELECT TOP	Specifies the number of records to return in the result set
SET	Specifies which columns and values that should be updated in a table
TABLE	Creates a table, or adds, deletes, or modifies columns in a table, or deletes a table or data inside a table
TOP	Specifies the number of records to return in the result set
TRUNCATE TABLE	Deletes the data inside a table, but not the table itself
UNION	Combines the result set of two or more SELECT statements (only distinct values)
UNION ALL	Combines the result set of two or more SELECT statements (allows duplicate values)
UNIQUE	A constraint that ensures that all values in a column are unique
UPDATE	Updates existing rows in a table
VALUES	Specifies the values of an INSERT INTO statement
VIEW	Creates, updates, or deletes a view
WHERE	Filters a result set to include only records that fulfill a specified condition




--------------------------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL RESOURCES - SQL Server Functions
https://www.w3schools.com/sql/sql_ref_sqlserver.asp
--------------------------------------------------------------------------------------------------------------------------------------------------------
--SQL Server String Functions
Function	Description
ASCII	Returns the ASCII value for the specific character
CHAR	Returns the character based on the ASCII code
CHARINDEX	Returns the position of a substring in a string
CONCAT	Adds two or more strings together
Concat with +	Adds two or more strings together
CONCAT_WS	Adds two or more strings together with a separator
DATALENGTH	Returns the number of bytes used to represent an expression
DIFFERENCE	Compares two SOUNDEX values, and returns an integer value
FORMAT	Formats a value with the specified format
LEFT	Extracts a number of characters from a string (starting from left)
LEN	Returns the length of a string
LOWER	Converts a string to lower-case
LTRIM	Removes leading spaces from a string
NCHAR	Returns the Unicode character based on the number code
PATINDEX	Returns the position of a pattern in a string
QUOTENAME	Returns a Unicode string with delimiters added to make the string a valid SQL Server delimited identifier
REPLACE	Replaces all occurrences of a substring within a string, with a new substring
REPLICATE	Repeats a string a specified number of times
REVERSE	Reverses a string and returns the result
RIGHT	Extracts a number of characters from a string (starting from right)
RTRIM	Removes trailing spaces from a string
SOUNDEX	Returns a four-character code to evaluate the similarity of two strings
SPACE	Returns a string of the specified number of space characters
STR	Returns a number as string
STUFF	Deletes a part of a string and then inserts another part into the string, starting at a specified position
SUBSTRING	Extracts some characters from a string
TRANSLATE	Returns the string from the first argument after the characters specified in the second argument are translated into the characters specified in the third argument.
TRIM	Removes leading and trailing spaces (or other specified characters) from a string
UNICODE	Returns the Unicode value for the first character of the input expression
UPPER	Converts a string to upper-case


--SQL Server Math/Numeric Functions
Function	Description
ABS	Returns the absolute value of a number
ACOS	Returns the arc cosine of a number
ASIN	Returns the arc sine of a number
ATAN	Returns the arc tangent of a number
ATN2	Returns the arc tangent of two numbers
AVG	Returns the average value of an expression
CEILING	Returns the smallest integer value that is >= a number
COUNT	Returns the number of records returned by a select query
COS	Returns the cosine of a number
COT	Returns the cotangent of a number
DEGREES	Converts a value in radians to degrees
EXP	Returns e raised to the power of a specified number
FLOOR	Returns the largest integer value that is <= to a number
LOG	Returns the natural logarithm of a number, or the logarithm of a number to a specified base
LOG10	Returns the natural logarithm of a number to base 10
MAX	Returns the maximum value in a set of values
MIN	Returns the minimum value in a set of values
PI	Returns the value of PI
POWER	Returns the value of a number raised to the power of another number
RADIANS	Converts a degree value into radians
RAND	Returns a random number
ROUND	Rounds a number to a specified number of decimal places
SIGN	Returns the sign of a number
SIN	Returns the sine of a number
SQRT	Returns the square root of a number
SQUARE	Returns the square of a number
SUM	Calculates the sum of a set of values
TAN	Returns the tangent of a number


--SQL Server Date Functions
Function	Description
CURRENT_TIMESTAMP	Returns the current date and time
DATEADD	Adds a time/date interval to a date and then returns the date
DATEDIFF	Returns the difference between two dates
DATEFROMPARTS	Returns a date from the specified parts (year, month, and day values)
DATENAME	Returns a specified part of a date (as string)
DATEPART	Returns a specified part of a date (as integer)
DAY	Returns the day of the month for a specified date
GETDATE	Returns the current database system date and time
GETUTCDATE	Returns the current database system UTC date and time
ISDATE	Checks an expression and returns 1 if it is a valid date, otherwise 0
MONTH	Returns the month part for a specified date (a number from 1 to 12)
SYSDATETIME	Returns the date and time of the SQL Server
YEAR	Returns the year part for a specified date

--SQL Server Advanced Functions
Function	Description
CAST	Converts a value (of any type) into a specified datatype
COALESCE	Returns the first non-null value in a list
CONVERT	Converts a value (of any type) into a specified datatype
CURRENT_USER	Returns the name of the current user in the SQL Server database
IIF	Returns a value if a condition is TRUE, or another value if a condition is FALSE
ISNULL	Return a specified value if the expression is NULL, otherwise return the expression
ISNUMERIC	Tests whether an expression is numeric
NULLIF	Returns NULL if two expressions are equal
SESSION_USER	Returns the name of the current user in the SQL Server database
SESSIONPROPERTY	Returns the session settings for a specified option
SYSTEM_USER	Returns the login name for the current user
USER_NAME	Returns the database user name based on the specified id


--------------------------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL RESOURCES - MySQL Functions
https://www.w3schools.com/sql/sql_ref_mysql.asp
--------------------------------------------------------------------------------------------------------------------------------------------------------
--MySQL String Functions
Function	Description
ASCII	Returns the ASCII value for the specific character
CHAR_LENGTH	Returns the length of a string (in characters)
CHARACTER_LENGTH	Returns the length of a string (in characters)
CONCAT	Adds two or more expressions together
CONCAT_WS	Adds two or more expressions together with a separator
FIELD	Returns the index position of a value in a list of values
FIND_IN_SET	Returns the position of a string within a list of strings
FORMAT	Formats a number to a format like "#,###,###.##", rounded to a specified number of decimal places
INSERT	Inserts a string within a string at the specified position and for a certain number of characters
INSTR	Returns the position of the first occurrence of a string in another string
LCASE	Converts a string to lower-case
LEFT	Extracts a number of characters from a string (starting from left)
LENGTH	Returns the length of a string (in bytes)
LOCATE	Returns the position of the first occurrence of a substring in a string
LOWER	Converts a string to lower-case
LPAD	Left-pads a string with another string, to a certain length
LTRIM	Removes leading spaces from a string
MID	Extracts a substring from a string (starting at any position)
POSITION	Returns the position of the first occurrence of a substring in a string
REPEAT	Repeats a string as many times as specified
REPLACE	Replaces all occurrences of a substring within a string, with a new substring
REVERSE	Reverses a string and returns the result
RIGHT	Extracts a number of characters from a string (starting from right)
RPAD	Right-pads a string with another string, to a certain length
RTRIM	Removes trailing spaces from a string
SPACE	Returns a string of the specified number of space characters
STRCMP	Compares two strings
SUBSTR	Extracts a substring from a string (starting at any position)
SUBSTRING	Extracts a substring from a string (starting at any position)
SUBSTRING_INDEX	Returns a substring of a string before a specified number of delimiter occurs
TRIM	Removes leading and trailing spaces from a string
UCASE	Converts a string to upper-case
UPPER	Converts a string to upper-case

--MySQL Numeric Functions
Function	Description
ABS	Returns the absolute value of a number
ACOS	Returns the arc cosine of a number
ASIN	Returns the arc sine of a number
ATAN	Returns the arc tangent of one or two numbers
ATAN2	Returns the arc tangent of two numbers
AVG	Returns the average value of an expression
CEIL	Returns the smallest integer value that is >= to a number
CEILING	Returns the smallest integer value that is >= to a number
COS	Returns the cosine of a number
COT	Returns the cotangent of a number
COUNT	Returns the number of records returned by a select query
DEGREES	Converts a value in radians to degrees
DIV	Used for integer division
EXP	Returns e raised to the power of a specified number
FLOOR	Returns the largest integer value that is <= to a number
GREATEST	Returns the greatest value of the list of arguments
LEAST	Returns the smallest value of the list of arguments
LN	Returns the natural logarithm of a number
LOG	Returns the natural logarithm of a number, or the logarithm of a number to a specified base
LOG10	Returns the natural logarithm of a number to base 10
LOG2	Returns the natural logarithm of a number to base 2
MAX	Returns the maximum value in a set of values
MIN	Returns the minimum value in a set of values
MOD	Returns the remainder of a number divided by another number
PI	Returns the value of PI
POW	Returns the value of a number raised to the power of another number
POWER	Returns the value of a number raised to the power of another number
RADIANS	Converts a degree value into radians
RAND	Returns a random number
ROUND	Rounds a number to a specified number of decimal places
SIGN	Returns the sign of a number
SIN	Returns the sine of a number
SQRT	Returns the square root of a number
SUM	Calculates the sum of a set of values
TAN	Returns the tangent of a number
TRUNCATE	Truncates a number to the specified number of decimal places

--MySQL Date Functions
Function	Description
ADDDATE	Adds a time/date interval to a date and then returns the date
ADDTIME	Adds a time interval to a time/datetime and then returns the time/datetime
CURDATE	Returns the current date
CURRENT_DATE	Returns the current date
CURRENT_TIME	Returns the current time
CURRENT_TIMESTAMP	Returns the current date and time
CURTIME	Returns the current time
DATE	Extracts the date part from a datetime expression
DATEDIFF	Returns the number of days between two date values
DATE_ADD	Adds a time/date interval to a date and then returns the date
DATE_FORMAT	Formats a date
DATE_SUB	Subtracts a time/date interval from a date and then returns the date
DAY	Returns the day of the month for a given date
DAYNAME	Returns the weekday name for a given date
DAYOFMONTH	Returns the day of the month for a given date
DAYOFWEEK	Returns the weekday index for a given date
DAYOFYEAR	Returns the day of the year for a given date
EXTRACT	Extracts a part from a given date
FROM_DAYS	Returns a date from a numeric datevalue
HOUR	Returns the hour part for a given date
LAST_DAY	Extracts the last day of the month for a given date
LOCALTIME	Returns the current date and time
LOCALTIMESTAMP	Returns the current date and time
MAKEDATE	Creates and returns a date based on a year and a number of days value
MAKETIME	Creates and returns a time based on an hour, minute, and second value
MICROSECOND	Returns the microsecond part of a time/datetime
MINUTE	Returns the minute part of a time/datetime
MONTH	Returns the month part for a given date
MONTHNAME	Returns the name of the month for a given date
NOW	Returns the current date and time
PERIOD_ADD	Adds a specified number of months to a period
PERIOD_DIFF	Returns the difference between two periods
QUARTER	Returns the quarter of the year for a given date value
SECOND	Returns the seconds part of a time/datetime
SEC_TO_TIME	Returns a time value based on the specified seconds
STR_TO_DATE	Returns a date based on a string and a format
SUBDATE	Subtracts a time/date interval from a date and then returns the date
SUBTIME	Subtracts a time interval from a datetime and then returns the time/datetime
SYSDATE	Returns the current date and time
TIME	Extracts the time part from a given time/datetime
TIME_FORMAT	Formats a time by a specified format
TIME_TO_SEC	Converts a time value into seconds
TIMEDIFF	Returns the difference between two time/datetime expressions
TIMESTAMP	Returns a datetime value based on a date or datetime value
TO_DAYS	Returns the number of days between a date and date "0000-00-00"
WEEK	Returns the week number for a given date
WEEKDAY	Returns the weekday number for a given date
WEEKOFYEAR	Returns the week number for a given date
YEAR	Returns the year part for a given date
YEARWEEK	Returns the year and week number for a given date

--MySQL Advanced Functions
Function	Description
BIN	Returns a binary representation of a number
BINARY	Converts a value to a binary string
CASE	Goes through conditions and return a value when the first condition is met
CAST	Converts a value (of any type) into a specified datatype
COALESCE	Returns the first non-null value in a list
CONNECTION_ID	Returns the unique connection ID for the current connection
CONV	Converts a number from one numeric base system to another
CONVERT	Converts a value into the specified datatype or character set
CURRENT_USER	Returns the user name and host name for the MySQL account that the server used to authenticate the current client
DATABASE	Returns the name of the current database
IF	Returns a value if a condition is TRUE, or another value if a condition is FALSE
IFNULL	Return a specified value if the expression is NULL, otherwise return the expression
ISNULL	Returns 1 or 0 depending on whether an expression is NULL
LAST_INSERT_ID	Returns the AUTO_INCREMENT id of the last row that has been inserted or updated in a table
NULLIF	Compares two expressions and returns NULL if they are equal. Otherwise, the first expression is returned
SESSION_USER	Returns the current MySQL user name and host name
SYSTEM_USER	Returns the current MySQL user name and host name
USER	Returns the current MySQL user name and host name
VERSION	Returns the current version of the MySQL database




--------------------------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL RESOURCES - CTE EXPLAINED

--Basic structure, layman's terms. A Common Table Expression (CTE) can be used many ways, 
but for the most basic use, think of it as a sub-query, or temp-query that you can reference within your primary query. 

In Microsoft Power Query (Excel/PowerBI), this would be akin to pulling in a table as "connection only", 
doing some transformations within that connection only table,
and then referencing or merging that connection only table into your final results. 
But unlike PowerQuery tables, you can do all the transformations in a few lines of code, without pulling in millions of rows of data before transformations.

//Start Example CTE
--CTE PRECEDING MAIN QUERY, This is you sub-query, or "connection only" query, which you will reference in your final query(s).
--CTE can be used to get a RowNum as below, MAX, AVERAGE, SUM, etc.

WITH CTE_TableNameYouAssign
AS (
SELECT
   column1
   column2
   column3
   ROW_NUMBER() OVER (PARTITION BY column3 ORDER BY column1 DESC) AS RowNum
   
FROM TableNameYouAreReferencing AS aliashere
WHERE columnwhatever = 'some condition'
)

--MAIN QUERY STARTS HERE, Now you will build the original query you wanted, and pull in the results of the CTE (often just the one column you needed).
--Select Statements 
SELECT DISTINCT
a.column1
a.column2
a.column3
a.column4
a.column5
b.column -- from CTE above, uses table join alias below, this is the part that confused me. 

--From, Join Where(s), Order By
FROM primarytable AS a
LEFT OUTER JOIN CTE_TableNameYouAssign AS b ON a.columnkey=b.columnkey
WHERE a.column1 = 'some condition'
AND a.column2 = 'some condition'
ORDER BY columnwhatever;

//End Example CTE




--**--An example I've actually used with a CTE, Treasurer_Warrants
//Begin example

--CTE PRECEDING MAIN QUERY

WITH CTE_DescrHeader AS (
    SELECT
        dh.Id,
        dh.BegEffDate,
        dh.TranId,
        dh.RevObjId,
        dh.DescrHeaderType,
        dh.DisplayDescr,
        ROW_NUMBER() OVER (PARTITION BY dh.RevObjId ORDER BY dh.BegEffDate DESC) AS RowNum
    FROM DescrHeader AS dh
    WHERE dh.EffStatus = 'A'
)

--MAIN QUERY STARTS HERE

--Select Statements 

SELECT DISTINCT
--Demographics
LTRIM(RTRIM(kcv.ain)) AS [AIN], 
LTRIM(RTRIM(kcv.pin)) AS [PIN], 
LTRIM(RTRIM(pb.OwnerName1)) AS [Owner],
LTRIM(RTRIM(pb.OwnerName2)) AS [AltOwner],
LTRIM(RTRIM(kcv.AttentionLine)) AS [Comm_Attn],
LTRIM(RTRIM(kcv.MailingAddress)) AS [MailingAddress],
LTRIM(RTRIM(kcv.MailingCityStZip)) AS [Mailing_CSZ],
LTRIM(RTRIM(pb.OwnerCountry)) AS [OwnerCountry],
LTRIM(RTRIM(kcv.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(kcv.DisplayDescr)) AS [LegalDescription],
dd.DisplayDescr AS [ParcelBase_LegalDesc],
--Amounts (incomplete, still searching for these figures)
del.TaxAmount AS [TaxDue],
del.PenAmount AS [Penalty],
del.IntAmount AS [Interest],
del.FeeAmount AS [Fees],
--Year, Vin, Make, if applicable
i.year_built AS [YearBuilt],
LTRIM(RTRIM(mh.mh_serial_num)) AS [VIN],
LTRIM(RTRIM(ct.tbl_element_desc)) AS [Make]

--From tables/joined tables

FROM KCv_PARCELMASTER1 AS kcv 
LEFT OUTER JOIN parcel_base_data AS pb ON kcv.lrsn=pb.lrsn
LEFT OUTER JOIN CTE_DescrHeader AS dd ON pb.lrsn=dd.RevObjId
LEFT OUTER JOIN manuf_housing AS mh ON kcv.lrsn=mh.lrsn
LEFT OUTER JOIN codes_table AS ct ON mh.mh_make=ct.tbl_element AND ct.tbl_type_code='mhmake'
LEFT OUTER JOIN improvements AS i ON mh.lrsn=i.lrsn AND mh.extension=i.extension
LEFT OUTER JOIN eGovDelq_T AS del ON kcv.lrsn=del.RevObjId

--Where conditions
WHERE kcv.EffStatus='A'
AND pb.status='A'
AND mh.status='A'
AND i.status='A'
AND dd.RowNum = 1
AND i.improvement_id='M'
AND kcv.pin NOT LIKE 'GENERAL PARCEL'
AND kcv.pin LIKE 'M%'
    OR kcv.pin LIKE 'L%'
    OR kcv.pin LIKE 'G%'
    OR kcv.pin LIKE 'E%'
    OR (kcv.pin LIKE 'R%' AND kcv.DisplayDescr LIKE '%Golden Spike%')
    OR (kcv.pin LIKE 'U%' AND kcv.ClassCD='010 Operating Property')
    OR (kcv.pin LIKE '%' AND kcv.DisplayDescr LIKE '%PP On Real%')

ORDER BY [PIN];
//End example
















--**--Microsoft SQL Server 2022:
WITH common_table_expression (Transact-SQL)
https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16
Specifies a temporary named result set, known as a common table expression (CTE). 
This is derived from a simple query and defined within the execution scope of a single SELECT, INSERT, UPDATE, DELETE or MERGE statement. 
This clause can also be used in a CREATE VIEW statement as part of its defining SELECT statement. 
A common table expression can include references to itself. This is referred to as a recursive common table expression.


The following guidelines apply to nonrecursive common table expressions. For guidelines that apply to recursive common table expressions, see Guidelines for Defining and Using Recursive Common Table Expressions that follows.

A CTE must be followed by a single SELECT, INSERT, UPDATE, or DELETE statement that references some or all the CTE columns. 
A CTE can also be specified in a CREATE VIEW statement as part of the defining SELECT statement of the view.
Multiple CTE query definitions can be defined in a nonrecursive CTE. The definitions must be combined by one of these set operators: UNION ALL, UNION, INTERSECT, or EXCEPT.
A CTE can reference itself and previously defined CTEs in the same WITH clause. Forward referencing isn't allowed.
Specifying more than one WITH clause in a CTE isn't allowed. For example, 
	if a CTE_query_definition contains a subquery, that subquery can't contain a nested WITH clause that defines another CTE.

The following clauses can't be used in the CTE_query_definition:

ORDER BY (except when a TOP clause is specified)
INTO
OPTION clause with query hints
FOR BROWSE

When a CTE is used in a statement that is part of a batch, the statement before it must be followed by a semicolon.
A query referencing a CTE can be used to define a cursor.
Tables on remote servers can be referenced in the CTE.
When executing a CTE, any hints that reference a CTE may conflict with other hints that are discovered when the CTE accesses its underlying tables, in the same manner as hints that reference views in queries. When this occurs, the query returns an error.

--**-- SQLSHACK
SQL Server Common Table Expressions (CTE)
https://www.sqlshack.com/sql-server-common-table-expressions-cte/
A Common Table Expression, also called as CTE in short form, 
is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 
The CTE can also be used in a View.

EXPLANATION:
The CTE query starts with a ?With? and is followed by the Expression Name. 
We will be using this expression name in our select query to display the result of our CTE Query and be writing our CTE query definition.
To view the CTE result we use a Select query with the CTE expression name.

-EXAMPLE:
WITH expression_name [ ( column_name [,...n] ) ] 
AS 
( CTE_query_definition )
Select [Column1,Column2,Column3 ?..] from expression_name

--Or

WITH expression_name [ ( column_name [,...n] ) ] 
AS 
( CTE_query_definition )
Select * from expression_name

--CTE with Union All
In order to display the result from start date to end date one by one as recursive, we use a Union All to increment RowNo, 
to add the day one by one till the condition satisfied the date range, in order to stop the recursion we need set some condition. 
In this example, we repeat the recursion to display our records until the date is less than or equal to the end date.

-EXAMPLE
declare @startDate datetime,  
        @endDate datetime;  
  
select  @startDate = getdate(),  
        @endDate = getdate()+16;  
-- select @sDate StartDate,@eDate EndDate  
;with myCTE as  
   (  
      select 1 as ROWNO,@startDate StartDate,'W - '+convert(varchar(2),  
            DATEPART( wk, @startDate))+' / D ('+convert(varchar(2),@startDate,106)+')' as 'WeekNumber'       
  union all  
       select  ROWNO+1 ,dateadd(DAY, 1, StartDate) ,  
              'W - '+convert(varchar(2),DATEPART( wk, StartDate))+' / D ('+convert(varchar(2),  
               dateadd(DAY, 1, StartDate),106)+')' as 'WeekNumber'     
  FROM  myCTE  
  WHERE dateadd(DAY, 1, StartDate)<=  @endDate    
    )  
select ROWNO,Convert(varchar(10),StartDate,105)  as StartDate ,WeekNumber from myCTE 




--ANOTHER EXAMPLE FROM SQL SERVER TUTORIAL
https://www.sqlservertutorial.net/sql-server-basics/sql-server-cte/

WITH cte_sales AS (
    SELECT 
        staff_id, 
        COUNT(*) order_count  
    FROM
        sales.orders
    WHERE 
        YEAR(order_date) = 2018
    GROUP BY
        staff_id
)

SELECT
    AVG(order_count) average_orders_by_staff
FROM 
    cte_sales;




--MORE EXAMPLES AT MS SQL TIPS
https://www.mssqltips.com/sqlservertip/6861/cte-in-sql-server-examples/
-EX 1

WITH Sum_OrderQuantity_CTE
AS (
SELECT ProductKey
,EnglishMonthName
,SUM(OrderQuantity) AS TotalOrdersByMonth
FROM [dbo].[FactInternetSales] fs
INNER JOIN [dbo].[DimDate] dd ON dd.DateKey = fs.OrderDateKey
GROUP BY ProductKey, EnglishMonthName

)
SELECT ProductKey, AVG(TotalOrdersByMonth) AS 'Average Total Orders By Month'
FROM Sum_OrderQuantity_CTE
GROUP BY ProductKey
ORDER BY ProductKey

-EX 2
WITH Simple_CTE
AS (
   SELECT dd.CalendarYear
      ,fs.OrderDateKey
      ,fs.ProductKey
      ,fs.OrderQuantity * fs.UnitPrice AS TotalSale
      ,dc.FirstName
      ,dc.LastName
   FROM [dbo].[FactInternetSales] fs
   INNER JOIN [dbo].[DimCustomer] dc ON dc.CustomerKey = fs.CustomerKey
   INNER JOIN [dbo].[DimDate] dd ON dd.DateKey = fs.OrderDateKey
   )
SELECT *
FROM Simple_CTE


--------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL RESOURCES - 
--------------------------------------------------------------------------------------------------------------------------------------------------------






*/