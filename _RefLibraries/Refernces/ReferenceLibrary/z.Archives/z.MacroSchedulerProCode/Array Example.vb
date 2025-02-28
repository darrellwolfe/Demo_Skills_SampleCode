//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
// Navigate to the correct work book where you have an array



XLSheetToArray>C:\Users\dsavage\Documents\Excel docs\Multi Family import Tool.xlsx.xls,Array,tArray

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
Until>f=7
Until>r=5

Wait 20
//Let>IGNORESPAC

