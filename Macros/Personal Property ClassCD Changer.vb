//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1

//Saved
//Set mouse to Assets
//MouseMove>442,137





InputBox>N,How many Parcels in this set?
InputBox>x,What ClassCD are we changing them to?

let>r=0
Repeat>r
  let>r=r+1

//Put AIN in the search for, run Macro

//Copy AIN from Excel - Ensure the chosen cell is already selected
MouseMove>2031,283
LClick
Press LCTRL
Send>c
Release LCTRL
Press Down
Wait 1

//SET MOUSE IN MPPV > Property Search to start again
MouseMove>66,137
LClick
Wait 1


//Click "Search For"
MouseMove>126,211
LClick *2
Wait 1

Paste Note
Press LCTRL
Send>v
Release LCTRL
Wait>2

//Search, Select, Move to Personal Property Screen
Press Tab
Press Enter
Wait 1
Press Tab
Press Enter
Wait 1

//SET MOUSE IN MPPV > PERSONAL PROPERTY > "Change" button (next to Class text box)
MouseMove>442,213
LClick
Wait 1

//CHANGE CLASS CODE TO 70, OR 022 OR WHATEVER YOU NEED
Send>x
Press Tab
Press Enter
Wait 1

//Save
MouseMove>949,498
LClick
Wait 1

//Press OK
Press Enter
Wait 1







Until>r=N

