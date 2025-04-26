@echo off
echo Uninstall TSM
cd "C:\Program Files\Tableau\Tableau Server\temp"
.\tableau-server-obliterate.cmd -y -y -y && pause
