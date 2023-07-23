//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1



//Sequence adds permit AND Field visit
//NOTE Must start with mouse selected on Res "Permit Note"
// Mouse on Add Permit
MouseMove>509,776
LClick
Wait 1
Press Tab
// Chooses Seg/Combo from dropdown
Send > S
Press Tab
Press Tab
// Chooses Filing Date from top of Mapping Packet in three steps
Send > 05
Press Right
Send > 17
Press Right
Send > 202
Press Tab
// Chooses date as Ref No from bottom of Mapping Packet
Send > 05/18/2023
Press Enter
// Chooses Permit Description from Excel for Residential
MouseMove>2643,823
LClick
Press LCTRL
Send>c
Release LCTRL
Wait>1
//Moves mouse to ProVal in Permit Description
MouseMove>496,699
LClick
Press LCTRL
Send>v
Release LCTRL
Wait>1
//Begin Field Visit
// Moves mouse to Add Field Visit
MouseMove>1234,727
LClick
//Moves mouse to Work Assigned Date
MouseMove>1323,662
LClick
Press Tab
Send> OO
//Moves mouse to Work Due Date
MouseMove>1770,662
LClick
Press Right
Press NP4
Press Right
Press NP1
Press Tab
Press Tab
Press Tab
Press Tab
Press Space
//End Field Visit//