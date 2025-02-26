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
    Set sourceWorkbook = Workbooks.Open("S:\Common\Comptroller Tech\Reporting Tools\Reports (Market Adjustments)\MA_RefWorkbooks\MA_SALES_MHReg_MHFloat_2023.xlsx")

    ' Set source worksheet   !!!!!!  PICK ONE !!!!!!
    Set sourceWorksheet = sourceWorkbook.Sheets("MH_565s")
    ' Set sourceWorksheet = sourceWorkbook.Sheets("MH_FloatRes")


    ' Specify column with GEO code
    ' For example, if the GEO code is in the first column (column C is the 3rd column after A-District and B-Sublass)
    geoCodeColumn = 3

    sourceLastRow = sourceWorksheet.Cells(sourceWorksheet.Rows.Count, geoCodeColumn).End(xlUp).Row

    ' Find the start worksheet index ---Will change for MH after we seperate stick builts and float homes
    ' Geo 1 starts commercial GEOs
    Dim startWsIndex As Integer
    For wsIndex = 1 To ThisWorkbook.Sheets.Count
    
    ' !!!!!!! CHANGE THE GEO BASED ON WHICH SALES !!!!!!!!!
        If ThisWorkbook.Sheets(wsIndex).Name = "9100" Then
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
                
                ' !!!! CHECK BOTH THE SOURCE AND DESTINATION !!!!!!!
                
                sourceWorksheet.Range("C" & i & ":AJ" & i).Copy
                targetWorksheet.Cells(targetRow, 1).PasteSpecial xlPasteValues
                sourceWorksheet.Cells(i, 37).Copy
                targetWorksheet.Cells(targetRow, 45).PasteSpecial xlPasteValues
                sourceWorksheet.Cells(i, 38).Copy
                targetWorksheet.Cells(targetRow, 46).PasteSpecial xlPasteValues

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


