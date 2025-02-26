Sub DarnSplitScreens()
    Dim ws As Worksheet

    ' Loop through each worksheet in the workbook
    For Each ws In ThisWorkbook.Worksheets
        ws.Activate ' Activate the current worksheet
        With ActiveWindow
            .SplitColumn = 0
            .SplitRow = 0
        End With
    Next ws

    ' Optional: Activate the first sheet after finishing
    ThisWorkbook.Worksheets(1).Activate
End Sub
