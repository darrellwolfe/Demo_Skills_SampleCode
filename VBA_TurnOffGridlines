Sub RemoveGridlines()
    Dim ws As Worksheet

    ' Turn off gridlines for each sheet
    For Each ws In ThisWorkbook.Worksheets
        ws.Activate
        ActiveWindow.DisplayGridlines = False
    Next ws

    ' Optional: Go back to the first sheet if needed
    ThisWorkbook.Worksheets(1).Activate
End Sub

' Assign the hotkey (Ctrl+Shift+G) to the RemoveGridlines subroutine
Sub SetHotkey()
    Application.OnKey "^+g", "RemoveGridlines" ' "^" stands for Ctrl, "+" stands for Shift
End Sub

