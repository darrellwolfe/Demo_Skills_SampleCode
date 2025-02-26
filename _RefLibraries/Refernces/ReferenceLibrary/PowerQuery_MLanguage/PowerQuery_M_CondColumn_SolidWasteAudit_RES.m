

if [District] = "Commercial" then null 
else if [District] = "Specialized_Cell_Towers" then null 
else if Text.Contains([Owner], "KOOTENAI") then null
else if Text.Start([PIN], 1) = "C" then null 
else if Text.Start([PIN], 1) = "M" and Text.Start([SitusCity], 5) = "COEUR" then null
else if Text.Start([PIN], 1) = "L" then null

else 1
