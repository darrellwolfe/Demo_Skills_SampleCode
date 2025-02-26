--This is for pulling sales from the transfers table
DECLARE @CurrentDate DATE = GETDATE();
DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @Year INT;
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year
Declare @EffYearFrom DATE = Cast(@Year-10 as varchar) + '-01-01'; -- Generates '20230101' for the previous year
Declare @EffYearTo DATE = Cast(@Year as varchar) + '-12-31'; -- Generates '20230101' for the previous year
SELECT
t.lrsn,
UPPER(TRIM(pm.pin)) AS PIN,
UPPER(TRIM(pm.AIN)) AS AIN,
UPPER(TRIM(pm.DisplayName)) AS Owner,
UPPER(TRIM(pm.DisplayDescr)) AS LegalDescription,
UPPER(TRIM(pm.SitusAddress)) AS SitusAddress,
CAST(t.pxfer_date AS DATE) AS [TransferDate],
t.AdjustedSalePrice AS [SalesPrice_ProVal],
YEAR(t.pxfer_date) AS Year,
MONTH(t.pxfer_date) AS Month,
t.DocNum,
t.ConvForm,
t.SaleDesc,
t.TfrType,
t.GrantorName AS [Grantor_Seller],
t.GranteeName AS [Grantee_Buyer],
CAST(t.last_update AS DATE) AS [LastUpdated],
CAST(t.sxfer_date AS DATE) AS [Secondary_Transfer_Date]
FROM transfer AS t
JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn = t.lrsn
WHERE t.status = 'A'
AND t.GrantorName <> t.GranteeName
AND t.pxfer_date BETWEEN @EffYearFrom AND @EffYearTo