InputBox>N,How many Parcels in this set?
let>r=0
Repeat>r
  let>r=r+1

//CHANGE FOR YOUR SCREEN-FIRST CELL IN EXCEL
MouseMove>2046,283
LCLick
Press LCTRL
Send>c
Release LCTRL
press down
wait>1
//CHANGE FOR YOUR SCREEN-CLICK THE "account number" box on Returns Processing
mousemove>1432,47
LCLICK
wait>1
Press LCTRL
Send>v
Release LCTRL
Press enter*2
wait>1
//SET TO # OF PINS IN PLAT
Until>r=N







