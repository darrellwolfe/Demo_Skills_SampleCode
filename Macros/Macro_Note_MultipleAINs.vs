//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1
// This Macro will import the sales from the ProVal Sale import Tool
XLSheetToArray>C:\Users\dsavage\Documents\Excel docs\ProVal Sale import Tool.xlsx.xls,Import Tool,tArray
// A note on arrays. The way that MS pulls in the array it will include headers on a table so you need to start the loop on the 2nd row.

Inputbox>N,How many AINs?
Inputbox>T,Note Type (la for land, im for improvement, ry23 for Reval Year 23, AS for Assessment Review)
Inputbox>W,What is the note (free type any note)?
  
// Loop throught the returned array
Let>r=0
Repeat>r
Let>r=r+1

//AINs pull from Array starting in A1
Let>AIN_Array=tArray_%r%_1

//In Proval, OPEN
SetFocus>ProVal
Press LCTRL
Wait>0.079
Send>o
Wait>0.109
Release LCTRL
Wait>1

//Send AINs
SetFocus>Parcel Selection
Press Tab
Send>AIN_Array
Press TAB * 5
Press Enter
Wait>3

//Open Select Memo popup window
SetFocus>ProVal
CapsOff
Press ALT
Send>am
Release ALT
Wait>5
Send>T
Press Tab
Press Enter

//Send Note
Send>W
Press Enter
Press Tab
Press Enter

//Next Parcel
Press F3
Press Enter
  
Until>r=N