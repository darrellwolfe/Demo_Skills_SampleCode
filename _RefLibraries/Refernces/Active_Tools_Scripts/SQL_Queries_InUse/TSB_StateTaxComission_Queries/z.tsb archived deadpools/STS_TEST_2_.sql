-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

Select Distinct
--LEFT(a.group_code,2) AS GroupCode
*
From allocations AS a
Where status = 'A'

/*

Declare @SalesFromDate DATE = '2022-10-01';
--From date requested by State Tax Commission Rep

Declare @SalesToDate DATE = '2023-12-31';
--To date requested by State Tax Commission Rep

Declare @LastCertifiedStart INT = '20230101';
--01/01 of most recent Assessed Values

Declare @LastCertifiedEnd INT = '20231231';
--12/31 of most recent Assessed Values

Declare @MemoLastUpdatedNoEarlierThan DATE = '2022-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022


Select *

From val_detail AS vd
Where vd.status = 'A'
And vd.eff_year = @LastCertifiedStart
----VARIABLE DATE
And vd.extension IN ('L00')
    And vd.improvement_id IN ('')
    And vd.group_code <> '19'
    And vd.lrsn = 2
    
*/