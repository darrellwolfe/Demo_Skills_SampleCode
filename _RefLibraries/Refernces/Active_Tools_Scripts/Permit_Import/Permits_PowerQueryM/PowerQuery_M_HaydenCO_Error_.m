let
    Source = Folder.Files("S:\Common\Comptroller Tech\Reports\Permits - Import\Permits_CompTechImports\HAYDEN COs"),
    #"Filtered Hidden Files1" = Table.SelectRows(Source, each [Attributes]?[Hidden]? <> true),
    #"Invoke Custom Function1" = Table.AddColumn(#"Filtered Hidden Files1", "Transform File from HAYDEN COs", each #"Transform File from HAYDEN COs"([Content])),
    #"Renamed Columns1" = Table.RenameColumns(#"Invoke Custom Function1", {"Name", "Source.Name"}),
    #"Removed Other Columns1" = Table.SelectColumns(#"Renamed Columns1", {"Source.Name", "Transform File from HAYDEN COs"}),
    #"Expanded Table Column1" = Table.ExpandTableColumn(#"Removed Other Columns1", "Transform File from HAYDEN COs", Table.ColumnNames(#"Transform File from HAYDEN COs"(#"Sample File (2)"))),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Table Column1",{{"Source.Name", type text}, {"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type any}, {"Column7", type text}, {"Column8", type text}}),
    #"Removed Top Rows" = Table.Skip(#"Changed Type",1),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Remove null" = Table.SelectRows(#"Promoted Headers", each ([Permit Number] <> null)),
    #"Remove OCC" = Table.SelectRows(#"Remove null", each not Text.Contains([Permit Number], "OCC")),
    #"Filtered Rows" = Table.SelectRows(#"Remove OCC", each not Text.Contains([Permit Number], "Permit")),
    #"Trimmed Text" = Table.TransformColumns(#"Filtered Rows",{{"Permit Number", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text",{{"Permit Number", Text.Clean, type text}}),
    #"Uppercased Text" = Table.TransformColumns(#"Cleaned Text",{{"Permit Number", Text.Upper, type text}})
in
    #"Uppercased Text"


    // An error occurred in the ‘Transform File from HAYDEN COs’ query. Expression.Error: The key didn't match any rows in the table.
//Details:
 //   Key=
  //      Item=ASSESSOR OCCUPANCY RPT
   //     Kind=Sheet
   // Table=[Table]