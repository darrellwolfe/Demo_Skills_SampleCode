InputBox>N,How many Parcels in this set?

let>r=0
repeat>r
let>r=r+1


//Putting land notes in with mapping packets

// Chooses LandMemo Note from Excel (hold for use below)
MouseMove>2731,815
LClick
Press LCTRL
Send>c
Release LCTRL
Wait>1

//Click into Proval (set Mouse somewhere inacuous on ProVal
MouseMove>1318,207
LClick

//Open Memos > Land
Press ALT
Release ALT
send>aml
Press Enter
Wait 1

//Paste LandMemo Note from earlier
Press LCTRL
Send>v
Release LCTRL
Wait>2

//Close Memo window
Press Tab
Press Enter

//Next Parcel
Press F3

//Save Popup Window
Press Enter
Wait>3

//SET TO # OF PINS IN Packet
Until>r=N
