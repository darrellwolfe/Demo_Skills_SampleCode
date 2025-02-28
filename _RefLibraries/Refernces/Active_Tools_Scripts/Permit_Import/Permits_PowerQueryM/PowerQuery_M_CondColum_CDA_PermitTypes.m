// Conditional Columns CDA Permits, Permit Types

//Mechanicals
if Text.Contains([permit_type], "MECHANICAL") then "9"

else if Text.Contains([project_description], "REPLACE") then "9"
else if Text.Contains([project_description], "REPAIR") then "9"
else if Text.Contains([project_description], "WINDOW") then "9"


else if Text.Contains([project_description], "REMODEL") then "3"



//DEMO
else if Text.Contains([project_description], "DEMO") then "6"


//MOBILE HOMES
else if Text.Contains([project_description], "MOBILE") then "99"
else if Text.Contains([project_description], "MANUFACT") then "99"
else if Text.Contains([project_description], "MH") then "99"



else if Text.Contains([project_description], "ADDITION") then "3"

else if Text.Contains([project_description], "ALT") then "3"




// RES NEW
else if [project_type] = "TOWN HOUSE" 
  or [project_type] = "MULTI-FAMILY"
  or (Text.Contains([project_description], "DUPLEX")
      and not Text.Contains([project_description], "REMODEL") 
      and not Text.Contains([project_description], "REPAIR")) then "1"

// RES NEW
else if [project_type] = "SINGLE-FAMILY" 
  and (Text.Contains([project_description], "SFD")
       or Text.Contains([project_description], "SFR") 
       or Text.Contains([project_description], "SINGLE") 
       or Text.Contains([project_description], "ADU") 
       or Text.Contains([project_description], "ALU") 
       or Text.Contains([project_description], "ACCESSORY")) 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") then "1"

// RES NEW (W/GARAGE)
else if Text.Contains([project_description], "W/GARAGE") 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") then "1"

//COMMERCIAL NEW
else if [project_type] = "COMMERCIAL" 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") 
  and not Text.Contains([project_description], "ADDITION") 
  and not Text.Contains([project_description], "CHANGE OF") 
  and not Text.Contains([project_description], "TI") 
  and not Text.Contains([project_description], "T.I.") 
  and not Text.Contains([project_description], "TENANT") 
  and not Text.Contains([project_description], "REPLACE") 
  and not Text.Contains([project_description], "T.") 
  and not Text.Contains([project_description], "I.") 
  and not Text.Contains([project_description], "T ") 
  and not Text.Contains([project_description], "I ") 
  and Text.Contains([project_description], "BLDG")
  and Text.Contains([project_description], "NEW")
    or Text.Contains([project_description], "MIXED USE") then "2"


else if [project_type] = "COMMERCIAL" 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") 
  and not Text.Contains([project_description], "ADDITION") 
  and not Text.Contains([project_description], "CHANGE OF") 
  and not Text.Contains([project_description], "TI") 
  and not Text.Contains([project_description], "T.I.") 
  and not Text.Contains([project_description], "TENANT") 
  and not Text.Contains([project_description], "REPLACE") 
  and not Text.Contains([project_description], "T.") 
  and not Text.Contains([project_description], "I.") 
  and not Text.Contains([project_description], "T ") 
  and not Text.Contains([project_description], "I ") 
  and Text.Contains([project_description], "BLDG") then "2"

else if [project_type] = "COMMERCIAL" 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") 
  and not Text.Contains([project_description], "ADDITION") 
  and not Text.Contains([project_description], "CHANGE OF") 
  and not Text.Contains([project_description], "TI") 
  and not Text.Contains([project_description], "T.I.") 
  and not Text.Contains([project_description], "TENANT") 
  and not Text.Contains([project_description], "REPLACE") 
  and not Text.Contains([project_description], "T.") 
  and not Text.Contains([project_description], "I.") 
  and not Text.Contains([project_description], "T ") 
  and not Text.Contains([project_description], "I ") 
  and Text.Contains([project_description], "MIXED USE")
  and Text.Contains([project_description], "BUILDING") then "2"

else if [project_type] = "COMMERCIAL" 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") 
  and not Text.Contains([project_description], "ADDITION") 
  and not Text.Contains([project_description], "CHANGE OF") 
  and not Text.Contains([project_description], "TI") 
  and not Text.Contains([project_description], "T.I.") 
  and not Text.Contains([project_description], "TENANT") 
  and not Text.Contains([project_description], "REPLACE") 
  and not Text.Contains([project_description], "T.") 
  and not Text.Contains([project_description], "I.") 
  and not Text.Contains([project_description], "T ") 
  and not Text.Contains([project_description], "I ") 
  and Text.Contains([project_description], "NEW")
  and Text.Contains([project_description], "BUILDING") then "2"


else if [project_type] = "COMMERCIAL" 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") 
  and not Text.Contains([project_description], "ADDITION") 
  and not Text.Contains([project_description], "CHANGE OF") 
  and not Text.Contains([project_description], "TI") 
  and not Text.Contains([project_description], "T.I.") 
  and not Text.Contains([project_description], "T.") 
  and not Text.Contains([project_description], "I.") 
  and not Text.Contains([project_description], "T ") 
  and not Text.Contains([project_description], "I ") 
  and not Text.Contains([project_description], "TENANT") 
  and not Text.Contains([project_description], "REPLACE") 

  and Text.Contains([project_description], "MIXED USE") then "2"

else if [project_type] = "COMMERCIAL" 
  and not Text.Contains([project_description], "REMODEL") 
  and not Text.Contains([project_description], "REPAIR") 
  and not Text.Contains([project_description], "CHANGE OF") 
  and not Text.Contains([project_description], "TI") 
  and not Text.Contains([project_description], "T.I.") 
  and not Text.Contains([project_description], "T.") 
  and not Text.Contains([project_description], "I.") 
  and not Text.Contains([project_description], "T ") 
  and not Text.Contains([project_description], "I ") 
  and not Text.Contains([project_description], "TENANT")
  and not Text.Contains([project_description], "REPLACE") 
  and not Text.Contains([project_description], "ADDITION") then "2"



//COMMERCIAL ADD ALT TIs
else if [project_type] = "COMMERCIAL" 
  and Text.Contains([project_description], "T.I.")
  or Text.Contains([project_description], "TI") 
  or Text.Contains([project_description], "T.I.") 
  or Text.Contains([project_description], "T.") 
  or Text.Contains([project_description], "I.") 
  or Text.Contains([project_description], "T ") 
  or Text.Contains([project_description], "I ") 
  or Text.Contains([project_description], "TENANT") then "3"



//RES OUTBUILDING
else if [project_type] = "SINGLE-FAMILY" 
  or Text.Contains([project_description], "NEW DETACHED") then "4"




//Mechanicals
else if Text.Contains([project_description], "SOLAR") then "9"
else if Text.Contains([project_description], "WINDOW") then "9"
else if Text.Contains([project_description], "ROOF") then "9"
else if Text.Contains([project_description], "AC") then "9"
else if Text.Contains([project_description], "A/C") then "9"
else if Text.Contains([project_description], "HEATER") then "9"
else if Text.Contains([project_description], "DOOR") then "9"
else if Text.Contains([project_description], "REPAIR") then "9"
else if Text.Contains([project_description], "REPLACE") then "9"
else if Text.Contains([project_description], "SIDING") then "9"
else if Text.Contains([project_description], "GENERATOR") then "9"
else if Text.Contains([project_description], "MECH") then "9"










//COMMERCIAL ADD ALT
else if [project_type] = "COMMERCIAL" 
  and Text.Contains([project_description], "T.I.")
  or Text.Contains([project_description], "TI") 
  or Text.Contains([project_description], "T.I.") 
  or Text.Contains([project_description], "T.") 
  or Text.Contains([project_description], "I.") 
  or Text.Contains([project_description], "T ") 
  or Text.Contains([project_description], "I ") 
  or Text.Contains([project_description], "TENANT")
  or Text.Contains([project_description], "DAMAGE") 
  or Text.Contains([project_description], "REPAIR") 
  or Text.Contains([project_description], "DEMO") 
  or Text.Contains([project_description], "REMODEL") 
  or Text.Contains([project_description], "EXISTING") 
  or Text.Contains([project_description], "CHANGE") 
  or Text.Contains([project_description], "RESTROOM") 
  or Text.Contains([project_description], "TANK")
  or Text.Contains([project_description], "POOL")
  or Text.Contains([project_description], "WAKE-UP")
  or Text.Contains([project_description], "OVERHANG")
  or Text.Contains([project_description], "ADDITION")
  or Text.Contains([project_description], "COVER") then "3"

//RES ADD/ALT
else if [project_type] = "SINGLE-FAMILY" 
  and Text.Contains([project_description], "REFRAMING") 
  or Text.Contains([project_description], "REPAIR") 
  or Text.Contains([project_description], "AWNING") 
  or Text.Contains([project_description], "EXISTING") 
  or Text.Contains([project_description], "BATH")
  or Text.Contains([project_description], "DECK")
  or Text.Contains([project_description], "REBUILD")
  or Text.Contains([project_description], "STAIRS")
  or Text.Contains([project_description], "PORCH")
  or Text.Contains([project_description], "REMODEL")
  
  or Text.Contains([project_description], "ADDITION") then "3"


//RES OUTBUILDING
else if [project_type] = "SINGLE-FAMILY" 
  and Text.Contains([project_description], "POLE")
  or Text.Contains([project_description], "SHED") 
  or Text.Contains([project_description], "CARPORT") 
  or Text.Contains([project_description], "GARAGE") 
  or Text.Contains([project_description], "OUTDOOR")
  or Text.Contains([project_description], "SHOP")
  or Text.Contains([project_description], "PERGOLA")
  or Text.Contains([project_description], "PAVILLION")
  or Text.Contains([project_description], "RETAINING")
  or Text.Contains([project_description], "NEW DETACHED")
  or Text.Contains([project_description], "BARN") then "4"



//RES OUTBUILDING
else if [project_type] = "SINGLE-FAMILY" 
  and Text.Contains([project_description], "POLE")
  or Text.Contains([project_description], "SHED") 
  or Text.Contains([project_description], "CARPORT") 
  or Text.Contains([project_description], "GARAGE") 
  or Text.Contains([project_description], "OUTDOOR")
  or Text.Contains([project_description], "SHOP")
  or Text.Contains([project_description], "PERGOLA")
  or Text.Contains([project_description], "PAVILLION")
  or Text.Contains([project_description], "RETAINING")
  or Text.Contains([project_description], "BARN") then "4"


//DOCK PERMITS
else if Text.Contains([project_description], "BOAT") then "14"
else if Text.Contains([project_description], "DOCK") then "14"



// CLEAN UP LOGIC
else if Text.Contains([project_description], "FINISH") then "3"
else if Text.Contains([project_description], "BASEMENT") then "3"
else if Text.Contains([project_description], "ADD") then "3"
else if Text.Contains([project_description], "GAZEBO") then "4"
else if Text.Contains([project_description], "TOWN HOUSE") then "1"
else if Text.Contains([project_description], "NEW RESIDENCE") then "1"
else if Text.Contains([project_description], "HOME") then "1"
else if Text.Contains([project_description], "GARAGE") then "4"
//else if Text.Contains([project_description], "XXXXX") then "XXX"
//else if Text.Contains([project_description], "XXXXX") then "XXX"









else "5"