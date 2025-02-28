//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1
//Simple dialog block
//Creates the Drop down box for the start of the macro
Month>this_month
  Year>this_year
  Input>AINLIST,List all AINs in Mapping Packet. Sperate AINs by using a comma
  Input>MemoTXT, Insert Memo text for mapping packet
  Input>PDESC, Insert Permit Description
  Input>PNUMBER,Permit Number (Bottom Date)
  Input>PFILE,Filing Date (Top Date)
  Input>TREVIEW,Timber or AG review? Y/N
  //Database connection string and query code pulls in legal acres
  DBConnect>Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=GRM_Main;Data Source=astxdbprod,dbH
  Let>tmp1=Select KC.AIN, KC.LegalAcres From TSBv_Parcelmaster AS KC WHERE KC.AIN IN (%AINLIST%)
  DBQuery>dbH,tmp1,KC_MASTR,NumRecs,NumFields,0
  SetFocus>ProVal
  Let>R=0
  Repeat>R
    Let>R=R+1
    LET>DBAIN=KC_MASTR_%R%_1
    LET>DBACRE=KC_MASTR_%R%_2
    Press LCTRL
    Wait>0.1
    Send>o
    Wait>0.1
    Release LCTRL
    Wait>1
    SetFocus>Parcel Selection
    Press Tab
    Release Tab
    Send>DBAIN
    Press TAB * 5
    Release Tab
    Press ENTER
    Release ENTER
    //Insert the Mapping Memo
    WAIT>2
    SetFocus>ProVal
    PRESS LCTRL
    PRESS SHIFT
    SEND>M
    Release LCTRL
    Release SHIFT
    WAIT>1
    SEND>L
    PRESS ENTER
    PRESS ENTER
    PRESS UP
    SEND>MemoTXT
    PRESS TAB
    PRESS ENTER
    //Find and Left Click Center of the land tab
    FindImagePos>%BMP_DIR%\image_4.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
    Endif
    WAIT>1
    //Find and Left Click Center of the land base sub tab
    FindImagePos>%BMP_DIR%\image_5.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
    Endif
    //Find and Left Click To the Right of the Farm Total Acres drop down
    FindImagePos>%BMP_DIR%\image_6.bmp,WINDOW:ProVal,0.7,8,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>{%XArr_0%+10},YArr_0
      LDBLClick
      SEND>DBACRE
    ELSE
    //Find and Left Click Below the Aggregate Land Type to click the ADD button
    FindImagePos>%BMP_DIR%\image_7.bmp,WINDOW:ProVal,0.7,6,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,{%YArr_0%+10}
      LClick
      SEND>F
      PRESS TAB
      SEND>DBACRE
      PRESS ENTER
    Endif
    Endif
    //Find and Left Click Center of the Permits TAB
    FindImagePos>%BMP_DIR%\image_8.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
      WAIT>2
    Endif
    //Find and Left Click Center of Add permit button when not highlighted
    FindImagePos>%BMP_DIR%\image_12.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
       WAIT>2.5
      SetFocus>Add Permit
      SEND>PNUMBER
      PRESS TAB
      SEND>S
      PRESS TAB*3
      SEND>PFILE
      PRESS TAB*3
      PRESS ENTER
      WAIT>2
    ELSE
    //Find and Left Click Center of Add permit button when it is highlighted
    FindImagePos>%BMP_DIR%\image_11.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
       WAIT>2.5
      SetFocus>Add Permit
      SEND>PNUMBER
      PRESS TAB
      SEND>S
      PRESS TAB*3
      SEND>PFILE
      PRESS TAB*3
      PRESS ENTER
      WAIT>2
      PRESS LSHIFT
      PRESS TAB*3
      RELEASE LSHIFT
      SEND>PDESC
    Endif
    Endif
    //Find and Left Click Center of the ADD FIELD VISIT BUTTON 
    FindImagePos>%BMP_DIR%\image_13.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
      //Find and Left Click To the Right of the WORK ASSIGNED DATE BUTTON 
    FindImagePos>%BMP_DIR%\image_14.bmp,WINDOW:ProVal,0.7,8,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>{%XArr_0%+10},YArr_0
      LClick
      PRESS TAB
      SEND>O
      PRESS DOWN
      PRESS TAB
      PRESS SPACE
      PRESS RIGHT
      SEND>4/1/2024
      PRESS TAB*3
      PRESS SPACE
      
    Endif
    Endif
  IF>TREVIEW=Y
  // FIND AND CLICK THE CENTER OF THE PERMIT TAB
  FindImagePos>%BMP_DIR%\image_8.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
      WAIT>2
    Endif
    //Find and Left Click Center of Add permit button when not highlighted
    FindImagePos>%BMP_DIR%\image_12.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
       WAIT>2.5
      SetFocus>Add Permit
      SEND>PNUMBER
      PRESS TAB
      SEND>T
      PRESS TAB*3
      SEND>PFILE
      PRESS TAB*3
      PRESS ENTER
      WAIT>2
      PRESS LSHIFT
      PRESS TAB*3
      RELEASE LSHIFT
      SEND>PDESC
    ELSE
    //Find and Left Click Center of Add permit button when it is highlighted
    FindImagePos>%BMP_DIR%\image_11.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
       WAIT>2.5
      SetFocus>Add Permit
      SEND>PNUMBER
      PRESS TAB
      SEND>T
      PRESS TAB*3
      SEND>PFILE
      PRESS TAB*3
      PRESS ENTER
      WAIT>2
      PRESS LSHIFT
      PRESS TAB*3
      RELEASE LSHIFT
      SEND>PDESC
    Endif
    Endif
    //Find and Left Click Center of the ADD FIELD VISIT BUTTON
    FindImagePos>%BMP_DIR%\image_13.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>XArr_0,YArr_0
      LClick
      WAIT>2
      //Find and Left Click To the Right of the WORK ASSIGNED DATE BUTTON
    FindImagePos>%BMP_DIR%\image_14.bmp,WINDOW:ProVal,0.7,8,XArr,YArr,NumFound,CCOEFF
    If>NumFound>0
      MouseMove>{%XArr_0%+10},YArr_0
      LClick
      PRESS TAB
      SEND>O
      PRESS DOWN
      PRESS TAB
      PRESS SPACE
      PRESS RIGHT
      SEND>4/1/2024
      PRESS TAB*3
      PRESS SPACE
      WAIT>1
    Endif
    Endif
  ENDIF
  PRESS LCTRL
  SEND>S
  RELEASE LCTRL
  WAIT 2
  //Find and Left Click Center of SAVE BUTTON 
  FindImagePos>%BMP_DIR%\image_15.bmp,WINDOW:ProVal,0.7,1,XArr,YArr,NumFound,CCOEFF
  If>NumFound>0
    MouseMove>XArr_0,YArr_0
    LClick
  Endif
  WAIT>2
  Until>R=NumRecs