// 2023

let
    Source = Excel.Workbook(File.Contents("S:\Common\Comptroller Tech\Reports\Permits - Import\Permits_CompTechImports\ATHOL\Planning&Zoning Permits - Log List.xlsx"), null, true),
    #"PnZ BLP FY 2023_Sheet" = Source{[Item="PnZ BLP FY 2023",Kind="Sheet"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(#"PnZ BLP FY 2023_Sheet",{{"Column1", type any}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}}),
    #"Removed Top Rows" = Table.Skip(#"Changed Type",4),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"DATE OF APPLICATION", type date}, {"PERMIT #", type text}, {"NAME OF APPLICANT", type text}, {"ADDRESS", type text}, {"DESCRIPTION OF WORK/REQUEST", type text}, {"STATUS", type text}, {"INSPECTION OF COMPLETED WORK", type text}, {"NOTES", type text}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type1", each ([STATUS] <> null)),





    #"Split Column by Delimiter" = Table.SplitColumn(#"Filtered Rows", "STATUS", Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, false), {"STATUS.1", "STATUS.2"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Split Column by Delimiter",{{"STATUS.1", type text}, {"STATUS.2", type date}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type2",{{"STATUS.2", "FILING DATE"}, {"DESCRIPTION OF WORK/REQUEST", "DESCRIPTION"}, {"PERMIT #", "REFERENCE #"}}),
    #"Uppercased Text" = Table.TransformColumns(#"Renamed Columns",{{"ADDRESS", Text.Upper, type text}}),
    #"READY TO MATCH" = Table.TransformColumns(#"Uppercased Text",{{"ADDRESS", Text.Trim, type text}})
in
    #"READY TO MATCH"


//2024
// Change This
let
    Source = Excel.Workbook(File.Contents("S:\Common\Comptroller Tech\Reports\Permits - Import\Permits_CompTechImports\ATHOL\Planning&Zoning Permits - Log List.xlsx"), null, true),
    #"PnZ BLP 2024_Sheet" = Source{[Item="PnZ BLP 2024",Kind="Sheet"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(#"PnZ BLP 2024_Sheet",{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}}),
    #"Removed Top Rows" = Table.Skip(#"Changed Type",4),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"DATE OF APPLICATION", type text}, {"PERMIT #", type text}, {"NAME OF APPLICANT", type text}, {"ADDRESS", type text}, {"DESCRIPTION OF WORK/REQUEST", type text}, {"STATUS", type text}, {"INSPECTION OF COMPLETED WORK", type text}, {"NOTES", type text}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type1", each ([#"PERMIT #"] <> null and [#"PERMIT #"] <> "CITY OF ATHOL -- Planning & Zoning  --   " and [#"PERMIT #"] <> "PERMIT #"))
in
    #"Filtered Rows"

// To This
let
    Source = Excel.Workbook(File.Contents("S:\Common\Comptroller Tech\Reports\Permits - Import\Permits_CompTechImports\ATHOL\Planning&Zoning Permits - Log List.xlsx"), null, true),
    #"PnZ BLP 2024_Sheet" = Source{[Item="PnZ BLP 2024",Kind="Sheet"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(#"PnZ BLP 2024_Sheet",{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}}),
    #"Removed Top Rows" = Table.Skip(#"Changed Type",4),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"DATE OF APPLICATION", type text}, {"PERMIT #", type text}, {"NAME OF APPLICANT", type text}, {"ADDRESS", type text}, {"DESCRIPTION OF WORK/REQUEST", type text}, {"STATUS", type text}, {"INSPECTION OF COMPLETED WORK", type text}, {"NOTES", type text}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type1", each ([#"PERMIT #"] <> null and [#"PERMIT #"] <> "CITY OF ATHOL -- Planning & Zoning  --   " and [#"PERMIT #"] <> "PERMIT #")),

    #"Split Column by Delimiter" = Table.SplitColumn(#"Filtered Rows", "STATUS", Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, false), {"STATUS.1", "STATUS.2"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Split Column by Delimiter",{{"STATUS.1", type text}, {"STATUS.2", type date}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type2",{{"STATUS.2", "FILING DATE"}, {"DESCRIPTION OF WORK/REQUEST", "DESCRIPTION"}, {"PERMIT #", "REFERENCE #"}}),
    #"Uppercased Text" = Table.TransformColumns(#"Renamed Columns",{{"ADDRESS", Text.Upper, type text}}),
    #"READY TO MATCH" = Table.TransformColumns(#"Uppercased Text",{{"ADDRESS", Text.Trim, type text}})
in
    #"READY TO MATCH"




