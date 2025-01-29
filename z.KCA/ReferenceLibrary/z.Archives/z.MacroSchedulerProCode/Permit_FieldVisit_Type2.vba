//This ads a field visit to a single permit. 
//Must be on the Permit Screen and have the correct permit selected.


//ANY PERMITS OTHER THAN MECHANICAL
SetFocus>ProVal
UIClick>ProVal,Add Field Visit
Wait 1

//Find and Left Click To the Right of the //You'll need to recapture this image?//
FindImagePos>%BMP_DIR%\image_1.bmp,WINDOW:ProVal,0.7,8,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>{%XArr_0%+5},YArr_0
  LClick
 // Wait 1
 // LClick
Endif
  Wait 3

//Visit Type
Press Tab
Send>p

//Need to visit, NO (check on and off to remove null and replace with no)
Press Tab * 4
Press Space
Wait 1
Press Space

SetFocus>ProVal
