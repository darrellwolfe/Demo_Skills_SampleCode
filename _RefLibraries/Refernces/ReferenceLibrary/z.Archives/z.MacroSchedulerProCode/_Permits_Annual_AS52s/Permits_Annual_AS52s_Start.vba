//
//
//Assumes ProVal is maximized on left screen in Darrell's Default layout. If not, check MouseMove below
//
//


XLSheetToArray>S:\Common\Comptroller Tech\Reporting Tools\Reports (Macros)\Arrays\AIN_Column1Array.xls,Sheet1,tArray

//Dates
Month>the_month
DAY>the_day
Year>the_year
InputBox>AIN, What is the AIN?
//InputBox>N,How many AINs (verticle) in this set?

/*
let>r=0
repeat>r
let>r=r+1
  WAIT>1
  SetFocus>ProVal
  Wait 1.5

// Grab Array
Let>AIN=tArray_%r%_1
*/

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


//Add New Permit

//Input box will ask you for reference number, usually today's date for manual/review permits.
//InputBox>x, Reference_Number

// Set Focus on Add Permit
SetFocus>ProVal
Wait>1
//Find and Left Click Center of 
FindImagePos>%BMP_DIR%\image_3.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>XArr_0,YArr_0
  LClick
  
  ELSE
  
    //Find and Left Click Center of 
  FindImagePos>%BMP_DIR%\image_4.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
  If>NumFound>0
    MouseMove>XArr_0,YArr_0
    LClick
  Endif
 
Endif
Wait>2


//Start a new permit
PushButton>ProVal,Add Permit

// Create Permit // The Reference Number is given at prompt will be entered here
Send>AS52_%the_month%-%the_day%-%the_year%
Send>Tab
Press Down *3
Send>Tab
Press Enter
Wait>1

//Begin Field Visit
SetFocus>ProVal
PushButton>ProVal,Add Field Visit
Wait>1

//Work Assigned Date is Today IMAGE CAPTURE
//Find and Left Click To the Right of the WORK ASSIGNED DATE: Checkmark Box
//Find and Left Click To the Right of the 
FindImagePos>%BMP_DIR%\image_1.bmp,WINDOW:ProVal,0.7,8,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>{%XArr_0%+10},YArr_0
  LClick
Endif
Wait>1

//Visit Type
Press Tab
Send>o
Wait>1

//Work Due Date
Press Tab
Press Space
Press Right
Send>06/24/2024
Wait>1



//Permit Description IMAGE CAPTURE
//Find and Left Click Below the Description
//Find and Left Click Below the 
FindImagePos>%BMP_DIR%\image_2.bmp,WINDOW:ProVal,0.7,6,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>XArr_0,{%YArr_0%+10}
  LClick
Endif
Wait>1
Send>ASSESSMENT REVIEW See AS52 for details
Wait>1



//Open Memos > AR Add Memo Notes
Press ALT
Release ALT
Send>am
Wait>1
Press Enter
Send>ar
Wait>1
Press Tab
Press Enter
Wait>1

//Results of sending ar
//Find and Left Click Center of 
FindImagePos>%BMP_DIR%\image_6.bmp,WINDOW:Duplicate ID,0.7,1,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>XArr_0,YArr_0
  Press Enter
  Send>a
  Press Enter
  Wait>1
  Press Tab
  Press Enter
  Wait>1
  ELSE
  //Send>AS52_%the_month%-%the_day%-%the_year%
  Press Tab
  Press Enter
  Wait>1
Endif


//Add to appeals
//Open Appeals Window
SetFocus>ProVal
Press ALT
Release ALT
Send>aau
Wait>2

//Find and Left Click Bottom Right of 
FindImagePos>%BMP_DIR%\image_7.bmp,WINDOW:Future Property Record Exists,0.7,4,XArr,YArr,NumFound,CCOEFF
If>NumFound>0
  MouseMove>XArr_0,YArr_0
  LClick
  Wait>2
 //  SetFocus>Future Property Record Exists
 // Press Tab
  Press Enter

  //Click "Update Options" to add NEW Appeal AS52 plus AIN for Appeal ID
  SetFocus>ProVal,Appeals
  Press ALT
  Release ALT
  Send>u
  Wait>3
  Send>n

  //Press Down*2
  //Press Enter
  Wait>2
  Send>AS52_%AIN%
  Press Tab
  Wait>2
  Send>the_year
  Wait>2
  Press Tab
  Press Enter
  Press Down*3
  Wait>2

  //To set Status Code
  Press Tab
  Press Down
  Wait>2

  //Set Determination Type
  //Find and Left Click To the Right of the 
  FindImagePos>%BMP_DIR%\image_5.bmp,WINDOW:Appeals,0.7,8,XArr,YArr,NumFound,CCOEFF
  If>NumFound>0
    MouseMove>{%XArr_0%+10},YArr_0
    LClick
    Send>a
    Press Enter
    Wait>1
  Endif

  ELSE

  //Click "Update Options" to add NEW Appeal AS52 plus AIN for Appeal ID
  Press ALT
  Release ALT
  Send>u
  Wait>1
  Send>n
  //Press Down*2
  //Press Enter
  Wait>1
  Send>AS52_%AIN%
  Press Tab
  Wait>1
  Send>the_year
  Wait>1
  Press Tab
  Press Enter
  Press Down*3
  Wait>1

  //To set Status Code
  Press Tab
  Press Down


  //Set Determination Type
  //Find and Left Click To the Right of the 
  FindImagePos>%BMP_DIR%\image_8.bmp,WINDOW:Appeals,0.7,8,XArr,YArr,NumFound,CCOEFF
  If>NumFound>0
    MouseMove>{%XArr_0%+10},YArr_0
    LClick
    Send>a
    Press Enter
  Endif
  

Endif


//
Press Tab*15
Pres Enter
Wait>1

Press LCTRL
Send>s
Release LCTRL
Wait>1

//Until>r=N
