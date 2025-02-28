
Declare @TaxYear int;

-- Dynamically set the TaxYear based on the current date
If GetDate() < DateFromParts(Year(GetDate()), 11, 15)
    Set @TaxYear = Year(GetDate()) - 1; -- Last year until November 15
Else
    Set @TaxYear = Year(GetDate()); -- Current year after November 15

-- Output the TaxYear for verification
--Select @TaxYear as TaxYear;
--Declare @TaxYear int = 2024;


--Select  * FROM LegalParty AS lp

WITH


CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
  Select Distinct
  pm.lrsn
,pm.EffStatus AS AccountStatus
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Desc
, TRIM(pm.TAG) AS TAG
, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip
--, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.AttentionLine) AS Attn
, TRIM(pm.MailingAddress) AS MailingAddress
, TRIM(pm.MailingCityStZip) AS MailingCSZ
, TRIM(pm.DisplayDescr) AS LegalDescription

, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.LegalAcres
,  pm.Improvement_Status -- <Improved vs Vacant


  From TSBv_PARCELMASTER AS pm
  
  Where pm.ClassCD IN ('020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090')
  AND pm.PIN NOT LIKE 'U%'
  AND pm.PIN NOT LIKE 'G%'

  AND pm.EffStatus = 'A'
--Order By District,GEO;
),

CTE_EmailFinder AS (
SELECT DISTINCT
ro.Id AS lrsn,
UPPER(TRIM(lp.DisplayName)) LegalPartyName,
UPPER(TRIM(comm.CommAddr)) AS EmailAddress
/*
ro.Id AS lrsn,
TRIM(ro.PIN) AS PIN,
TRIM(ro.AIN) AS AIN,
lp.Id AS LegalPartyId,
lp.LegalPartyType,
lp.LPSubType,
lpr.PercentInt
*/
FROM LegalParty AS lp

JOIN LegalPartyRole AS lpr
  ON lp.Id = lpr.LegalPartyId
  AND lpr.EffStatus = 'A'
  AND lpr.BegEffDate = (select max(BegEffDate) from LegalPartyRole AS lprsub where lprsub.id = lpr.id )
  AND lpr.PrimeLegalParty = 1

JOIN CommRole AS cr
  ON lp.Id = cr.ObjectId AND cr.EffStatus = 'A'
JOIN Comm AS comm
  ON comm.Id = cr.CommId
  AND CommType = 101851 -- This populates all the non-address options from the CommAddr column, but that also includes phone numbers.
  AND ACType = 101100 -- Email Address

JOIN RevObj AS ro
  ON ro.Id = lpr.ObjectId
  AND ro.EffStatus = 'A'
  AND ro.BegEffDate = (select max(BegEffDate) from RevObj AS rosub where rosub.id = ro.id )
  AND ro.PIN LIKE 'E%'
)






SELECT DISTINCT
--pmd.lrsn,
pmd.Owner,
ef.EmailAddress

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_EmailFinder AS ef
  ON ef.lrsn = pmd.lrsn
ORDER BY Owner









--AND lpr.BegEffDate = (select max(BegEffDate) from LegalPartyRole AS lprsub where lprsub.id = lpr.id AND lprsub.BegEffDate <= @TaxYear)

--AND ro.Id = 41252



/*
SELECT
lp.Id AS LegalPartyId,
lp.LegalPartyType,
lp.LPSubType,
UPPER(TRIM(lp.DisplayName)) LegalPartyName,
UPPER(TRIM(comm.CommAddr)) AS EmailAddress

FROM LegalParty AS lp
JOIN CommRole AS cr
  ON lp.Id = cr.ObjectId AND cr.EffStatus = 'A'
JOIN Comm AS comm
  ON comm.Id = cr.CommId
  AND CommType = 101851 -- This populates all the non-address options from the CommAddr column, but that also includes phone numbers.
  AND ACType = 101100 -- Email Address
*/


--SELECT * FROM CommRole
--SELECT * FROM SysType WHERE shortDescr LIKE '%email%'
--SysType.Id = 101100 -- shortDescr is Email, descr is E-mail Address
--SELECT * FROM Comm WHERE CommType = 101851 and ACType = 101100









--SELECT * FROM Comm WHERE AddrType = 101608
--SELECT * FROM MailAddr --WHERE CRType = 101100


--SELECT DISTINCT AddrType FROM Comm

/*
101600
101601
101602
101603
101604
101605
101606
101607
101608
101609
2000002
*/

--SELECT DISTINCT CommType FROM Comm
/*101850
101851*/


--SELECT * FROM Comm_V
--SELECT * FROM AddrType
--SELECT * FROM ComType
--SELECT * FROM LPSubType

--SELECT * FROM OfficeContact
--SELECT * FROM LegalParty
--SELECT * FROM LegalPartyCombo_V
--SELECT * FROM LegalPartyRole
--SELECT * FROM LegalPartyElement

--SELECT * FROM AltComm


/*
SELECT * FROM information_schema.columns 
WHERE column_name LIKE '%Legal%'
AND column_name LIKE '%Type%'

--WHERE table_name LIKE 'Communication%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;
*/

/*
DECLARE @SearchValue NVARCHAR(255) = 'E-mail Address' -- Replace this with the value you want to search for
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + 
    ' UNION ALL SELECT ''' + s.name + '.' + t.name + ''' AS TableName, ''' + c.name + ''' AS ColumnName, ' + 
    'CAST(' + QUOTENAME(c.name) + ' AS NVARCHAR(MAX)) AS MatchedValue ' + 
    'FROM ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' ' + 
    'WHERE CAST(' + QUOTENAME(c.name) + ' AS NVARCHAR(MAX)) LIKE ''%' + @SearchValue + '%'''
FROM sys.schemas s
INNER JOIN sys.tables t ON s.schema_id = t.schema_id
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE ty.name IN ('char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext')  -- Only text-based columns
AND t.name NOT LIKE 'KCv%' -- Exclude tables with names like 'KCv%'

-- Remove the leading UNION ALL
IF LEN(@SQL) > 0
    SET @SQL = STUFF(@SQL, 1, 10, '');

-- Execute the generated SQL
EXEC sp_executesql @SQL;
*/
