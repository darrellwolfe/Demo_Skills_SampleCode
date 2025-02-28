-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

Select *
From val_detail
Where status = 'A'
And lrsn = 2
And eff_year LIKE '2024%'

*/

-- First year of Reval
DECLARE @Year INT = 2023;
DECLARE @Year1 VARCHAR(5) = CAST(@Year AS VARCHAR) + '%';
DECLARE @Year2 VARCHAR(5) = CAST(@Year+1 AS VARCHAR) + '%';
DECLARE @Year3 VARCHAR(5) = CAST(@Year+2 AS VARCHAR) + '%';
DECLARE @Year4 VARCHAR(5) = CAST(@Year+3 AS VARCHAR) + '%';
DECLARE @Year5 VARCHAR(5) = CAST(@Year+4 AS VARCHAR) + '%';


WITH

CTE_ParcelBase AS (
Select Distinct
pb.lrsn
,pb.parcel_id
,pb.tax_bill_id
,pb.neighborhood
,CAST(pb.property_class AS VARCHAR) AS pcc
From parcel_base AS pb
Where pb.status = 'A' 
),

CTE_ValDetail AS (
Select
vd.lrsn
,vd.eff_year
,vd.last_update_long
--,CAST(pb.property_class AS VARCHAR) AS gpid1
,LEFT(vd.group_code,2) AS gpid
From val_detail AS vd
Where vd.status = 'A'
--And vd.eff_year LIKE '2024%'
)

Select 
pbi.lrsn
,pbi.parcel_id
,pbi.tax_bill_id
,pbi.neighborhood
,pbi.pcc
,vdi.eff_year
,vdi.last_update_long
,vdi.gpid

From CTE_ParcelBase AS pbi
Left Join CTE_ValDetail AS vdi
  On pbi.lrsn = vdi.lrsn
/*
Where (vdi.eff_year LIKE @Year1
      OR vdi.eff_year LIKE @Year2
      OR vdi.eff_year LIKE @Year3
      OR vdi.eff_year LIKE @Year4
      OR vdi.eff_year LIKE @Year5)
*/
Where vdi.gpid LIKE '%62%'



