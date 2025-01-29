//This ads a field visit to a single permit. 
//Must be on the Permit Screen and have the correct permit selected.


//ANY PERMITS OTHER THAN MECHANICAL
SetFocus>ProVal
UIClick>ProVal,Add Field Visit
Wait 1

//Find and Double Left Click To the Right of the //You'll need to recapture this image?//
FindImagePos>%BMP_DIR%\image_9.bmp,WINDOW:ProVal,0.7,8,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>{%XArr_0%+5},YArr_0
  LClick
  //Wait 2
  //LClick
Endif

Wait 1

//Visit Type
Press Tab
Send>p

//Work Due Date
Press Tab
Press Space
Press Right
send>12
press right
send>31

//Need to Visit
Press Tab * 3
Press Space

//Next Parcel + Save
//Press F3
//Press Enter
SetFocus>ProVal
