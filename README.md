# learn-tableau
how to read logs
```bash
Get-Content 'C:\ProgramData\Tableau\Tableau Server\data\tabsvc\logs\tabadmincontroller\tabadmincontroller_node1-0.log' -Tail 200 | Select-String -Context 5 "2025-02-21 14:24:57"
```
