//InputBox>N,What note
//Putting land notes in with mapping packets


//Dates
Month>the_month
DAY>the_day
Year>the_year

InputBox>AIN, What is the AIN?
InputBox>NOTICE, Corrected Notice? y or n
InputBox>USER, Initials of appraiser. Ex: DGW


//Click into Proval (set Mouse somewhere inacuous on ProVal
SetFocus>ProVal

//Open Appeals
SetFocus>ProVal
Press LCTRL
Send>o
Release LCTRL
Wait>1

Press Tab
Press Backspace
Wait>1
Send>AIN
Press Enter
Wait>1


//Open Memos > Land
Press ALT
Release ALT
Send>am
Wait>1
Send>a
Press Enter
Wait>1

IF>NOTICE=n
//Paste LandMemo Note from earlier
  //Send>DGW-06/23 Corrected Notice /or/ No Change
  Send>DGW-%the_month%/%the_year% No Change
  Press Enter
  Wait>1
  Press Tab
  Press Enter
Wait>1

  ELSE

  Send>DGW-%the_month%/%the_year% NEEDS CORRECTED NOTICE
  Press Enter
  Wait>1
  Press Tab
  Press Enter
Wait>1

ENDIF


//Close Out Appeal
//Open Appeals Window
SetFocus>ProVal
Press ALT
Release ALT
Send>aau
Wait>2

Press Tab*5
Wait>2

IF>NOTICE=n
//No Change
Press Down*6
ELSE
//Send Corrected Notice
Press Down*7
ENDIF
Wait>2

Press Tab*5
Wait>2
Send>USER

IF>NOTICE=n
//No Change
//Find and Left Click To the Left of the
FindImagePos>%BMP_DIR%\image_1.bmp,WINDOW:Appeals,0.7,7,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>{%XArr_0%-10},YArr_0
  LClick
Endif

ELSE

//Send Corrected Notice
//Find and Left Click To the Left of the
FindImagePos>%BMP_DIR%\image_2.bmp,WINDOW:Appeals,0.7,7,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>{%XArr_0%-10},YArr_0
  LClick
Endif

ENDIF
Wait>2

Press Tab*24
Press Enter

Wait>1
Press LCTRL
Send>s
Release LCTRL
Wait>1

//DGW-06/05/2024 Corrected Notice