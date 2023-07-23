//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1


//Put AIN in the search for, run Macro

//Search, Select, Move to Personal Property Screen
Press Tab
Press Enter
Wait>1
Press Tab
Press Enter
Wait>1


//Copy note from Excel - Ensure the chosen cell is already selected
MouseMove>2043,662
LClick
Press Esc
Wait>1
MouseMove>2043,662
LClick
Press LCTRL
Send>c
Release LCTRL
Wait>2


//SET MOUSE IN MPPV > PERSONAL PROPERTY > "Change" button (next to Class text box)
MouseMove>442,213
LClick
Wait>1

//CHANGE CLASS CODE TO 70
Send>070
Press Tab
Press Enter
Wait>1


//Save
MouseMove>949,498
LClick
Wait>3

//Press OK
Press Enter
Wait>2

//Open Actions
MouseMove>688,136
LClick
Wait>2

//Paste Note
Press LCTRL
Send>v
Release LCTRL
Wait>1
Press Tab *6
Wait>1
Press Enter
Wait>2

//SET MOUSE IN MPPV > Property Search to start again
MouseMove>66,137
LClick
Wait 1

//END
