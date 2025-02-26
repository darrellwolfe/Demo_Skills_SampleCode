// Conditional Columns CDA Permits, Permit Types


// Updated Conditional Columns Logic for CDA Permits, Permit Types based on Client Feedback

// Fire Damage or Fire Repair
//Anything with the words “Fire Damage” or “Fire Repair” should be Mandatory Reviews for us. 
  //  Those will most likely be remodel permit situations for us and involve a bit more of a value change.

if ((Text.Contains([project_description], "FIRE") 
    or Text.Contains([project_description], "SMOKE"))
  and (Text.Contains([project_description], "REPAIR")
    or Text.Contains([project_description], "DAMAGE")) ) then "6"


//MOBILE HOMES
else if Text.Contains([project_description], "MOBILE") then "99"
else if Text.Contains([project_description], "MANUFACT") then "99"
else if Text.Contains([project_description], "MH") then "99"



//DEMOS—Demo of full house or other structures are Mandatory Reviews, 
  //  but Demo of interior walls (there is also usually a remodel permit on top of these), decks, or other minor 
  //  demo things are not Mandatory Reviews. They can be moved into the Addition/Alt/Remodel category.

//DEMO
else if Text.Contains([project_description], "DEMO") 
  and (Text.Contains([project_description], "INTERIOR")
  or Text.Contains([project_description], "WALL")
  or Text.Contains([project_description], "STAIR")
  or Text.Contains([project_description], "WALK")
  or Text.Contains([project_description], "PARTIAL")) then "3"

else if Text.Contains([project_description], "DEMO") then "6"



// RES NEW
else if Text.Contains([project_description], "TOWN HOUSE") then "1"
else if Text.Contains([project_description], "NEW RESIDENCE") then "1"
else if Text.Contains([project_description], "HOME") then "1"

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



//COMMERCIAL NEW
else if [project_type] = "COMMERCIAL" 
  and not (Text.Contains([project_description], "REMODEL") 
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
    and not Text.Contains([project_description], "I "))
  and (Text.Contains([project_description], "BLDG")
      or Text.Contains([project_description], "NEW")
      or Text.Contains([project_description], "MIXED USE")
      or Text.Contains([project_description], "BUILDING") ) then "2"


//COMMERCIAL ADD ALT
else if [project_type] = "COMMERCIAL" 
  and (Text.Contains([project_description], "T.I.")
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
    or Text.Contains([project_description], "COVER") ) then "3"







//Outbuilding/Garage Permits are just meant for Sheds, Pole Buildings, Shops, Garages, Detached Garages, etc., 
  //  so “Buildings,” not remodel type items.
//OUTBUILDINGS
else if Text.Contains([project_description], "POLE")
  or Text.Contains([project_description], "SHED") 
  or Text.Contains([project_description], "CARPORT") 
  or Text.Contains([project_description], "GARAGE") 
  or Text.Contains([project_description], "OUTDOOR")
  or Text.Contains([project_description], "SHOP")
  or Text.Contains([project_description], "SHOP")
  //or Text.Contains([project_description], "PERGOLA")
  or Text.Contains([project_description], "DETACHED GARAGE")
  or Text.Contains([project_description], "BARN") then "4"

 

//Deck additions/changes, Porches, Dormers, Add Bathroom, Carriage House Interior Finish, Entry doors, Finish Basement , etc.
  //  —Those items can go to the Addition/Alt/Remodel type permits category.

// ADD ALTS
else if (Text.Contains([project_description], "REMODEL") 
  or Text.Contains([project_description], "ADDITION")
  or Text.Contains([project_description], "ALT") 
  or Text.Contains([project_description], "ADD") 
  or Text.Contains([project_description], "REPAIR") 
  or Text.Contains([project_description], "REPLACE") 
  or Text.Contains([project_description], "PARTIAL") 
  or Text.Contains([project_description], "INTERIOR") 
  
  // EXTRA STRUCTURES NOT INHABITABLE
  or Text.Contains([project_description], "DECK") 
  or Text.Contains([project_description], "PERGOLA") 
  or Text.Contains([project_description], "PAVILLION")
  or Text.Contains([project_description], "RETAINING")
  or Text.Contains([project_description], "GAZEBO")
  or Text.Contains([project_description], "POOL")
  or Text.Contains([project_description], "AWNINGS")
  or Text.Contains([project_description], "PATIO")
  or Text.Contains([project_description], "COVER")
  or Text.Contains([project_description], "REBUILD")
  or Text.Contains([project_description], "POOL")

  // REMODEL ACTIVITIES
  or Text.Contains([project_description], "FINISH") 
  or Text.Contains([project_description], "BASEMENT") 
  or Text.Contains([project_description], "DOOR") 
  or Text.Contains([project_description], "INSTALL") 
  or Text.Contains([project_description], "BASEMENT") 
  or Text.Contains([project_description], "BATHROOM") 
  or Text.Contains([project_description], "WINDOW") 
  or Text.Contains([project_description], "PORCH") 
  or Text.Contains([project_description], "SOLAR") 
  or Text.Contains([project_description], "STAIRS") 
  or Text.Contains([project_description], "WALL") )  then "3"
//  or Text.Contains([project_description], "xxxxxx") 
//  or Text.Contains([project_description], "xxxxxx") 



else if [project_type] = "COMMERCIAL" then "2"



//Mechanicals
else if (Text.Contains([project_description], "ROOF") 
  or Text.Contains([project_description], "AC") 
  or Text.Contains([project_description], "A/C") 
  or Text.Contains([project_description], "HEATER") 
  or Text.Contains([project_description], "SIDING") 
  or Text.Contains([project_description], "GENERATOR") 
  or Text.Contains([project_description], "MECH")) then "9"


else if Text.Contains([permit_type], "MECHANICAL") then "9"


else "5"