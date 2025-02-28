------------------------------------------
-- Conditional Columns CDA Permits, Permit Types
--[RcType]
--[RcSubType]
--[PermitDesc]

[RcType] = "xxxx" 
RESIDENTIAL BUILDING
COMMERCIAL BUILDING

MANUFACTURED HOME

<- Add/Alt
STORM REPAIR
DEMOLITION

<- Dock
TRAM 
FLOODPLAIN DEVELOPMENT PERMIT

<- MECH
MECHANICAL
RETAINING WALL
SWIMMING POOL
LOCATION
OFFICE FEES


<- Disinclude
SIGN
SITE DISTURBANCE
FENCE


[RcType] = "xxxx" 
Text.Contains([RcSubType], "xxxxxxx") then 1

------------------------------------------

if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "ACCESSORY LIVING UNIT") then 1

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "DWELLING") then 1

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "ACCESSORY STRUCTURE") then 4

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "ADDITION/ALTERATION") then 3

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "AG EXEMPT") then 4

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "BUILDING EXTERIOR") then 9

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "DECK/PORCH") then 3

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "HANGAR") then 4

else if [RcType] = "RESIDENTIAL BUILDING" 
and Text.Contains([RcSubType], "TEMPORARY") then 5

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "NEW") then 2

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "HANGAR") then 2

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "STRUCTURE") then 2

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "ADDITION/ALTERATION") then 3

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "CHANGE OF USE") then 3

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "BUILDING EXTERIOR") then 9

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "MISC") then 5

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "TENANT IMPROVEMENT") then 3

else if [RcType] = "COMMERCIAL BUILDING" 
and Text.Contains([RcSubType], "TOWER") then 15

else if [RcType] = "MANUFACTURED HOME" then 99

else if [RcType] = "DEMOLITION" then 3

else if [RcType] = "SWIMMING POOL" then 3

else if [RcType] = "MECHANICAL" then 9

else if [RcType] = "FLOODPLAIN DEVELOPMENT PERMIT" then 14

else if [RcType] = "STORM REPAIR" then 3

else if Text.Contains([RcType], "TRAM") then 14

else if Text.Contains([RcType], "RETAINING WALL") then 9

else if Text.Contains([RcSubType], "ADDITION/ALTERATION") then 3

else if Text.Contains([RcSubType], "DECK/PORCH") then 1

else if Text.Contains([RcSubType], "GARAGE/CARPORT") then 4

else if Text.Contains([RcSubType], "HANGAR") then 1

else 0

