//------------------------------------------
//-- Conditional Columns CDA Permits, Permit Types
//-- See GitHub Repo
//------------------------------------------



if Text.Contains([Description], "VERIFICATION OF OCCUPANCY") then 6

else if Text.Contains([Description], "COM NEW CONSTRUCTION") then 2

else if Text.Contains([Description], "COM MECHANICAL") then 9
else if Text.Contains([Description], "COM ROOFING") then 9
else if Text.Contains([Description], "RES MECHANICAL") then 9
else if Text.Contains([Description], "RES ROOFING") then 9
else if Text.Contains([Description], "RES SIDING") then 9
else if Text.Contains([Description], "RES SOLAR") then 9
else if Text.Contains([Description], "ROOFING") then 9
else if Text.Contains([Description], "SIDING") then 9
else if Text.Contains([Description], "SOLAR") then 9
else if Text.Contains([Description], "WINDOWS") then 9
else if Text.Contains([Description], "WINDOW") then 9
else if Text.Contains([Description], "DOORS") then 9
else if Text.Contains([Description], "DOOR") then 9
else if Text.Contains([Description], "SEWER") then 9
else if Text.Contains([Description], "REPLACE") then 9




else if Text.Contains([Description], "RES SINGLE FAMILY") then 1
else if Text.Contains([Description], "TOWNHOME") then 1
else if Text.Contains([Type], "RES DUPLEX") then 1

else if Text.Contains([Description], "COM NEW CONSTRUCTION") then 2
else if Text.Contains([Type], "COM NEW CONSTRUCTION") then 2

else if Text.Contains([Type], "COM ACCESSORY") then 3
else if Text.Contains([Type], "COM ALTERATION") then 3

else if Text.Contains([Type], "RES WINDOWS & DOORS") then 3
else if Text.Contains([Type], "COM ALTERATION") then 3
else if Text.Contains([Type], "COM ALTERATION") then 3

else if Text.Contains([Description], "DEMO") then 3
else if Text.Contains([Description], "RES ACCESSORY") then 3
else if Text.Contains([Description], "RES ALTERATION") then 3
else if Text.Contains([Description], "RES ADDITION") then 3
else if Text.Contains([Description], "SHED") then 3
else if Text.Contains([Description], "PATIO") then 3
else if Text.Contains([Description], "ADDITION") then 3
else if Text.Contains([Description], "DECK") then 3

else if Text.Contains([Description], "SITE") then 1

else 0


