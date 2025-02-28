-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/


Select *
From landdetail AS d
Where d.DepthFactor > 1
And d.effstatus = 'A'
And d.LandModelId = 702010
--And d.PostingSource = 702010 -- Gary Logsdon was using the wrong column

