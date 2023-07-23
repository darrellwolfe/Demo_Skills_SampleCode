//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1
//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1
InputBox>N,How many Parcels in this set?
let>r=0
Repeat>r
  let>r=r+1
//Get the legal acres from Excel
MouseMove>2107,283
LCLick
Press LCTRL
Send>c
Release LCTRL
press down
wait>1

//Move mouse to Add market button
MouseMove>519,872
LClick
wait>.5
// Mouse over and Click the land type tab
MouseMove>515,590
LClick

Wait 2
// Change to match the type of land you want to add
Press Down * 4

//Tab to Pricing Method
Wait 2
Press Enter
Press Tab
Press Down

// Tab to Acres
Press Tab * 3
Press LCTRL
Send>v
Release LCTRL
Wait 2

//Tab to Site rating
Press Tab * 8

// Change to reflect the site rating that you want
Press Down * 5
wait 2
Press F3
Press Enter
Until>r=N
