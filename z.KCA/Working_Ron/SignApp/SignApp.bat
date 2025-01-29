@echo off
setlocal EnableDelayedExpansion

:: Configuration
set "TOOLS_DIR=%~dp0"
set "SIGNER_SCRIPT=%TOOLS_DIR%SignApp.py"
:: Check if Python is available
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Python is not available in PATH
    pause
    exit /b 1
)

:: Display menu
:menu
cls
echo Kootenai County Code Signing Tool
echo ================================
echo.
echo Select an application to sign:
echo 1. TimeTracker
echo 2. Other Application (Custom)
echo 3. Help
echo 4. Exit
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto sign_timetracker
if "%choice%"=="2" goto sign_custom
if "%choice%"=="3" goto show_help
if "%choice%"=="4" goto end

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto menu

:sign_timetracker
cls
echo Signing TimeTracker
echo ==================
echo.

:: Try to locate TimeTracker directory
set "TIMETRACKER_DIR=%TOOLS_DIR%..\TimeTracker"
if not exist "%TIMETRACKER_DIR%" (
    echo Error: TimeTracker directory not found
    echo Expected path: %TIMETRACKER_DIR%
    pause
    goto menu
)

:: Try to locate certificate
set "CERT_PATH=%TIMETRACKER_DIR%\TimeTrackerCert.pfx"
if not exist "%CERT_PATH%" (
    echo Error: TimeTracker certificate not found
    echo Expected path: %CERT_PATH%
    pause
    goto menu
)

:: Sign TimeTracker
python "%SIGNER_SCRIPT%" --exe "%TIMETRACKER_DIR%\dist" --cert "%CERT_PATH%" --pattern "TimeTracker*.exe" --desc "Kootenai County TimeTracker"
pause
goto menu

:sign_custom
cls
echo Sign Custom Application
echo ======================
echo.

:: Get executable path
set /p exe_path="Enter path to executable or directory: "
if not exist "%exe_path%" (
    echo Error: Path does not exist
    pause
    goto menu
)

:: Get certificate path
set /p cert_path="Enter path to certificate (.pfx): "
if not exist "%cert_path%" (
    echo Error: Certificate not found
    pause
    goto menu
)

:: Get optional parameters
set /p pattern="Enter file pattern (optional, press Enter for *.exe): "
if "!pattern!"=="" set "pattern=*.exe"

set /p description="Enter signature description (optional, press Enter to skip): "

:: Build command
set "cmd=python "%SIGNER_SCRIPT%" --exe "%exe_path%" --cert "%cert_path%" --pattern "%pattern%""
if not "!description!"=="" set "cmd=!cmd! --desc "%description%""

:: Execute
%cmd%
pause
goto menu

:show_help
cls
echo Code Signing Help
echo ================
echo.
echo This tool helps sign Windows executables with digital certificates.
echo.
echo Options:
echo 1. TimeTracker - Automatically signs the TimeTracker application
echo    - Looks for TimeTracker in the standard location
echo    - Uses the TimeTracker certificate
echo.
echo 2. Other Application - Sign any executable
echo    - Specify the executable path
echo    - Specify the certificate path
echo    - Optional file pattern for multiple executables
echo    - Optional signature description
echo.
echo Requirements:
echo - Windows SDK ^(for signtool.exe^)
echo - Valid code signing certificate ^(.pfx file^)
echo - Python 3.6+
echo.
echo Common Issues:
echo - "signtool not found" - Install Windows SDK
echo - "certificate not found" - Check certificate path
echo - "invalid password" - Make sure certificate password is correct
echo.
echo For more detailed help, run:
echo python code_signer.py --help
echo.
pause
goto menu

:end
echo.
echo Goodbye!
exit /b 0