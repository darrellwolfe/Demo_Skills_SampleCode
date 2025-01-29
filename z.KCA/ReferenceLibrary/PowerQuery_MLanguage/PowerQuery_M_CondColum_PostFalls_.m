// Text.Contains([Proposed Description], "SFR") then "1"
// [Record_Type] [Type_of_Work] [DESCRIPTION] [REFERENCENUM]
// START CASCADING LOGIC HERE
//MECHANICALS
if Text.Contains([Record_Type], "MECH") then "9"
else if Text.Contains([REFERENCENUM], "MECH") then "9"
else if Text.Contains([Type_of_Work], "ROOF") then "9"
else if Text.Contains([Type_of_Work], "SIDING") then "9"
else if Text.Contains([Type_of_Work], "WINDOW") then "9"
else if Text.Contains([Type_of_Work], "SOLAR") then "9"
else if Text.Contains([Type_of_Work], "SIDING") then "9"
else if Text.Contains([Type_of_Work], "SIDING") then "9"

//Mobile Homes
else if Text.Contains([Type_of_Work], "MANUFACT") then "99"
else if Text.Contains([Type_of_Work], "MOBILE") then "99"
else if Text.Contains([Type_of_Work], "MH") then "99"

// NEW
else if Text.Contains([DESCRIPTION], "SFR") then "1"
else if Text.Contains([DESCRIPTION], "PLAN") then "1"
else if Text.Contains([DESCRIPTION], "SINGLE FAMILY") then "1"

//Outbuildings
else if Text.Contains([DESCRIPTION], "PATIO") then "4"
else if Text.Contains([DESCRIPTION], "DESK") then "4"
else if Text.Contains([DESCRIPTION], "GPB") then "4"
else if Text.Contains([DESCRIPTION], "BARN") then "4"
else if Text.Contains([DESCRIPTION], "POLE") then "4"
else if Text.Contains([DESCRIPTION], "SHOP") then "4"
else if Text.Contains([DESCRIPTION], "SHED") then "4"
else if Text.Contains([DESCRIPTION], "CARPORT") then "4"
else if Text.Contains([DESCRIPTION], "DETACHED") then "4"
else if Text.Contains([DESCRIPTION], "ACCESSORY") then "4"
else if Text.Contains([DESCRIPTION], "PERGOLA") then "4"
//else if Text.Contains([DESCRIPTION], "XXXXXXX") then "4"
//else if Text.Contains([DESCRIPTION], "XXXXXXX") then "4"

// ADD ALT
else if Text.Contains([Type_of_Work], "ADD") then "3"
else if Text.Contains([Type_of_Work], "ALT") then "3"
else if Text.Contains([Type_of_Work], "TENANT") then "3"
else if Text.Contains([Type_of_Work], "FINISH") then "3"
else if Text.Contains([Type_of_Work], "DECK") then "3"
else if Text.Contains([Type_of_Work], "SWIM") then "3"
else if Text.Contains([Type_of_Work], "REMODEL") then "3"

// NEW
else if Text.Contains([Record_Type], "COMMERCIAL")
  and Text.Contains([Type_of_Work], "FOUNDATION") then "2"

else if Text.Contains([Record_Type], "RESIDENTIAL")
  and Text.Contains([Type_of_Work], "FOUNDATION") then "1"

else if Text.Contains([Record_Type], "COMMERCIAL")
  and Text.Contains([Type_of_Work], "NEW") then "2"

else if Text.Contains([Record_Type], "RESIDENTIAL")
  and Text.Contains([Type_of_Work], "NEW") then "1"


//Misc Other
else if Text.Contains([Type_of_Work], "RETAIN") then "6"
else if Text.Contains([Record_Type], "DEMO") then "6"
else if Text.Contains([Record_Type], "HISTORIC") then "6"

//IF NONE OF THAT CAUGHT, CALL IT NEW AND LET THE APRAISER FIGURE IT OUT
else if Text.Contains([Record_Type], "COMMERCIAL") then "2"
else if Text.Contains([Record_Type], "RESIDENTIAL") then "1"

else "Check"