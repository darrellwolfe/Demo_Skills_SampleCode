import os
import json
import subprocess
from io import BytesIO
from datetime import datetime, timedelta

def run_powershell_script(script):
    with open("exchange_script.ps1", "w") as f:
        f.write(script)
    
    result = subprocess.run(["powershell", "-File", "exchange_script.ps1"], capture_output=True, text=True)
    print("PowerShell Output:")
    print(result.stdout)
    print("PowerShell Errors:")
    print(result.stderr)
    if result.returncode != 0:
        print(f"Error executing PowerShell script. Return code: {result.returncode}")
        return None
    return result.stdout.strip()

def main():
    username = input("Enter your email: ")
    
    save_dir = os.path.join(os.path.expanduser("~"), "Documents", "Permits", "IDL Permits")
    os.makedirs(save_dir, exist_ok=True)

    print(f"Attempting to login with username: {username}")

    ps_script = f"""
    $ErrorActionPreference = "Stop"
    try {{
        Write-Host "Importing ExchangeOnlineManagement module..."
        Import-Module ExchangeOnlineManagement
        
        Write-Host "Connecting to Exchange Online..."
        Connect-ExchangeOnline -UserPrincipalName {username} -ShowProgress $true

        Write-Host "Checking connection..."
        $connectionInfo = Get-ConnectionInformation
        if ($null -eq $connectionInfo -or $connectionInfo.TokenStatus -ne "Active") {{
            throw "Failed to connect to Exchange Online. Please check your credentials and try again."
        }}

        Write-Host "Connection successful. Retrieving mailbox..."
        $mailbox = Get-EXOMailbox -Identity {username}
        Write-Host "Mailbox retrieved successfully."

        Write-Host "Retrieving mailbox folder statistics..."
        $folderStats = Get-EXOMailboxFolderStatistics -Identity $mailbox.Identity -IncludeOldestAndNewestItems -FolderScope Inbox | Select-Object -First 1
        Write-Host "Folder statistics retrieved successfully."

        Write-Host "Retrieving messages..."
        $startDate = (Get-Date).AddDays(-10)
        $endDate = Get-Date
        $messages = $folderStats | ForEach-Object {{
            $folder = $_
            Write-Host "Processing folder: $($folder.FolderPath)"
            $items = Get-EXOMailboxFolderStatistics -Identity $mailbox.Identity -FolderScope Inbox |
                Where-Object {{ $_.FolderPath -eq $folder.FolderPath }} |
                Select-Object -ExpandProperty NewestItems
            $items | Where-Object {{ $_.ReceivedDateTime -ge $startDate -and $_.ReceivedDateTime -le $endDate }} |
                Where-Object {{ $_.From -match 'sramos@kcgov.us|drgossselin@kcgov.us' }} |
                Select-Object Subject, From, To, ReceivedDateTime, HasAttachments
        }}

        Write-Host "Messages retrieved successfully."
        $messagesJson = $messages | ConvertTo-Json -Depth 4
        Write-Output $messagesJson
    }}
    catch {{
        Write-Error "An error occurred: $_"
        exit 1
    }}
    finally {{
        Write-Host "Disconnecting from Exchange Online..."
        Disconnect-ExchangeOnline -Confirm:$false
    }}
    """

    try:
        output = run_powershell_script(ps_script)
        if output:
            lines = output.split('\n')
            json_start = next((i for i, line in enumerate(lines) if line.strip().startswith('[')), None)
            if json_start is not None:
                messages_json = '\n'.join(lines[json_start:])
                messages = json.loads(messages_json)
                for message in messages:
                    print(f"Subject: {message['Subject']}")
                    print(f"From: {message['From']}")
                    print(f"To: {message['To']}")
                    print(f"Received: {message['ReceivedDateTime']}")
                    print(f"Has Attachments: {message['HasAttachments']}")
                    print("---")
            else:
                print("No messages found in the output.")
        else:
            print("No output received from PowerShell script.")

    except Exception as e:
        print(f"An error occurred in Python script: {str(e)}")

if __name__ == "__main__":07
    main()
