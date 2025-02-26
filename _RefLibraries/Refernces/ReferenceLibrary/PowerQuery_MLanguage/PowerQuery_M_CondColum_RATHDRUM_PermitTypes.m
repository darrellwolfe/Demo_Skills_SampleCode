//RATH_PERMIT_TYPES
//MATCH ON 
// [Permit Type]
// [Work Description]

// Exclude entirely
//SEDIMENT EROSION
//RIGHT OF WAY
//WATER METER

//Mechanicals weed these out first
if Text.Contains([Permit Type], "MECHANICAL") then "9"
else if Text.Contains([Permit Type], "SIGN") then "9"
else if Text.Contains([Permit Type], "ROOF") then "9"
else if Text.Contains([Permit Type], "SOLAR PANELS") then "9"

//MOBILE HOMES
else if Text.Contains([Permit Type], "MOBILE HOME SET") then "99"
else if Text.Contains([Permit Type], "MOBILE") then "99"
else if Text.Contains([Permit Type], "MANUFACT") then "99"

//COMMERCIAL
else if Text.Contains([Permit Type], "COMMERCIAL") then "2"
else if Text.Contains([Permit Type], "COM -") then "3"

//RESIDENTIAL NEW 1
else if Text.Contains([Permit Type], "MULTI") then "1"
else if Text.Contains([Permit Type], "SINGLE") then "1"
else if Text.Contains([Permit Type], "DUPLEX") then "1"
//RESIDENTIAL ADD ALT 3
else if Text.Contains([Permit Type], "ADDITION") then "3"
else if Text.Contains([Permit Type], "ALTERATION") then "3"
else if Text.Contains([Permit Type], "DECK") then "3"
else if Text.Contains([Permit Type], "PORCH") then "3"
else if Text.Contains([Permit Type], "PATIO") then "3"
//RESIDENTIAL OUTBUILDING 4
else if Text.Contains([Permit Type], "POLE") then "4"
else if Text.Contains([Permit Type], "BARN") then "4"
else if Text.Contains([Permit Type], "SHOP") then "4"
else if Text.Contains([Permit Type], "ACCESSORY") then "4"
else if Text.Contains([Permit Type], "STRUCTURE") then "4"
else if Text.Contains([Permit Type], "OTHER") then "4"
else if Text.Contains([Permit Type], "SHED") then "4"

else "0"
