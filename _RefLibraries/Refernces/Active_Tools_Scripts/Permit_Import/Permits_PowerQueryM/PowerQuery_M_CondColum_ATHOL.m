//ATHOL PERMIT TYPES

//Mechanicals weed these out first
if Text.Contains([Work], "MECHANICAL") then "9"
else if Text.Contains([Work], "SIGN") then "9"
else if Text.Contains([Work], "ROOF") then "9"
else if Text.Contains([Work], "SOLAR PANELS") then "9"
else if Text.Contains([Work], "WINDOW") then "9"
else if Text.Contains([Work], "SIDING") then "9"


// Misc
else if Text.Contains([Work], "MISC") then "5"

// CHANGE OF USE
else if Text.Contains([Work], "CHANGE OF USE") then "3"

// REVIEW
else if Text.Contains([Work], "REVIEW") then "6"

//MOBILE HOMES
else if Text.Contains([Work], "MOBILE HOME SET") then "99"
else if Text.Contains([Work], "MOBILE") then "99"
else if Text.Contains([Work], "MANUFACT") then "99"

//COMMERCIAL
else if Text.Contains([Work], "COMMERCIAL") then "2"
else if Text.Contains([Work], "COM") then "2"
else if Text.Contains([Work], "COURT") then "2"
else if Text.Contains([Work], "BANK") then "2"
else if Text.Contains([Work], "RESTAURANT") then "2"
else if Text.Contains([Work], "RETAIL") then "2"
else if Text.Contains([Work], "STORE") then "2"
else if Text.Contains([Work], "CARPORT") then "2"
else if Text.Contains([Work], "OFFICE") then "2"
else if Text.Contains([Work], "BUSINESS") then "2"
else if Text.Contains([Work], "CHURCH") then "2"
else if Text.Contains([Work], "CAR") then "2"
else if Text.Contains([Work], "WASH") then "2"
else if Text.Contains([Work], "TANK") then "2"




//RESIDENTIAL NEW 1
else if Text.Contains([Work], "MULTI") then "1"
else if Text.Contains([Work], "SINGLE") then "1"
else if Text.Contains([Work], "DUPLEX") then "1"
else if Text.Contains([Work], "HOME") then "1"
else if Text.Contains([Work], "HOUSE") then "1"
else if Text.Contains([Work], "RESIDENCE") then "1"
//else if Text.Contains([Work], "DUPLEX") then "1"



//RESIDENTIAL ADD ALT 3
else if Text.Contains([Work], "ADDITION") then "3"
else if Text.Contains([Work], "ALTERATION") then "3"
else if Text.Contains([Work], "DECK") then "3"
else if Text.Contains([Work], "PORCH") then "3"
else if Text.Contains([Work], "PATIO") then "3"
else if Text.Contains([Work], "FINISH") then "3"
else if Text.Contains([Work], "ATTACHED") then "3"
else if Text.Contains([Work], "DRIVEWAY") then "3"
else if Text.Contains([Work], "STAIR") then "3"
else if Text.Contains([Work], "CONTAINER") then "3"
else if Text.Contains([Work], "FENC") then "3"
else if Text.Contains([Work], "EXPAN") then "3"
else if Text.Contains([Work], "XXXXXX") then "3"
else if Text.Contains([Work], "XXXXXX") then "3"
else if Text.Contains([Work], "XXXXXX") then "3"






//RESIDENTIAL OUTBUILDING 4
else if Text.Contains([Work], "POLE") then "4"
else if Text.Contains([Work], "BARN") then "4"
else if Text.Contains([Work], "SHOP") then "4"
else if Text.Contains([Work], "ACCESSORY") then "4"
else if Text.Contains([Work], "STRUCTURE") then "4"
else if Text.Contains([Work], "OTHER") then "4"
else if Text.Contains([Work], "SHED") then "4"
else if Text.Contains([Work], "QUANSET") then "4"
else if Text.Contains([Work], "STORAGE") then "4"
else if Text.Contains([Work], "GARAGE") then "4"
else if Text.Contains([Work], "STRUCT") then "4"
else if Text.Contains([Work], "BUILDING") then "4"
else if Text.Contains([Work], "XXXXXX") then "4"
else if Text.Contains([Work], "XXXXXX") then "4"







else "0"
