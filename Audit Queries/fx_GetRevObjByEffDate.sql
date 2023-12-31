
-- !preview conn=conn

/*
AsTxDBProd
GRM_Main


Power Query direct connected to the database, without using SQL:
1. Pull in the function: 
  GetRevObjByEffDate

Power Query results:
  function(@p_EffDate as nullable datetime) as table
  = Source{[Schema="dbo",Item="GetRevObjByEffDate"]}[Data]

To use SQL for this function:   
GetRevObjByEffDate is a Table-Valued Function
SELECT * FROM dbo.GetRevObjByEffDate('2023-01-01'); -- Replace with your desired date

*/

SELECT * FROM dbo.GetRevObjByEffDate('2023-01-01'); -- Replace with your desired date
