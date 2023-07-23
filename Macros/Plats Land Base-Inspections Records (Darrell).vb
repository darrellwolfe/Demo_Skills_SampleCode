let>r=0
repeat>r
let>r=r+1

//Darrells Copy-Computer

// This copies from Excel
//CHANGE FOR YOUR SCREEN-FIRST CELL IN EXCEL
MouseMove>2094,283
LCLick
Press LCTRL
Send>c
Release LCTRL
press down
wait>1

//This adds the Farm Total Acres to Land Base
//CHANGE FOR YOUR SCREEN-ADD LAND BASE LINE
MouseMove>1027,695
LClick
Send>f
Wait>1
Press Tab
//CHANGE FOR YOUR SCREEN-CLICK THE ZERO IN THE "SIZE" BOX NEXT TO LAND
mousemove>1073,604
LCLICK * 3
RClick
send>p
press enter
wait>2

// This opens the Inspection Records Popup Window
press alt
release alt
send>pi
wait>1
press tab
//CHANGE DATE BELOW TO TODAY'S DATE
send>04/07/2023
press tab
//CHANGE INITIALS BELOW TO YOUR FULL INITIALS
send>DGW
press tab * 3
//CHANGE DOWN NUMBER BELOW TO: 12 FOR VACANT; 1 FOR IMPROVED
press down * 12
press tab * 5
press enter
press tab
wait>1
press enter

//This moves to next parcel
press F3
wait>5
press enter
//SET TO # OF PINS IN PLAT
Until>r=125
