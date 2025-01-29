Sub CopyRowsByGeoCode()
    Dim sourceWorkbook As Workbook
    Dim sourceWorksheet As Worksheet
    Dim sourceLastRow As Long
    Dim geoCodeColumn As Long
    Dim geoCode As String
    Dim targetRow As Long ' Variable to keep track of the next available row in the target worksheet
    
    ' Change the file path and sheet name for the source workbook
    Set sourceWorkbook = Workbooks.Open("S:\Common\Comptroller Tech\Reporting Tools\Reports (Market Adjustments)\MA_DatabaseQuery\MA_DatabaseQuery_RESIDENTIAL_SALES_2022,2023.xlsx")
    
    ' Change "MA_RESIDENTIAL" to the name of the sheet containing the sales data in the source workbook
    Set sourceWorksheet = sourceWorkbook.Sheets("MA_RESIDENTIAL")
    
    ' Change "GEO_CODE_COLUMN" to the appropriate column index containing the GEO code in the source workbook
    geoCodeColumn = 1 ' For example, if the GEO code is in the first column (column A)
    
    sourceLastRow = sourceWorksheet.Cells(sourceWorksheet.Rows.Count, geoCodeColumn).End(xlUp).Row
    
    ' Set the target worksheet as the second worksheet in the workbook
    Dim targetWorksheet As Worksheet
    Set targetWorksheet = ThisWorkbook.Sheets(2) ' 2 represents the second worksheet in the workbook
    
    ' Set the target row to Cell A28 in the target worksheet
    targetRow = 28 ' Starting row in the target worksheet
    
    ' Assuming your sales data starts from row 2 (excluding headers) in the source workbook, change this if your data starts from a different row
    For i = 2 To sourceLastRow
        geoCode = sourceWorksheet.Cells(i, geoCodeColumn).Value
        
        ' Check if the GEO code in the source workbook matches the GEO code in the target workbook
        If targetWorksheet.Cells(1, 2).Value = geoCode Then ' Change "2" to the column index where the GEO code is located in cell B1
            ' Copy the values from columns A to AG (columns 1 to 33) from the source worksheet to the target worksheet
            sourceWorksheet.Range("A" & i & ":AG" & i).Copy
            targetWorksheet.Cells(targetRow, 1).PasteSpecial xlPasteValues ' Paste only values
            
            ' Copy the value from column AH from the source worksheet to column AY in the target worksheet
            sourceWorksheet.Cells(i, 34).Copy ' 34 represents column AH
            targetWorksheet.Cells(targetRow, 50).PasteSpecial xlPasteValues ' 51 represents column AY
            
            targetRow = targetRow + 1 ' Move to the next available row in the target worksheet
        End If
    Next i
    
    Application.CutCopyMode = False ' Clear the copy mode
    
    ' Close the source workbook without saving changes (you can save if needed)
    sourceWorkbook.Close SaveChanges:=False
End Sub
