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

tsm topology set-process -n node2 -pr backgrounder -c 4
tsm topology set-process -n node2 -pr gateway -c 1
tsm topology set-process -n node2 -pr flowprocessor -c 1
tsm topology set-process -n node2 -pr floweditor  -c 1
tsm topology set-process -n node2 -r flows
tsm topology set-node-role -n node1 -r no-flows
tsm pending-changes apply

echo File created: %FILENAME%
endlocal
