
--DECLARE @val_year INT = 2024;
DECLARE @val_year INT;
SET @val_year = YEAR(GETDATE());

DECLARE @val_element VARCHAR(50) = 'MHOME';
--COM-DEPRE
--OB-DEPRE
--RES-DEPRE
--RES-DEPRE-5
--RES-DEPRE-6
--RES-DEPRE-7
--RES-DEPRE-8
--RES-DEPRE-9
--MHOME

/*
Select * 
From val_element_table 
Where val_year = @val_year
And val_element LIKE '%Depre%'
--And val_sub_element LIKE '%Dep%'
Order By val_element
*/

WITH AGE AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'AGE'
),

ABN AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'ABN'
),

BLN AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'BLN'
),

EXE AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'EXE'
),

NML AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'NML'
),

POOR AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'POOR'
),

VGO AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VGO'
),

VPO AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'VPO'
),

SUBGROUP AS (
    Select 1 AS row_num, df1 AS value From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 2, df2 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 3, df3 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 4, df4 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 5, df5 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 6, df6 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 7, df7 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 8, df8 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 9, df9 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 10, df10 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 11, df11 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 12, df12 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 13, df13 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 14, df14 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 15, df15 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 16, df16 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 17, df17 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 18, df18 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 19, df19 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 20, df20 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 21, df21 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 22, df22 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 23, df23 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 24, df24 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 25, df25 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 26, df26 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 27, df27 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 28, df28 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 29, df29 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 30, df30 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 31, df31 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 32, df32 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 33, df33 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 34, df34 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 35, df35 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 36, df36 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 37, df37 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 38, df38 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 39, df39 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 40, df40 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 41, df41 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 42, df42 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 43, df43 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 44, df44 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 45, df45 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 46, df46 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 47, df47 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 48, df48 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 49, df49 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 50, df50 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 51, df51 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 52, df52 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 53, df53 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 54, df54 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 55, df55 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 56, df56 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 57, df57 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 58, df58 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 59, df59 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
    UNION ALL
    Select 60, df60 From val_element_table WHERE val_year = @val_year AND val_element LIKE @val_element  AND val_sub_element = 'SUBGROUP'
)

SELECT
a.row_num
,(Select df1 From val_element_table 
    WHERE val_year = @val_year
    AND val_element LIKE @val_element 
    AND val_sub_element = 'BASEYEAR') AS BaseYear
,a.value AS AGE
,d.value * 0.01 AS EXE_EX_EXELLENT
,g.value * 0.01 AS VGO_VG_VERYGOOD
,b.value * 0.01 AS ABN_GD_GOOD
,e.value * 0.01 AS NML_AV_AVERAGE
,c.value * 0.01 AS BLN_FA_FAIR
,f.value * 0.01 AS POOR_PR_POOR
,h.value * 0.01 AS VPO_VP_VERYPOOR
,i.value * 0.01 AS SUBGROUP

From AGE AS a
Cross Join ABN AS b
Cross Join BLN AS c
Cross Join EXE AS d
Cross Join NML AS e
Cross Join POOR AS f
Cross Join VGO AS g
Cross Join VPO AS h
Cross Join SUBGROUP AS i

Where a.row_num = b.row_num
And a.row_num = c.row_num
And a.row_num = d.row_num
And a.row_num = e.row_num
And a.row_num = f.row_num
And a.row_num = g.row_num
And a.row_num = h.row_num
And a.row_num = i.row_num

Order by a.row_num;



/*
RES-DEPRE   	ABN         	G	@val_year	02/12/@val_year                    	DEPR                	        
RES-DEPRE   	AGE         	G	@val_year	02/12/@val_year                    	AGE                 	        
RES-DEPRE   	BASEYEAR    	G	@val_year	02/12/@val_year                    	VALUE               	YEAR    
RES-DEPRE   	BLN         	G	@val_year	02/12/@val_year                    	DEPR                	        
RES-DEPRE   	EXE         	G	@val_year	02/12/@val_year                    	DEPR                	        
RES-DEPRE   	NML         	G	@val_year	02/12/@val_year                    	DEPR                	        
RES-DEPRE   	POOR        	G	@val_year	02/12/@val_year                    	DEPR                	        
RES-DEPRE   	VGO         	G	@val_year	02/12/@val_year                    	DEPR                	        
RES-DEPRE   	VPO         	G	@val_year	02/12/@val_year                    	DEPR                	        

(Select df1 From val_element_table 
    WHERE val_year = @val_year
    AND val_element LIKE @val_element 
    AND val_sub_element = 'BASEYEAR') AS BaseYear


--- Query 1

Select 1 AS row_num,
df1
,df2
,df3
,df4
,df5
,df6
,df7
,df8
,df9
,df10
,df11
,df12
,df13
,df14
,df15
,df16
,df17
,df18
,df19
,df20
,df21
,df22
,df23
,df24
,df25
,df26
,df27
,df28
,df29
,df30
,df31
,df32
,df33
,df34
,df35
,df36
,df37
,df38
,df39
,df40
,df41
,df42
,df43
,df44
,df45
,df46
,df47
,df48
,df49
,df50
,df51
,df52
From val_element_table 
    WHERE val_year = @val_year
    AND val_element LIKE @val_element
    AND val_sub_element = 'AGE'

--- Query 2

Select
dep.*
FROM val_element_table AS Dep
WHERE val_year = @val_year
--AND val_element LIKE 'RES-DEPRE'
AND val_element LIKE @val_element
--AND val_field = 'DEPR'
--AND val_sub_element = 'AGE'
--AND val_sub_element = 'BASEYEAR'
--AND val_sub_element = 'AGE'
--AND val_element LIKE '%dep%'
ORDER BY 1, 2;
*/
