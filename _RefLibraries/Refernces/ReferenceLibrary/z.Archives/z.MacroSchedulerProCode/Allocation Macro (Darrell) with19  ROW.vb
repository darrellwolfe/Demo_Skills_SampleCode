//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1
let>r=0
Repeat>r
  let>r=r+1
//Open Allocations Menu
Press F9
Wait 1
//Repeat for number of land lines you are changing
Press Down * 2
Press Space
Wait 1
Press ALT
Press LALT
Send>e
Release ALT
Wait 1
// Change to reflect the allocation that you want selected
//Press Tab *1
//Press DOWN * 10
Press Tab * 1
Wait 1
Press DOWN * 6
Wait 1
Press Tab
Press Enter

//Repeat for number of land lines you are changing
Press Down * 4
Press Space
Wait 1
Press ALT
Press LALT
Send>e
Release ALT
Wait 1
// Change to reflect the allocation that you want selected
//Press Tab *4
Press DOWN * 6
Press Tab *1
Wait 1
Press DOWN * 6
Wait 1
Press Tab
Press Enter



//Enter to save, Alt N to Done
Press Enter
Press ALT
Press LALT
Send>n
Release ALT
Wait 1
Press F3
Press Enter
wait 3
until>r=52
