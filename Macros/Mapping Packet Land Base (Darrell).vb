InputBox>N,How many Parcels in this set?
let>r=0
Repeat>r
  let>r=r+1

//CHANGE FOR YOUR SCREEN-FIRST CELL IN EXCEL
MouseMove>2082,198
LCLick
Press LCTRL
Send>c
Release LCTRL
press down
wait>1
//CHANGE FOR YOUR SCREEN-CLICK THE ZERO IN THE "SIZE" BOX
mousemove>1085,604
LCLICK * 1
wait>1
LCLICK * 1
wait>1
Press LCTRL
Send>v
Release LCTRL
Press enter
wait>1
press F3
wait>1
press enter
//SET TO # OF PINS IN PLAT
Until>r=N







