@echo off
echo Uninstalling administrative services...
cd "c:\Program Files\Tableau\Tableau Server\packages\scripts.20242.24.1112.0335"

tsm stop && ".\stop-administrative-services.cmd" && ".\start-administrative-services.cmd" && tsm start && pause
