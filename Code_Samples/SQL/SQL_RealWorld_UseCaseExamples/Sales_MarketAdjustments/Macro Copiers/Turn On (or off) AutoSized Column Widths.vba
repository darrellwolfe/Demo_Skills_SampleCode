

Right click the TEMPLATE Tab
View Code
In the code, if AutoFit is turned on, it will look like this:

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
Columns.AutoFit
End Sub

If AutoFit is not on, it will look like this:
Private Sub Worksheet_SelectionChange(ByVal Target As Range)

End Sub
