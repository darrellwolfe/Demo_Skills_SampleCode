#Requires -Version 5.0

<#
.SYNOPSIS
    Wrapper for the KC Code Signing Tool
.DESCRIPTION
    Interactive wrapper for signing Windows executables with digital certificates
.NOTES
    Author: Ron Mason III
    Version: 1.0.0
#>

# Configuration
$TOOLS_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SIGNER_SCRIPT = Join-Path $TOOLS_DIR "SignApp.py"

# Check Python
try {
    python --version | Out-Null
}
catch {
    Write-Host "Error: Python is not available in PATH" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

function Show-Menu {
    Clear-Host
    Write-Host "Kootenai County Code Signing Tool" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host
    Write-Host "Select an application to sign:"
    Write-Host "1. TimeTracker"
    Write-Host "2. Other Application (Custom)"
    Write-Host "3. Help"
    Write-Host "4. Exit"
    Write-Host
}

function Sign-TimeTracker {
    Clear-Host
    Write-Host "Signing TimeTracker" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host

    # Try to locate TimeTracker directory
    $TIMETRACKER_DIR = Join-Path $TOOLS_DIR "\TimeTracker"
    if (-not (Test-Path $TIMETRACKER_DIR)) {
        Write-Host "Error: TimeTracker directory not found" -ForegroundColor Red
        Write-Host "Expected path: $TIMETRACKER_DIR"
        Read-Host "Press Enter to continue"
        return
    }

    # Try to locate certificate
    $CERT_PATH = Join-Path $TIMETRACKER_DIR "TimeTrackerCert.pfx"
    if (-not (Test-Path $CERT_PATH)) {
        Write-Host "Error: TimeTracker certificate not found" -ForegroundColor Red
        Write-Host "Expected path: $CERT_PATH"
        Read-Host "Press Enter to continue"
        return
    }

    # Sign TimeTracker
    python $SIGNER_SCRIPT --exe "$TIMETRACKER_DIR\dist" --cert $CERT_PATH --pattern "TimeTracker*.exe" --desc "Kootenai County TimeTracker"
    Read-Host "Press Enter to continue"
}

function Sign-CustomApp {
    Clear-Host
    Write-Host "Sign Custom Application" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host

    # Get executable path
    $exe_path = Read-Host "Enter path to executable or directory"
    if (-not (Test-Path $exe_path)) {
        Write-Host "Error: Path does not exist" -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }

    # Get certificate path
    $cert_path = Read-Host "Enter path to certificate (.pfx)"
    if (-not (Test-Path $cert_path)) {
        Write-Host "Error: Certificate not found" -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }

    # Get optional parameters
    $pattern = Read-Host "Enter file pattern (optional, press Enter for *.exe)"
    if ([string]::IsNullOrWhiteSpace($pattern)) { $pattern = "*.exe" }

    $description = Read-Host "Enter signature description (optional, press Enter to skip)"

    # Build command
    $cmd = "python `"$SIGNER_SCRIPT`" --exe `"$exe_path`" --cert `"$cert_path`" --pattern `"$pattern`""
    if (-not [string]::IsNullOrWhiteSpace($description)) {
        $cmd += " --desc `"$description`""
    }

    # Execute
    Invoke-Expression $cmd
    Read-Host "Press Enter to continue"
}

function Show-Help {
    Clear-Host
    Write-Host "Code Signing Help" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor Cyan
    Write-Host
    @"
This tool helps sign Windows executables with digital certificates.

Options:
1. TimeTracker - Automatically signs the TimeTracker application
   - Looks for TimeTracker in the standard location
   - Uses the TimeTracker certificate

2. Other Application - Sign any executable
   - Specify the executable path
   - Specify the certificate path
   - Optional file pattern for multiple executables
   - Optional signature description

Requirements:
- Windows SDK (for signtool.exe)
- Valid code signing certificate (.pfx file)
- Python 3.6+

Common Issues:
- "signtool not found" - Install Windows SDK
- "certificate not found" - Check certificate path
- "invalid password" - Make sure certificate password is correct

For more detailed help, run:
python code_signer.py --help
"@ | Write-Host
    Read-Host "Press Enter to continue"
}

# Main loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-4)"
    
    switch ($choice) {
        "1" { Sign-TimeTracker }
        "2" { Sign-CustomApp }
        "3" { Show-Help }
        "4" { 
            Write-Host "`nGoodbye!" -ForegroundColor Cyan
            exit 0 
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}