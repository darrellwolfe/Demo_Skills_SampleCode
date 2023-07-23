InputBox>N,How many Parcels in this set?

let>r=0
repeat>r
let>r=r+1


//Putting 602(3) Memos


//Click into Proval (set Mouse somewhere inacuous on ProVal
MouseMove>1318,207
LClick

//Open Memos > Land
Press ALT
Release ALT
send>am
Wait 1
Press Enter
send>6
Press Enter
Wait 1

//Paste LandMemo Note from earlier
Send>HB475

//Close Memo window
Press Tab
Press Enter

//Next Parcel
Press F3
Wait>3

//Save Popup Window
Press Enter
Wait>5

//SET TO # OF PINS IN Packet
Until>r=N
