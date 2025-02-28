// Text.Contains([Proposed Description], "SFR") then "SFR"
// [Record_Type] [Type_of_Work] [DESCRIPTION] [REFERENCENUM]
// START CASCADING LOGIC HERE
//MECHANICALS
if Text.Contains([Record_Type], "MECH") then "MECH"
else if Text.Contains([REFERENCENUM], "MECH") then "MECH"
else if Text.Contains([Type_of_Work], "ROOF") then "MECH"
else if Text.Contains([Type_of_Work], "SIDING") then "MECH"
else if Text.Contains([Type_of_Work], "WINDOW") then "MECH"
else if Text.Contains([Type_of_Work], "SOLAR") then "MECH"
else if Text.Contains([Type_of_Work], "SIDING") then "MECH"
else if Text.Contains([Type_of_Work], "SIDING") then "MECH"

//Mobile Homes
else if Text.Contains([Type_of_Work], "MANUFACT") then "MH"
else if Text.Contains([Type_of_Work], "MOBILE") then "MH"
else if Text.Contains([Type_of_Work], "MH") then "MH"

// NEW
else if Text.Contains([DESCRIPTION], "SFR") then "SFR"
else if Text.Contains([DESCRIPTION], "PLAN") then "SFR"
else if Text.Contains([DESCRIPTION], "SINGLE FAMILY") then "SFR"

//Outbuildings
else if Text.Contains([DESCRIPTION], "PATIO") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "DESK") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "GPB") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "BARN") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "POLE") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "SHOP") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "SHED") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "CARPORT") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "DETACHED") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "ACCESSORY") then "OTHER_OUT"
else if Text.Contains([DESCRIPTION], "PERGOLA") then "OTHER_OUT"
//else if Text.Contains([DESCRIPTION], "XXXXXXX") then "OTHER_OUT"
//else if Text.Contains([DESCRIPTION], "XXXXXXX") then "OTHER_OUT"

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
  and Text.Contains([Type_of_Work], "FOUNDATION") then "SFR"

else if Text.Contains([Record_Type], "COMMERCIAL")
  and Text.Contains([Type_of_Work], "NEW") then "2"

else if Text.Contains([Record_Type], "RESIDENTIAL")
  and Text.Contains([Type_of_Work], "NEW") then "SFR"


//Misc Other
else if Text.Contains([Type_of_Work], "RETAIN") then "6"
else if Text.Contains([Record_Type], "DEMO") then "6"
else if Text.Contains([Record_Type], "HISTORIC") then "6"

//IF NONE OF THAT CAUGHT, CALL IT NEW AND LET THE APRAISER FIGURE IT OUT
else if Text.Contains([Record_Type], "COMMERCIAL") then "2"
else if Text.Contains([Record_Type], "RESIDENTIAL") then "SFR"

else "Check"