


/*

Server: Permits-Prod
Database: iMS

*/


DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @CurrentDate DATE = GETDATE();



Select Distinct
UPPER(TRIM(b.ParcelNo)) AS PIN,
UPPER(TRIM(b.BaseNo)) AS CaseNumber,
b.baseDisplayDate,

CONCAT(TRIM(b.FullDescription),' ; ',TRIM(b.ShortDescription)) AS CaseDescription,


UPPER(CONCAT(b.HouseNumber,' ',b.StreetName)) AS SiteAddress,
b.City,
b.State,
b.Zip,
Concat(b.lat, ',', b.lon) As GoogleMapsFormatedLatLongs,
b.moneyCharges,
Format(b.Progress, '0.00') + '%' As ProgressPercentage,
Cast(b.IssueDt As date) As IssueDt,
Cast(b.ClosedDt As date) As ClosedDt,
Cast(b.UpdateDt As date) As UpdateDt,
Cast(b.CreateDt As date) As CreateDt,
Cast(b.AppComplDt As date) As AppComplDt,
Cast(b.ApproveDt As date) As ApproveDt,
Cast(b.CancelDt As date) As CancelDt,
Cast(b.ExpireDt As date) As ExpireDt,
Cast(b.FinalDt As date) As FinalDt

--b.*


FROM Base AS b

--FROM Vw_Base_KC AS vwb 
--JOIN Base AS b ON vwb.ID=b.ID
  --AND b.IssueDt > DATEFROMPARTS(YEAR(GETDATE()) - 3, 1, 1)



WHERE b.BaseNo LIKE '%CV%'
AND b.IssueDt > DATEFROMPARTS(YEAR(GETDATE()) - 3, 1, 1)
AND (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')





