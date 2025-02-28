//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1


SetFocus>ProVal
// This opens the Sales Records Popup Window
press alt
release alt
send>ap
Let>WW_TIMEOUT=10
WaitWindowOpen>Update Sales Transaction Information
press tab
