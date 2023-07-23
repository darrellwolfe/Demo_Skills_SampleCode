//Set IGNORESPACES to 1 to force script interpreter to ignore spaces.
//If using IGNORESPACES quote strings in {" ... "}
//Let>IGNORESPACES=1

' Launch web browser and navigate to Box.com
ChromeStart>strSessionID

Wait 1000

Browser.NewBrowser()
Browser.Navigate("https://box.com")

' Wait for the sign-in page to load
Browser.WaitPageLoad("Box | Login")

' Enter your credentials and sign in
Browser.SetText("[name='login']", "asrcomptechs@kcgov.us")
Browser.SetText("[name='password']", "TableDucky!2023")
Browser.ClickElement("[type='submit']")

' Wait for the user dashboard to load
Browser.WaitPageLoad("Box | Secure File Sharing, Storage, and Collaboration")

' Navigate to the folder you want to download
Browser.Navigate("https://app.box.com/folder/204096053267?s=9f0rxywh09td5ltaj4buv49lorreb0oo")

' Wait for the folder contents to load
Browser.WaitElement("a[data-item-id]")

' Get a list of all items in the folder
Dim items As Variant
items = Browser.GetElements("a[data-item-id]")

' Create a new folder on your system to save the downloaded content
File.CreateDirectory("C:\Path\to\your\destination\folder")

' Loop through the items and download each one
For Each item In items
    Dim itemId As String
    itemId = Browser.GetAttribute(item, "data-item-id")
    
    ' Click the item to open its context menu
    Browser.ClickElement(item, MouseButtonRight)
    
    ' Wait for the context menu to open
    Browser.WaitElement("#ItemContextMenu_" & itemId)
    
    ' Click the "Download" option in the context menu
    Browser.ClickElement("#ItemContextMenu_" & itemId & " a[data-action='download']")
    
    ' Wait for the download to complete
    File.WaitFileDownload("S:\Common\Comptroller Tech\Reporting Tools\Reports (Permits - Import)\Permits\CDA" & itemId & ".zip")
Next

' You may need to extract the downloaded files if they are zipped
' You can use a tool like 7-Zip to automate the extraction process

' Perform any additional operations on the downloaded content if needed

' Close the browser
Browser.CloseBrowser()
