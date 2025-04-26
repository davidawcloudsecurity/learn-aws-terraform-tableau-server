@echo off
setlocal enabledelayedexpansion

:: Prompt for user choice
echo Select an option:
echo 1. Generate bootstrap file
echo 2. Add node to Tableau Server
set /p choice="Enter your choice (1 or 2): "

:: Get current date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%I in ('wmic os get LocalDateTime /value') do set dt=%%I
set "year=%dt:~0,4%"
set "month=%dt:~4,2%"
set "day=%dt:~6,2%"
set "today=%year%-%month%-%day%"
set "FILENAME=bootstrap_%today%.json"

:: Handle choices
if "%choice%"=="1" (
    echo Generating bootstrap file...
    tsm topology nodes get-bootstrap-file --file "C:\temp\%FILENAME%"
    echo File created: C:\temp\%FILENAME%
) else if "%choice%"=="2" (
    set /p exePath="Enter the full path to TableauServer installer (e.g. C:\Installers\TableauServer-64bit-2024-2-5.exe): "

    if exist "%exePath%" (
        echo Running Tableau Server installer from:
        echo %exePath%
        "%exePath%" /silent ACCEPTEULA=1 EMBEDDEDCREDENTIAL=1 BOOTSTRAPFILE="C:\temp\%FILENAME%"
        pause
        tsm topology list-nodes -v
    ) else (
        echo ERROR: File not found at %exePath%
    )
) else (
    echo Invalid choice. Exiting.
)

endlocal
