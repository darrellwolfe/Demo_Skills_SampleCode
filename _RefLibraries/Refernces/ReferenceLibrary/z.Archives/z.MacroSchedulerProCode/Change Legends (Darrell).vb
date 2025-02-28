//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1

//
Inputbox>n, How many parcels in this set?
Inputbox>d,How many times to hit the down key?

//Loop to be continued
let>r=0
repeat>r
let>r=r+1

//Legend Change

//Set mouse on "Site Rating", Legend dropdown.
MouseMove>534,706
LClick

//Press down to change to Legend#
Press Down * d
Press Enter
Press Tab
Press LCTRL
Send>s
Release LCTRL

//Next Parcel
Press F3
Wait>2.0

//End Loop to be continued
//SET TO # OF PINS IN PLAT
Until>r=n


