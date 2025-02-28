// Start a BLANK query in Power Query, paste this into Advanced Editor

let
    // Set the start and end dates
    // Reval Cycle 04/15/2022 - 04/16/2028
    StartDate = #date(2022, 4, 15),
    EndDate = #date(2028, 4, 16),

    // Generate a list of dates
    DateList = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),

    // Convert the list to a table
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),

    // Change the Date column type to Date
    TypedDateTable = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),

    // Add DateKey column
    AddDateKey = Table.AddColumn(TypedDateTable, "DateKey", each Date.ToText([Date], "yyyyMMdd"), type text),

    // Reorder columns to have DateKey first
    ReorderedColumns = Table.ReorderColumns(AddDateKey, {"DateKey", "Date"}),

    // Sort the table by Date
    SortedTable = Table.Sort(ReorderedColumns, {{"Date", Order.Ascending}}),
    #"Inserted Month" = Table.AddColumn(SortedTable, "Month", each Date.Month([Date]), Int64.Type),
    #"Inserted Month Name" = Table.AddColumn(#"Inserted Month", "Month Name", each Date.MonthName([Date]), type text),
    #"Inserted Year" = Table.AddColumn(#"Inserted Month Name", "Year", each Date.Year([Date]), Int64.Type)
in
    #"Inserted Year"