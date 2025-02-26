-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

group_code
tbl_element_desc AS Imp_GroupCode_Desc


*/



SELECT DISTINCT
dw.mkt_house_type AS HouseType_Num
, htyp.tbl_element_desc AS HouseType_Name
    ,Case 
        When dw.mkt_house_type In (11, 12, 13, 14, 15, 16, 21, 22, 23, 24, 25
                , 26, 31, 32, 33, 34, 35, 36, 41, 42, 43, 44, 45, 46, 51, 52, 53, 54
                , 55, 56, 61, 62, 63, 64, 65, 66) 
                Then 'Single_Family_Residence'
        When dw.mkt_house_type In (68) 
            Then 'Condo'
        When dw.mkt_house_type In (69) 
            Then 'Townhouse'
        When dw.mkt_house_type In (71, 72, 73, 74) 
            Then 'Split Entry'
        When dw.mkt_house_type In (75, 76, 77, 78, 79, 80) 
            Then 'Tri-Level'
            
        When dw.mkt_house_type In (82, 83, 84, 85) 
            Then 'MultiFamily'

        When dw.mkt_house_type In (87, 88, 89, 91, 92, 93, 94, 95, 96) 
            Then 'Cabin'        
        --When dw.mkt_house_type In (87, 88, 89) Then 'Cabin'
        --When dw.mkt_house_type In (91, 92, 93, 94, 95, 96) Then 'Log Cabin'
        When dw.mkt_house_type In (97) 
            Then 'Earth Shelter'
        When dw.mkt_house_type In (98, 102) 
            Then 'A-Frame'
        When dw.mkt_house_type In (104, 105, 107, 108, 109, 111, 112, 113, 115, 117, 118, 120, 121) 
            Then 'Mobile Home'
        When dw.mkt_house_type In (124, 125, 127, 128, 129, 131, 132, 133, 135, 136, 137, 140, 141) 
            Then 'NREV Mobile Home'
        Else 'Other'
    End As HouseType_Category


FROM dwellings AS dw 
--ON i.lrsn=dw.lrsn
--      AND dw.status='A'
--        AND i.extension=dw.extension
LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  

ORDER BY HouseType_Num;