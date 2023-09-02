//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1
XLSheetToArray>S:\Common\Comptroller Tech\Reporting Tools\Reports (Macros)\PersonalProperty.xls,pp,tArray

 
InputBox>N,How many assets (verticle) in this set?


//loop through returned recordset
Let>r=0
Repeat>r
Let>r=r+1
Let>f=0
Let>Count=0
Repeat>f
Let>Count=Count+1
Let>f=f+1
Let>Return_Array=tArray_%r%_%f%
Send>Return_Array
Let>countTEST={%Count% MOD 2}
If>countTEST=0
Press Tab * 3
ELSE
Press Tab
ENDIF
Until>f=5

//Hit save
MouseMove>971,158
LClick
Wait 1
Press Enter
Wait 1
Press Enter

//New is automatic?

//Category
MouseMove>369,200
LClick
Wait 1

Until>r=N
Wait 1


