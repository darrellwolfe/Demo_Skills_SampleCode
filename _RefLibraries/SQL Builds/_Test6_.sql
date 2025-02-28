
--DECLARE @val_year INT = 2024;
DECLARE @val_year INT;
SET @val_year = YEAR(GETDATE());

DECLARE @val_element VARCHAR(50) = 'RES-DEPRE';
--COM-DEPRE
--OB-DEPRE
--RES-DEPRE
--RES-DEPRE-5
--RES-DEPRE-6
--RES-DEPRE-7
--RES-DEPRE-8
--RES-DEPRE-9
--MHOME
Select * 
From val_element_table 
Where val_year = @val_year
And val_element = @val_element
--And val_element = 'MHOME'
--And val_element LIKE '%Depre%'
--And val_field LIKE 'DEPR'
--And val_element LIKE '%mh%' 
    -- this table also has mobile home rates, but none of the MH tables have depreciation directly
    -- So this is probably one of the aux depre val elements?
--And val_sub_element LIKE '%Dep%'
Order By val_element
