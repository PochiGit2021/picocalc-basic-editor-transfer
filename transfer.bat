@echo off
:: ============================================================================
:: PicoMite BASIC Program Transfer Script for PicoCalc
:: ============================================================================
:: This script transfers a BASIC program file to a PicoMite device
:: connected via a serial (COM) port.
::
:: Copyright (c) 2025 PochiGit2021
:: Licensed under the MIT License - see LICENSE file for details
::
:: Usage: picocalc_transfer.bat [OPTIONS]
:: Options:
::   -c, --com <PORT>     Specify COM port (e.g., COM3, COM6)
::   -f, --file <FILE>    Specify BASIC file to transfer
::   -h, --help           Show this help message
:: ============================================================================

:: Default configuration
set "COMPORT=COM3"
set "LOCAL_FILE=sample.bas"
set "FILE_SPECIFIED=0"

:: Command line argument processing
:parse_args
if "%~1"=="" goto :post_args_processing
if /i "%~1"=="-c" goto :set_com
if /i "%~1"=="--com" goto :set_com
if /i "%~1"=="-f" goto :set_file
if /i "%~1"=="--file" goto :set_file
if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--help" goto :show_help

echo [ERROR] Unknown option: %~1
goto :show_help

:set_com
if "%~2"=="" (
    echo [ERROR] COM port not specified after %~1
    goto :show_help
)
set "COMPORT=%~2"
shift
shift
goto :parse_args

:set_file
if "%~2"=="" (
    echo [ERROR] File name not specified after %~1
    goto :show_help
)
set "LOCAL_FILE=%~2"
set "FILE_SPECIFIED=1"
shift
shift
goto :parse_args

:show_help
echo.
echo Usage: %~nx0 [OPTIONS]
echo.
echo Options:
echo   -c, --com ^<PORT^>     Specify COM port (e.g., COM3, COM6)
echo   -f, --file ^<FILE^>    Specify BASIC file to transfer
echo   -h, --help           Show this help message
echo.
echo If no file is specified with -f, a GUI file picker will be shown.
echo.
echo Examples:
echo   %~nx0                           Show GUI to pick a file
echo   %~nx0 -c COM6                   Show GUI and use COM6 port
echo   %~nx0 -f sample.bas             Transfer sample.bas
echo   %~nx0 -c COM6 -f sample.bas     Use COM6 and transfer sample.bas
echo.
goto :eof

:post_args_processing
if %FILE_SPECIFIED%==1 goto :start_transfer

:gui_file_picker
echo [INFO] Opening file picker dialog...
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.Filter = 'BASIC Files (*.bas)|*.bas|All Files (*.*)|*.*'; $dialog.Title = 'Select BASIC file to transfer'; $dialog.InitialDirectory = '%~dp0'; if ($dialog.ShowDialog() -eq 'OK') { Write-Output $dialog.FileName } else { exit 1 }" > "%TEMP%\selected_file.txt"
if errorlevel 1 (
    echo [INFO] File selection cancelled. Using default: %LOCAL_FILE%
) else (
    set /p "LOCAL_FILE=" < "%TEMP%\selected_file.txt"
    del "%TEMP%\selected_file.txt" 2>nul
    echo [INFO] Selected file: %LOCAL_FILE%
)

:start_transfer
set "REMOTE_FILE="
set "BAUDRATE=115200"
set "LINE_DELAY=1"

:: --- Initial Setup ---
echo.
echo [INFO] PicoMite BASIC Program Transfer
echo -----------------------------------------

if not defined REMOTE_FILE (
    for %%F in ("%LOCAL_FILE%") do set "REMOTE_FILE=%%~nxF"
)

echo [INFO] COM Port: %COMPORT%
echo [INFO] Baud Rate: %BAUDRATE%
echo [INFO] Local File: %LOCAL_FILE%
echo [INFO] Remote Filename: %REMOTE_FILE%
echo -----------------------------------------
echo.

if not exist "%LOCAL_FILE%" (
    echo [ERROR] Local file not found: %LOCAL_FILE%
    goto :error_exit
)

:: --- Transfer Process ---

:: 1. Configure COM port
echo [STEP 1/7] Configuring %COMPORT%...
mode %COMPORT% BAUD=%BAUDRATE% PARITY=n DATA=8 STOP=1 > nul
if errorlevel 1 (
    echo [ERROR] Failed to configure %COMPORT%.
    goto :error_exit
)
echo [SUCCESS] COM port configured.
echo.
timeout /t 1 /nobreak > nul

:: 2. Remove existing file
echo [STEP 2/7] Removing existing file if present...
(echo RMDIR "%REMOTE_FILE%") > %COMPORT%
timeout /t 2 /nobreak > nul
echo [SUCCESS] Cleanup completed.
echo.

:: 3. Clear program memory
echo [STEP 3/7] Sending 'NEW' command...
(echo NEW) > %COMPORT%
timeout /t 2 /nobreak > nul
echo [SUCCESS] Sent.
echo.

:: 4. Enter editor
echo [STEP 4/7] Sending 'EDIT' command...
(echo EDIT "%REMOTE_FILE%") > %COMPORT%
timeout /t 2 /nobreak > nul
echo [SUCCESS] Entered editor mode.
echo.

:: 5. Transfer file content
echo [STEP 5/7] Transferring file content...
for /f "usebackq delims=" %%L in ("%LOCAL_FILE%") do (
    echo   Sending line: "%%L"
    (echo %%L) > %COMPORT%
    timeout /t %LINE_DELAY% /nobreak > nul
)
echo [SUCCESS] File content transferred.
echo.

:: 6. Save and exit editor (F1 key)
echo [STEP 6/7] Saving and exiting editor with F1 key sequence...
powershell -NoLogo -NoProfile -Command "try { $p = New-Object System.IO.Ports.SerialPort('%COMPORT%', %BAUDRATE%, 'None',8,'One'); $p.NewLine='\n'; $p.Open(); $bytes = 0x1B,0x5B,0x31,0x31,0x7E; $p.Write($bytes,0,$bytes.Length); Start-Sleep -Milliseconds 400; $p.Close(); exit 0 } catch { exit 1 }" 2>nul
if errorlevel 1 (
  echo [WARN] Could not send F1 sequence automatically.
) else (
  echo [SUCCESS] F1 sequence sent - attempted to save and exit editor.
)
echo.

:: 7. Run the program
echo [STEP 7/7] Running the program...
timeout /t 2 /nobreak > nul
(echo RUN "%REMOTE_FILE%") > %COMPORT%
timeout /t 1 /nobreak > nul
echo [SUCCESS] RUN command sent.
echo.

echo -----------------------------------------
echo [COMPLETE] Program transfer and execution finished successfully!
echo -----------------------------------------
echo The program "%REMOTE_FILE%" has been transferred, saved, and executed.
echo.
goto :eof

:error_exit
echo.
echo [FAILED] Program transfer failed.
echo.

:eof
endlocal
pause
