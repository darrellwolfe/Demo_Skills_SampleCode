// CUSTOM COLUMN FOR permit_type

if [Permit Type] = "MECHANICAL" then 9
else if [Permit Type] = "ENCROACHMENT/RIGHT OF WAY" then 9
else if [Permit Type] = "BUILDING"
and [Project Type] = "ROOF" then 9
else if [Permit Type] = "BUILDING"
and [Project Type] = "NEW SINGLE FAMILY RESIDENCE" then 1
else if [Permit Type] = "BUILDING"
and [Project Type] = "GARAGE OR OUTBUILDING" then 4
else if [Permit Type] = "BUILDING"
and [Project Type] = "OTHER" then 3
else if [Permit Type] = "BUILDING"
and [Project Type] = "DEMOLITION" then 6
else 0