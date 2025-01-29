// Conditional Columns CDA Permits, Permit Types

//Mechanicals
if Text.Contains([DESCRIPTION], "MECHANICAL") then "9"

else if Text.Contains([DESCRIPTION], "SIGN") then "9"
else if Text.Contains([DESCRIPTION], "TANK") then "9"
else if Text.Contains([DESCRIPTION], "DRIVEWAY") then "9"





// RESIDENTIAL
else if Text.Contains([DESCRIPTION], "HOME") then "1"
else if Text.Contains([DESCRIPTION], "RES") then "1"
else if Text.Contains([DESCRIPTION], "HOUSE") then "1"

//OUTBUILDING
else if Text.Contains([DESCRIPTION], "SHOP") then "4"
else if Text.Contains([DESCRIPTION], "CARPORT") then "4"
else if Text.Contains([DESCRIPTION], "SHED") then "4"

// ADD ALT
else if Text.Contains([DESCRIPTION], "ADD") then "3"
else if Text.Contains([DESCRIPTION], "DRIVEWAY") then "3"
else if Text.Contains([DESCRIPTION], "PATIO") then "3"
else if Text.Contains([DESCRIPTION], "PORCH") then "3"

//COMMERCIAL
else if Text.Contains([DESCRIPTION], "COM") then "2"
else if Text.Contains([DESCRIPTION], "STORE") then "2"
else if Text.Contains([DESCRIPTION], "BUILDING") then "2"
else if Text.Contains([DESCRIPTION], "COURT") then "2"
else if Text.Contains([DESCRIPTION], "GUNS") then "2"
else if Text.Contains([DESCRIPTION], "BUILDING") then "2"


// 


//else if Text.Contains([DESCRIPTION], "XXXXXXX") then "9"

//else if Text.Contains([DESCRIPTION], "XXXXXXX") then "9"



else "ASSIGN_PERMIT_TYPE"