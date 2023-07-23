//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1

//Cannot run multiples due to possible error while changing GEOs. 
// In some PINs, but not all, you may get a popup box error "Land Detail Error" due to "Land Line # is missing a Valid Land Method"
//Cannot figure out how to figure out how to factor for random error

//Popup Box to type the new GEO -- TBC


let>r=0
repeat>r
let>r=r+1

//Change GEOs

// Click into ProVal anywhere that won't activate something (I used top right blank area)
MouseMove>1360,204
LClick

//Ctrl+K Activates Key Information PopUp Window
Press LCTRL
Send>k
Release LCTRL
Wait>3

//Active Field to tab from changes frequently for some reason, entering a mouse move to create a consistent starting place
//Mouse to Routing Number
MouseMove>857,642
LClick

//Use mouse to click "Reassign Areas"
Press Tab * 4
Press Enter
Wait>1

//Tab to "Neighborhood"
Press Tab * 8
Wait>1

//Send the desired GEO, tab to Accept, Hit Enter
Send 2511
Wait>1
Press Tab *2
Press Enter

//Tab to "Reval Neigh"
Press Tab * 2
Press Del * 4
Wait>1

// Send the desired GEO
Send 2511
Wait>1

//Tab to OK
Press Tab * 2
Press Enter
Wait>3

//Move to next parcel, hit Save
Press F3
Press Enter
Wait>3

//SET TO # OF PINS to Change
Until>r=78