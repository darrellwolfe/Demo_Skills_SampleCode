-- Inside Power Query, Advanced Editor
District-Geo Key
--Step One, paste the District-Geo Key

let
    Source = Sql.Database("AsTxDBProd", "GRM_Main"),
    dbo_KCv_PARCELMASTER1 = Source{[Schema="dbo",Item="KCv_PARCELMASTER1"]}[Data],
    #"Active Only" = Table.SelectRows(dbo_KCv_PARCELMASTER1, each ([EffStatus] = "A")),
    #"Grouped Rows" = Table.Group(#"Active Only", {"neighborhood"}, {{"Count", each Table.RowCount(_), type number}}),
    #"Removed Columns" = Table.RemoveColumns(#"Grouped Rows",{"Count"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"neighborhood", "GEO"}}),
    #"Sorted Rows" = Table.Sort(#"Renamed Columns",{{"GEO", Order.Ascending}}),
    #"Filtered Rows" = Table.SelectRows(#"Sorted Rows", each ([GEO] <> null)),
    #"District Key" = Table.AddColumn(#"Filtered Rows", "District", each if [GEO] >= 9000 then "Manufactured Homes" else if [GEO] >= 6003 then "District 6" else if [GEO] = 6002 then "Manufactured Homes" else if [GEO] = 6001 then "District 6" else if [GEO] = 6000 then "Manufactured Homes" else if [GEO] >= 5003 then "District 5" else if [GEO] = 5002 then "Manufactured Homes" else if [GEO] = 5001 then "District 5" else if [GEO] = 5000 then "Manufactured Homes" else if [GEO] >= 4000 then "District 4" else if [GEO] >= 3000 then "District 3" else if [GEO] >= 2000 then "District 2" else if [GEO] >= 1021 then "District 1" else if [GEO] = 1020 then "Manufactured Homes" else if [GEO] >= 1001 then "District 1" else if [GEO] = 1000 then "Manufactured Homes" else if [GEO] >= 451 then "Commercial" else if [GEO] = 450 then "Personal Property" else if [GEO] >= 1 then "Commercial" else if [GEO] = 0 then "N/A or Error" else null),
    #"Reordered Columns" = Table.ReorderColumns(#"District Key",{"District", "GEO"}),
    #"Sorted Rows1" = Table.Sort(#"Reordered Columns",{{"District", Order.Ascending}, {"GEO", Order.Ascending}}),
    #"Improvement ID" = Table.AddColumn(#"Sorted Rows1", "Improvement ID", each if [District] = "Commercial" then "C" else if Text.Contains([District], "District") then "D" else if [District] = "Manufactered Homes" then "M" else "N/A"),
    #"Added Conditional Column" = Table.AddColumn(#"Improvement ID", "Const Type", each if [Improvement ID] = "C" then "Commercial Const" else if [Improvement ID] = "D" then "Residential Const" else if [Improvement ID] = "M" then "MH Const" else "N/A")
in
    #"Added Conditional Column"


--Step Two, rename the query from Step One from "Query1 to District-Geo Key, THEN, paste the Imp Types

let
    Source = #"District-Geo Key",
    #"Removed Duplicates" = Table.Distinct(Source, {"Improvement ID"}),
    #"Removed Other Columns" = Table.SelectColumns(#"Removed Duplicates",{"District", "Improvement ID", "Const Type"})
in
    #"Removed Other Columns"
