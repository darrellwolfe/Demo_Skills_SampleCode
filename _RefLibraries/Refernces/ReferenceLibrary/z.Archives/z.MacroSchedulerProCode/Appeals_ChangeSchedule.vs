//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1

//Appeal Change Schedule

Inputbox>N,How many AINs?
Inputbox>D,What Date?
Inputbox>T,What Time?

// Loop
Let>r=0
Repeat>r
Let>r=r+1

//Open Appeals
SetFocus>ProVal
Press Alt
Release Alt
Send aau
Wait 3
//Send a
//Send u

//Change
SetFocus>ProVal
SetFocus>Macro - Appeals_ChangeSchedule

//Change Date
GetWindowHandle>Appeals,hWnd
FindObject>hWnd,Edit,,19,hWnd,X1,Y1,X2,Y2,result
Let>X={%X1% + (%X2%-%X1%) div 2}
Let>Y={%Y1% + (%Y2%-%Y1%) div 2}
MouseMove>X,Y
LDblClick
Send>D
Wait 1

//Change Time
GetWindowHandle>Appeals,hWnd
FindObject>hWnd,Edit,,21,hWnd,X1,Y1,X2,Y2,result
Let>X={%X1% + (%X2%-%X1%) div 2}
Let>Y={%Y1% + (%Y2%-%Y1%) div 2}
MouseMove>X,Y
LDblClick
Send>T
Wait 1


//Press OK
Press Tab *9
Press Enter
Wait 1

//Next Parcel
Press F3
Press Enter
Wait 3






Until>r=N

//ObjectSendText>Scheduled Hearing Date,07/06/23





//Send>