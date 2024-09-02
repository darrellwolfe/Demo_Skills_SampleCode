if [YearBuilt] > Date.Year(DateTime.LocalNow()) - 5 
    and [NetImpAssessedMinusHOEX] = [TaxableValue] 
    and [YearBuilt] = [ImpValDetail_YearBuilt]
    and [NewDevRollYear] = null 
    and [ImpValDetail_ImpId] <> "C"
then "OK"

else if [NewDevRollYear] <> null
then "REMOVE"

else if [ImpValDetail_ImpId] = "C"
then "REMOVE"

else if [NetImpAssessedMinusHOEX] <> [TaxableValue]
then "UPDATE"

else if [YearBuilt] <> [ImpValDetail_YearBuilt]
then "YEAR_WRONG"

else if [YearBuilt] <= Date.Year(DateTime.LocalNow()) - 5
then "REMOVE"

else "REVIEW"

