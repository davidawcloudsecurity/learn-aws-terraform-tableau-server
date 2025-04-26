@echo off
setlocal

:: Step 1: Get current date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%I in ('wmic os get LocalDateTime /value') do set dt=%%I
set "year=%dt:~0,4%"
set "month=%dt:~4,2%"
set "day=%dt:~6,2%"
set "today=%year%-%month%-%day%"

:: Step 2: Set file name with date
set "FILENAME=bootstrap_%today%.json"

:: Step 3: Generate bootstrap file
tsm topology nodes get-bootstrap-file --file "c:\temp\%FILENAME%"

echo File created: %FILENAME%
endlocal
