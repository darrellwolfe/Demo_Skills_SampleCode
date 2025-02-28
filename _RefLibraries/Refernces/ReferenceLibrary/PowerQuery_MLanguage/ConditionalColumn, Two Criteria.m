--Power Query, Add Conditional Column
https://support.microsoft.com/en-us/office/add-a-conditional-column-power-query-f2422ed1-f565-4e64-ba3f-4f8d4616254e

--NOTE: Be sure that your date is formatted as a date and amount as an number (neither as ABC/Text) in a step prior to adding these steps

--Full Syntax
let
    Source = YourTable,
    AddCustom = Table.AddColumn(Source, "Status", each if [Year Acquired] >= #date(2013, 1, 1) and [Reported Cost Value] <= 3000 then "Exempt" else "Taxable")
in
    AddCustom


--What you put into the Add Conditional Column Builder

if [Year Acquired] >= #date(2013, 1, 1) 
and [Reported Cost Value] <= 3000 
then "Exempt" 
else "Taxable"