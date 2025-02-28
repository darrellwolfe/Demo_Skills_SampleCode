//ATHOL PERMIT TYPES

//Mechanicals weed these out first
if Text.Contains([DESCRIPTION], "MECH") then "Mech"
else if Text.Contains([#"REFERENCE#"], "MEC") then "Mech"

else if Text.Contains([DESCRIPTION], "SIGN") then "Mech"
else if Text.Contains([DESCRIPTION], "ROOF") then "Mech"
else if Text.Contains([DESCRIPTION], "SOLAR") then "Mech"
else if Text.Contains([DESCRIPTION], "WINDOW") then "Mech"
else if Text.Contains([DESCRIPTION], "SIDING") then "Mech"
else if Text.Contains([DESCRIPTION], "HEAT") then "Mech"


else if Text.Contains([DESCRIPTION], " AC ") then "Mech"
else if Text.Contains([DESCRIPTION], " AC") then "Mech"
else if Text.Contains([DESCRIPTION], "AC ") then "Mech"
else if Text.Contains([DESCRIPTION], "A/C") then "Mech"
else if [DESCRIPTION] = "AC" then "Mech"


else if Text.Contains([DESCRIPTION], "HVAC") then "Mech"

else if Text.Contains([DESCRIPTION], "GAS") then "Mech"
else if Text.Contains([DESCRIPTION], "REPLACE") then "Mech"
else if Text.Contains([DESCRIPTION], "GENERATOR") then "Mech"
else if Text.Contains([DESCRIPTION], "INSTALL") then "Mech"
else if Text.Contains([DESCRIPTION], "SPLIT") then "Mech"
else if Text.Contains([DESCRIPTION], "STOVE") then "Mech"
else if Text.Contains([DESCRIPTION], "CHIMNEY") then "Mech"
else if Text.Contains([DESCRIPTION], " FP") then "Mech"
else if Text.Contains([DESCRIPTION], "DOOR") then "Mech"
else if Text.Contains([DESCRIPTION], "HOODS") then "Mech"
else if Text.Contains([DESCRIPTION], "TEAR OFF") then "Mech"
else if Text.Contains([DESCRIPTION], "RE-SIDE") then "Mech"
else if Text.Contains([DESCRIPTION], "RETAINING") then "Mech"
else if Text.Contains([DESCRIPTION], "RESIDE") then "Mech"
else if Text.Contains([DESCRIPTION], "FIREPLACE") then "Mech"
else if Text.Contains([DESCRIPTION], "VENT") then "Mech"
else if Text.Contains([DESCRIPTION], "FENCE") then "Mech"
else if Text.Contains([DESCRIPTION], "FURNACE") then "Mech"
else if Text.Contains([DESCRIPTION], "FENCE") then "Mech"



else "Review"
