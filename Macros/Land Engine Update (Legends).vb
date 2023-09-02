//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1


//Copy (text only) the one column of changes (IMP or Land, not both) into the saved xls worksheet.
//Open the land engine for that geo and type (Ex: Homesite)
//Double click on the first value, hit your Hot Key

InputBox>N,How many legends or values (verticle) in this set?


// Navigate to the correct work book where you have an array
XLSheetToArray>S:\Common\Comptroller Tech\Reporting Tools\Reports (Macros)\Land Engine Paste (Darrell).xls,Land_Legends,tArray

//After using Input box, you need to reset curser with this or it gets off when input box resets curser placement
MouseMove>1958,129
LClick
Press Tab*1
Send> 2023
Press Tab*3
Wait 1

//loop through returned recordset
Let>r=0
Repeat>r
Let>r=r+1
Let>f=0
Repeat>f
Let>f=f+1
Let>Return_Array=tArray_%r%_%f%
Send>Return_Array
Press Tab
Until>f=1
Until>r=N
Wait 20
//Let>IGNORESPAC

