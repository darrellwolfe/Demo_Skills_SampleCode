//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1


//First, copy the desired factor from Excel, then run this

let>r=0
repeat>r
let>r=r+1
//Place mouse on Factor Table Pop UP
MouseMove>1392,174
LClick

//Tab to "Default Local Modifier"
Press Tab *6
Wait 1

//Paste twice
Press LCTRL
Send>v
Press Tab
Send>v
Release LCTRL
Press Tab *4
Press Enter
Press Tab*2
Press Enter
MouseMove>791,321
LClick
Press Down
Wait 1
Press LCTRL
Send>c
Release LCTRL
Wait 1
Until>r=1

//End