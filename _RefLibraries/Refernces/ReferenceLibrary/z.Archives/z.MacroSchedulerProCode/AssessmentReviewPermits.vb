//
//Creates an Assesment Review Permit in ProVal
//
//Assumes ProVal is maximized on left screen in Darrell's Default layout. If not, check MouseMove below
//
//



//Add New Permit

//Input box will ask you for reference number, usually today's date for manual/review permits.
InputBox>date, Reference_Number

// Set Focus on Add Permit
SetFocus>ProVal
Wait 1
PushButton>ProVal,Add Permit

// Create Permit // The Reference Number is given at prompt will be entered here
Send>%date%
Send>Tab
Press Down *4
Send>Tab
Press Enter
Wait 1

//Begin Field Visit
SetFocus>ProVal
PushButton>ProVal,Add Field Visit
Wait>0.5
//Work Assigned Date is Today
FindWindowWithText>Work Assigned,0,strTitle
GetWindowHandle>ProVal,hWndParent
FindObject>hWndParent,WindowsForms10.SysDateTimePick32.app.0.13965fa_r7_ad1,,5,hWnd,X1,Y1,X2,Y2,result
ObjectSendKeys>hWnd,SPACE
//Visit Type
Press Tab
Send>o
//Work Due Date
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

//Description
FindWindowWithText>Description,0,strTitle
GetWindowHandle>ProVal,hWndParent
FindObject>hWndParent,WindowsForms10.EDIT.app.0.13965fa_r7_ad1,,53,hWnd,X1,Y1,X2,Y2,result
ObjectSendKeys>hWnd,See Assessment Review AS-52
Wait > 1











