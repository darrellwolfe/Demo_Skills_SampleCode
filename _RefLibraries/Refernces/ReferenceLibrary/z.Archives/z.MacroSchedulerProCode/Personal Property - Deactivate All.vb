//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1

InputBox>N,How many Parcels in this set?

let>r=0
repeat>r
let>r=r+1


//Deactivate

MouseMove>895,158
LClick

//Next
Press Tab*2
Press Down

Until>r=N
