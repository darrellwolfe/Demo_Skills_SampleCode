
In SQL, From val_detail AS vd, where vd.group_code is the column in SQL matching the "Code#" in PowerQuery M., I need a case statement in SQL matching the logic of this PowerQuery M conditional column.


if Text.Contains([#"Code#"], "99") then "Non-Allocated_Error"

else if Text.Contains([#"Code#"], "98") then "Non-Allocated_Error"

else if Text.Contains([#"Code#"], "01") then "Timber_Ag"
else if Text.Contains([#"Code#"], "03") then "Timber_Ag"
else if Text.Contains([#"Code#"], "04") then "Timber_Ag"
else if Text.Contains([#"Code#"], "05") then "Timber_Ag"
else if Text.Contains([#"Code#"], "06") then "Timber_Ag"
else if Text.Contains([#"Code#"], "07") then "Timber_Ag"
else if Text.Contains([#"Code#"], "08") then "Timber_Ag"
else if Text.Contains([#"Code#"], "09") then "Timber_Ag"

else if Text.Contains([#"Code#"], "10") then "Residential"
else if Text.Contains([#"Code#"], "11") then "Residential"
else if Text.Contains([#"Code#"], "12") then "Residential"
else if Text.Contains([#"Code#"], "15") then "Residential"
else if Text.Contains([#"Code#"], "20") then "Residential"
else if Text.Contains([#"Code#"], "25") then "Residential"
else if Text.Contains([#"Code#"], "26") then "Residential"
else if Text.Contains([#"Code#"], "30") then "Residential"
else if Text.Contains([#"Code#"], "31") then "Residential"
else if Text.Contains([#"Code#"], "32") then "Residential"
else if Text.Contains([#"Code#"], "33") then "Residential"
else if Text.Contains([#"Code#"], "34") then "Residential"
else if Text.Contains([#"Code#"], "37") then "Residential"
else if Text.Contains([#"Code#"], "41") then "Residential"
else if Text.Contains([#"Code#"], "46") then "Residential"
else if Text.Contains([#"Code#"], "47") then "Residential"
else if Text.Contains([#"Code#"], "48") then "Residential"
else if Text.Contains([#"Code#"], "49") then "Residential"
else if Text.Contains([#"Code#"], "50") then "Residential"
else if Text.Contains([#"Code#"], "55") then "Residential"
else if Text.Contains([#"Code#"], "65") then "Residential"

else if Text.Contains([#"Code#"], "13") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "14") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "16") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "17") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "18") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "21") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "22") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "27") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "35") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "36") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "38") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "39") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "42") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "43") then "Commercial_Industrial"
else if Text.Contains([#"Code#"], "51") then "Commercial_Industrial"

else if Text.Contains([#"Code#"], "19") then "Public_Owned"

else if Text.Contains([#"Code#"], "45") then "Operating_Property"

else if Text.Contains([CodeDescription], "EXEMPT") then "Exempt_Property"

else if Text.Contains([CodeDescription], "OPERATING") then "Operating_Property"

else if Text.Contains([CodeDescription], "QIE") then "Qualified_Improvement_Expenditure"

else if Text.Contains([#"Code#"], "P") then "Business_Personal_Property"



else null