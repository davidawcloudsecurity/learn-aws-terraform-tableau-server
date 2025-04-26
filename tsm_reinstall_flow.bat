@echo off

echo Uninstalling flowprocessor...
cd "c:\ProgramData\Tableau\Tableau Server\data\tabsvc\services\flowprocessor_0.20242.24.1112.0335"

tsm stop && .\uninstall.cmd && .\install.cmd && tsm start && pause
