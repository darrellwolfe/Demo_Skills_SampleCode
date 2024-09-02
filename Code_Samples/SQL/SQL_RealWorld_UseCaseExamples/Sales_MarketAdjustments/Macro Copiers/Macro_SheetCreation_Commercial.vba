Sub CopySheetWithNewNames()
    Dim wb As Workbook
    Dim wbNames As Workbook
    Dim ws As Worksheet
    Dim wsNames As Worksheet
    Dim wsNew As Worksheet
    Dim i As Integer
    Dim lastRow As Long
    Dim pathNames As String
    
    ' Define workbook
    Set wb = ThisWorkbook
    
    ' Define the sheet you want to copy
    Set ws = wb.Sheets("Template")  ' Changed from an index to a sheet name
    
    ' Path to the workbook with the names
    pathNames = "S:\Common\Comptroller Tech\Reporting Tools\Reports (Market Adjustments)\MA_RefWorkbooks\GEO_ReferenceInformationTables_2023.xlsx"
    ' Change to the path of your workbook
    ' pathNames = "C:\Users\darre\OneDrive\Desktop\Business Intelligence (BI) Analyst-selected\Reports (Market Adjustments)\z.Development\Commercial\GEO_ReferenceInformationTables (2023).xlsx" '  Home Edition
        
    Set wbNames = Workbooks.Open(pathNames)
    
    ' Define the sheet with the names
    '  Set wsNames = wbNames.Sheets("District_Key")  ' Change to the correct sheet if it's not the first one
    Set wsNames = wbNames.Sheets("GEOCountsNEW") '  Home Edition


    ' Determine the last row in column A of wsNames
    lastRow = wsNames.Cells(wsNames.Rows.Count, "A").End(xlUp).Row
    
    ' Start the loop
    For i = 1 To lastRow
        ' Check if the tag in column A is "District 1"
        If wsNames.Cells(i, "A").Value = "Commercial" Then
            ' Create a new sheet and copy the content from the sheet named "1003"
            ws.Copy After:=wb.Sheets(wb.Sheets.Count)
            Set wsNew = ActiveSheet
            ' Name the new sheet after the cell value in column B
            wsNew.Name = wsNames.Cells(i, "C").Value
        End If
    Next i
    
    ' Close the workbook with the names
    wbNames.Close SaveChanges:=False
End Sub
