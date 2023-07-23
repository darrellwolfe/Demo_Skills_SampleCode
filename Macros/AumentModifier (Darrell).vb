//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1


InputBox>N, What is the AIN?


//In Aumentum to Open Modifier


//Click Tax
MouseMove>2121,84
LClick
Wait 1

//Click Assessment Administration
MouseMove>2150,112
LClick
Wait 1

//Click Assessment Maintenance
MouseMove>2345,114
LClick
Wait 1

//Click Value Modifier Maitenance
MouseMove>2519,165
LClick
Wait 1


//Paste AIN

Send>n
Wait 1
Press Tab
Press Enter
Wait 1
Press Tab
Press Enter