



// REPLACE the Power Query fx "Transform File from HAYDEN COs"

```{m}

let
    Source = (#"Sample File Parameter2" as binary) => let
        Source = Excel.Workbook(#"Sample File Parameter2", null, true),
        #"ASSESSOR OCCUPANCY RPT_Sheet" = Source{[Item="ASSESSOR OCCUPANCY RPT",Kind="Sheet"]}[Data]
    in
        #"ASSESSOR OCCUPANCY RPT_Sheet"
in
    Source

```

// with 

```{m}

let
    Source = (#"Sample File Parameter2" as binary) => let
        Source = Excel.Workbook(#"Sample File Parameter2", null, true),
        FirstSheet = Source{0}[Data]  // Always select the first sheet
    in
        FirstSheet
in
    Source

```


// This eliminates the error looking for a particular sheet name. f

// Same for Permits transformer 

```{m}
let
    Source = (#"Sample File Parameter1") =>
let
    Source = Excel.Workbook(#"Sample File Parameter1", null, true),
    FirstSheet = Source{0}[Data]
in
    FirstSheet
in
    Source
```



// The actual code for HAYDEN COs references this function above, so, I had to step one step back to fix the function, not the later code... This code below is what uses the function(s) above... 

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



////// DIAGNOSTIC THREAD -- SEE ASANA FOR SCREENSHOTS


Comments
All activity
Hide earlier comments
Darrell Wolfe created this task · 47 minutes ago
Darrell Wolfe · 46 minutes ago
What is the error? 

An error occurred in the ‘Transform File from HAYDEN COs’ query. Expression.Error: The key didn't match any rows in the table.
Details:
    Key=
        Item=ASSESSOR OCCUPANCY RPT
        Kind=Sheet
    Table=[Table]


Darrell Wolfe · 44 minutes ago
An error occurred in the ‘Transform File from HAYDEN COs’ query.

The Transform File is the process Power Query M goes through to take a group of CSVs and transform them into a single table. 


Darrell Wolfe · 43 minutes ago
Nothing obvious inside Power Query itself at first...
Darrell Wolfe · 40 minutes ago
So in the HAYDEN COs, I review the Applied Steps (far right) from the beggining. At "Removed Other Columns1" I found an issue. It recognizes (based on the 'same' files) 01/2023 through 05/2024, but suddenly it doesn't recognize 6, 7, 8.... Odd....
Darrell Wolfe · 39 minutes ago
I created a duplicate of this (so I wouldn't mess up all my other steps on the original, and then hit one of the errors to see what would happen.... and got the same error message from downline in the later logic.... 



Darrell Wolfe · 36 minutes ago
I created a BLANK workbook, and named it Hayden_Error_Finder in the main permits folder... 

I'm going a fresh compile to see what the initials steps show me... 

From the Data tab in Excel, 
Get Data > From File > From Folder

S:\Common\Comptroller Tech\Reports\Permits - Import\Permits_CompTechImports\HAYDEN COs

Combine & Transform Data


Darrell Wolfe · 34 minutes ago
Now this is interesting.... The initials error that started this says "Details:
    Key=
        Item=ASSESSOR OCCUPANCY RPT
        Kind=Sheet
    Table=[Table]"

On this page, the table containing the report is called "ASSESSOR OCCUPANCY RPT", so I'm on to something!? 

ASSESSOR OCCUPANCY RPT


Darrell Wolfe · 33 minutes ago

Darrell Wolfe · 32 minutes ago












Darrell Wolfe · 32 minutes ago
Seriously!?!?!? They RENAMED the files they're sending us??
Darrell Wolfe · 30 minutes ago
You've got to be kidding me... it's the SHEET NAMES!?






Darrell Wolfe · 28 minutes ago
From inside the original workbook, I want to get the transform steps from Power Query M's code (not the gui, but the actual code) and see if there's a work around for what a human screws up the sheet names.... 



Darrell Wolfe · 28 minutes ago
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
Darrell Wolfe · 25 minutes ago(edited)
ChatGPT40 Prompt: 

I have Power Query M code that gathers multiple CSVs from a folder into a single table and then performs steps on that table. I got an errror message indicating it could not transform the most recent three CSVs. After tracking down this error, I learned that the SHEET NAMES were changed by the sender on the final three reports. How can I build a query that does all the same steps, but ignores sheet names when compiling the CSVs into a table, and simply grabs Sheet1 from each table regardless of the name of that sheet? Here is my error `` and here is my Power Query M code ``. << Then past those two between the ``
Darrell Wolfe · 23 minutes ago
Final Prompt is this:
Darrell Wolfe · 20 minutes ago
I have Power Query M code that gathers multiple CSVs from a folder into a single table and then performs steps on that table. I got an errror message indicating it could not transform the most recent three CSVs. After tracking down this error, I learned that the SHEET NAMES were changed by the sender on the final three reports. How can I build a query that does all the same steps, but ignores sheet names when compiling the CSVs into a table, and simply grabs Sheet1 from each table regardless of the name of that sheet? 



Here is my error 

`An error occurred in the ‘Transform File from HAYDEN COs’ query. Expression.Error: The key didn't match any rows in the table.
Details:
    Key=
        Item=ASSESSOR OCCUPANCY RPT
        Kind=Sheet
    Table=[Table]` 



and here is my Power Query M code 


`let
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
    #"Uppercased Text"`.
Darrell Wolfe · 18 minutes ago
The error you encountered occurs because the Power Query M code expects specific sheet names when extracting data from Excel files. However, since the sheet names in the newer files have changed, the code fails to find the expected sheet and throws an error.
To address this, you need to modify your custom function used to transform each file to ignore the sheet names and always select the first sheet (which is typically Sheet1 in Excel files), regardless of its name.
Assuming your custom function (#"Transform File from HAYDEN COs") looks something like the following:
m
Copy code
let
    TransformFile = (file) =>
    let
        Source = Excel.Workbook(file, null, true),
        AssessorSheet = Source{[Item="ASSESSOR OCCUPANCY RPT",Kind="Sheet"]}[Data]
    in
        AssessorSheet
in
    TransformFile

You'll need to change it so that it always selects the first sheet instead of looking for a sheet by name. Here's how you can adjust it:
m
Copy code
let
    TransformFile = (file) =>
    let
        Source = Excel.Workbook(file, null, true),
        FirstSheet = Source{0}[Data]  // Always select the first sheet
    in
        FirstSheet
in
    TransformFile

Here’s how you can integrate the updated function back into your main query:
m
Copy code
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

This change will make your query robust against changes in sheet names, as it will always process the first sheet from each Excel file. Let me know if you need more help with this or any other adjustments!
Darrell Wolfe · 15 minutes ago
Ah..... Ok ok ok..... I think I see it now... 



Darrell Wolfe · 13 minutes ago
Ok... I see it now. There is "Transform File from HAYDEN COs" fx built by the Power Query gui first, and then from that function, I got the HAYDEN COs table to use... let Source = (#"Sample File Parameter2" as binary) => let Source = Excel.Workbook(#"Sample File Parameter2", null, true), #"ASSESSOR OCCUPANCY RPT_Sheet" = Source{[Item="ASSESSOR OCCUPANCY RPT",Kind="Sheet"]}[Data] in #"ASSESSOR OCCUPANCY RPT_Sheet" in Source
Darrell Wolfe · 13 minutes ago
Thanks for sharing the detailed function. Since the function explicitly looks for a sheet named "ASSESSOR OCCUPANCY RPT," you'll need to modify it to always select the first sheet, irrespective of its name. This adjustment will prevent the error when the sheet names change in the future.
Here’s how you can modify the function to always select the first sheet:
m
Copy code
let
    Source = (#"Sample File Parameter2" as binary) => let
        Source = Excel.Workbook(#"Sample File Parameter2", null, true),
        FirstSheet = Source{0}[Data]  // Always select the first sheet
    in
        FirstSheet
in
    Source

This modification replaces the specific sheet selection with a generic selection of the first sheet in the workbook (Source{0}[Data]). By doing this, the function will always process the first sheet it finds, regardless of what it's called.
Now, integrate this updated function into your main query where you use "Transform File from HAYDEN COs", and your query should be able to handle files with varying sheet names without errors. Let me know if there's anything else you need help with!
Darrell Wolfe · 11 minutes ago
// REPLACE the Power Query fx "Transform File from HAYDEN COs"

```{m}

let
    Source = (#"Sample File Parameter2" as binary) => let
        Source = Excel.Workbook(#"Sample File Parameter2", null, true),
        #"ASSESSOR OCCUPANCY RPT_Sheet" = Source{[Item="ASSESSOR OCCUPANCY RPT",Kind="Sheet"]}[Data]
    in
        #"ASSESSOR OCCUPANCY RPT_Sheet"
in
    Source

```

// with 

```{m}

let
    Source = (#"Sample File Parameter2" as binary) => let
        Source = Excel.Workbook(#"Sample File Parameter2", null, true),
        FirstSheet = Source{0}[Data]  // Always select the first sheet
    in
        FirstSheet
in
    Source

```


// This eliminates the error looking for a particular sheet name. 
Darrell Wolfe · 10 minutes ago
// Same for Permits transformer 

```{m}
let
    Source = (#"Sample File Parameter1") =>
let
    Source = Excel.Workbook(#"Sample File Parameter1", null, true),
    FirstSheet = Source{0}[Data]
in
    FirstSheet
in
    Source
```
Darrell Wolfe · 9 minutes ago
Deleting the "extra" I made for diagnostic purposes and the file as it's no longer needed. Replacing the code and refreshing to see if this work.
Darrell Wolfe · 1 minute ago
Hayden Query now works all errors gone. Closing out this ticket but sharing it with the team so they know what kinds of things to look for. Long-term, we'll use Python, but Power Query will still be one of the tools we use for various reason for many years, I suspect, so this is good to save for future reference.


