Sub CopyRowsByGeoCode()
    Dim sourceWorkbook As Workbook
    Dim sourceWorksheet As Worksheet
    Dim sourceLastRow As Long
    Dim geoCodeColumn As Long
    Dim geoCode As String
    Dim targetRow As Long
    Dim wsIndex As Integer
    Dim targetWorksheet As Worksheet


    ' Open source workbook
    Set sourceWorkbook = Workbooks.Open("S:\Common\Comptroller Tech\Reporting Tools\Reports (Market Adjustments)\MA_RefWorkbooks\MA_SALES_Comm_2023.xlsx")

    ' Home Edition
    ' Set sourceWorkbook = Workbooks.Open("C:\Users\darre\OneDrive\Desktop\Business Intelligence (BI) Analyst-selected\Reports (Market Adjustments)\z.Development\Commercial\Sales Only v1 2023-11-01 (draft test version).xlsx")
   
    ' Set source worksheet
    Set sourceWorksheet = sourceWorkbook.Sheets("MA_COMMERCIAL")

    ' Specify column with GEO code
    ' For example, if the GEO code is in the first column (column C is the 3rd column)
    geoCodeColumn = 3

    sourceLastRow = sourceWorksheet.Cells(sourceWorksheet.Rows.Count, geoCodeColumn).End(xlUp).Row

    ' Find the start worksheet index
    ' Geo 1 starts commercial GEOs
    Dim startWsIndex As Integer
    For wsIndex = 1 To ThisWorkbook.Sheets.Count
        If ThisWorkbook.Sheets(wsIndex).Name = "1" Then
            startWsIndex = wsIndex
            Exit For
        End If
    Next wsIndex

    ' Loop through each worksheet starting from "1"
    For wsIndex = startWsIndex To ThisWorkbook.Sheets.Count
        Set targetWorksheet = ThisWorkbook.Sheets(wsIndex)

        ' Skip if worksheet is hidden
        If targetWorksheet.Visible <> xlSheetVisible Then
            GoTo NextSheet
        End If

        ' Set target row
        targetRow = 29

        ' Loop through source data
        For i = 2 To sourceLastRow
            geoCode = sourceWorksheet.Cells(i, geoCodeColumn).Value

            ' Check if GEO codes match
            If targetWorksheet.Cells(1, 2).Value = geoCode Then
                ' Copy and paste values
                ' C is GEO after District and SubDistrict
                
                sourceWorksheet.Range("C" & i & ":AU" & i).Copy
                targetWorksheet.Cells(targetRow, 1).PasteSpecial xlPasteValues
                sourceWorksheet.Cells(i, 48).Copy
                targetWorksheet.Cells(targetRow, 59).PasteSpecial xlPasteValues
                sourceWorksheet.Cells(i, 49).Copy
                targetWorksheet.Cells(targetRow, 60).PasteSpecial xlPasteValues

                ' Increment target row
                targetRow = targetRow + 1
            End If
        Next i

        ' Clear clipboard
        Application.CutCopyMode = False

NextSheet:
    Next wsIndex

    ' Close source workbook without saving changes
    sourceWorkbook.Close SaveChanges:=False
End Sub

