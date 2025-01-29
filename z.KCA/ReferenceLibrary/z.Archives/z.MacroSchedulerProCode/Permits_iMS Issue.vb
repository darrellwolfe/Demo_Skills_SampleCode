//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1
//Send>%date% <- Sends today's date
// Disregard Save for later - XLSheetToArray>S:\Common\Comptroller Tech\Reporting Tools\Reports (Permits - Import)\Permits_CompTechImports\_ImportsCompleted (CSVs)\iMS_0_PINs_Manual_Import_MacroCopy.xls,Import Ready,sheetArray



//Permits iMS Imports
XLSheetToArray>C:\Users\dwolfe\Documents\MarcoArrays\iMS_0_PINs_Manual_Import_MacroCopy.xls,Import Ready,tArray

// A note on arrays. The way that MS pulls in the array it will include headers on a table so you need to start the loop on the 2nd row or delete the headers.
Inputbox>N,How many permits are you importing

// Loop throught the returned array
Let>r=0
Repeat>r
Let>r=r+1

// Grab Array
Let>PIN_Array=tArray_%r%_1
Let>PermitRef_Array=tArray_%r%_2
Let>PermitIssueDate_Array=tArray_%r%_5
Let>PermitDescription_Array=tArray_%r%_9
Let>Sales_Array=tArray_%r%_2
Let>Sales_Array=tArray_%r%_2

//Focus on ProVal, Open Parcel Search Screen
SetFocus>ProVal
Press LCTRL
Wait>0.079
Send>o
Wait>0.109
Release LCTRL
Wait>1

// Send PIN, open Parcel
SetFocus>Parcel Selection
Press Tab
Send>PIN_Array
Press TAB * 6
Press Enter
Wait>1
// Check

//Add New Permit from array

//Input box will ask you for reference number, usually today's date for manual/review permits.
InputBox>d, Permit_Type

// Set Focus on Add Permit
SetFocus>ProVal
Wait 1
PushButton>ProVal,Add Permit

// Create Permit

//Send Reference Number
Send>PermitRef_Array
Send>Tab

// Send Permit Type, but the types in the sheet are NOT the number of times to press down...
// 1	New Dwelling Permit          > Down * 1
// 2	New Commercial Permit        > Down * 8
// 3	Addition/Alt/Remodel Permit  > Down * 9
// 4	Outbuilding/Garage Permit    > Down * 10
// 5	Miscellaneous Permit         > Down * 11
// 6	Mandatory Review             > Down * 12
// 9	Roof/Siding/Wind/Mech Permit > Down * 13
// 10	Agricultural Review          > Down * 2
// 11	Timber Review                > Down * 3
// 12	Assessment Review            > Down * 4
// 13	Seg/Combo                    > Down * 5
// 14	Dock/Boat Slip Permit        > Down * 6
// 15	PP Review                    > Down * 7
// 99	Mobile Setting Permit        > Down * 14
Press Down *d
Send>Tab *3


//////////////////////////////////////////////////////////////LEFT OFF HERE

// This isn't going to work unless I split the date up...
// PermitIssueDate_Array

//Filing Date
Send>12
Press Right
Send>01
Press Right
Send>2023

Press Enter
Wait 1




//Work Due Date <- Change to 2024 in October
Press Tab
Send>SPACE
Press Right
Send>12
Press Right
Send>01
Press Right
Send>2023





//Begin Field Visit
SetFocus>ProVal
PushButton>ProVal,Add Field Visit
Wait>0.5

//Work Assigned Date is Today
FindWindowWithText>Work Assigned,0,strTitle
GetWindowHandle>ProVal,hWndParent
FindObject>hWndParent,WindowsForms10.SysDateTimePick32.app.0.13965fa_r7_ad1,,5,hWnd,X1,Y1,X2,Y2,result
ObjectSendKeys>hWnd,SPACE


//Visit Type: Permit
Press Tab
Send>p

//Work Due Date <- Change to 2024 in October
Press Tab
Send>SPACE
Press Right
Send>12
Press Right
Send>01
Press Right
Send>2023


//Need To Visit
Press Tab*3
Send>SPACE
Wait 1

//Move mouse to field under "Description" if the above isn't working. Then comment out above and remove comment out from the below.
MouseMove>496,700
LDblClick
Wait 1
//Send>ASSESSMENT REVIEW
Send>PermitDescription_Array



//Check
Wait 1000000



Until>r=N
