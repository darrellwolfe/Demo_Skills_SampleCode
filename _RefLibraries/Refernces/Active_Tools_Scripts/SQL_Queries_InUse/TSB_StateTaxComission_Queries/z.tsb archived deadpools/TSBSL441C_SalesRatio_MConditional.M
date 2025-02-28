

TSBSL441C_SalesRatio_MConditional





if Text.Contains([SalesMemos], "invalid") then "Check"
else if Text.Contains([SalesMemos], "not") then "Check"
else if Text.Contains([SalesMemos], "REO") then "Check"
else if Text.Contains([SalesMemos], "family") then "Check"

else null


























else if Text.Contains([SalesMemos], "xxxxxx") then "Check"