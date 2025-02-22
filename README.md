# learn-tableau
how to read logs
```bash
Get-Content 'C:\ProgramData\Tableau\Tableau Server\data\tabsvc\logs\tabadmincontroller\tabadmincontroller_node1-0.log' -Tail 200 | Select-String -Context 5 "2025-02-21 14:24:57"
```
Here's the updated version with the path hardcoded in the script:
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.5
Variable to pause
```powershell
# Real-time log monitor with context display
$Path = "C:\ProgramData\Tableau\Tableau Server\data\tabsvc\logs"  # Modified to your actual path
$FilePattern = "*.log"               # Modified to catch all logs
$PollInterval = 10000               # Milliseconds between checks (10 seconds)
$ContextLines = 3                    # Number of lines before/after to show
$SearchTerm = "ERROR"               # Term to search for
$PauseOnMatch = 5                   # Seconds to pause when match is found
$Debug = $false                     # Enable debug output

# Function to process new content
function Process-NewContent {
    param (
        [string]$FilePath,
        [int]$StartLine,
        [int]$ContextLines
    )
    
    try {
        $content = Get-Content -Path $FilePath -Raw | ForEach-Object {$_ -split "`r`n"}
        $totalLines = $content.Count
        
        if ($totalLines -gt $StartLine) {
            $newLines = $content[$StartLine..($totalLines - 1)]
            $currentLine = $StartLine
            
            foreach ($line in $newLines) {
                if ($line -cmatch $SearchTerm) {
                    Write-Host "`n==================== MATCH FOUND ====================`n" -ForegroundColor Cyan
                    Write-Host "File: $FilePath" -ForegroundColor Green
                    Write-Host "Line: $($currentLine + 1)" -ForegroundColor Green
                    Write-Host "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Green
                    Write-Host "Context:" -ForegroundColor Cyan
                    
                    # Show lines before the match
                    $startContext = [Math]::Max(0, $currentLine - $ContextLines)
                    for ($i = $startContext; $i -lt $currentLine; $i++) {
                        Write-Host "  $($i + 1): $($content[$i])" -ForegroundColor DarkGray
                    }
                    
                    # Show the matched line
                    Write-Host "→ $($currentLine + 1): $line" -ForegroundColor Yellow
                    
                    # Show lines after the match
                    $endContext = [Math]::Min($totalLines - 1, $currentLine + $ContextLines)
                    for ($i = $currentLine + 1; $i -le $endContext; $i++) {
                        Write-Host "  $($i + 1): $($content[$i])" -ForegroundColor DarkGray
                    }
                    
                    Write-Host "`nPausing for $PauseOnMatch seconds..." -ForegroundColor Gray
                    Start-Sleep -Seconds $PauseOnMatch
                    Write-Host "Continuing scan..." -ForegroundColor Gray
                }
                $currentLine++
            }
            return $totalLines
        }
        return $StartLine
    }
    catch {
        Write-Warning "Error in Process-NewContent: $($_.Exception.Message)"
        return $StartLine
    }
}

try {
    if (-not (Test-Path $Path)) {
        throw "Path '$Path' does not exist!"
    }

    $filePositions = @{}
    Clear-Host
    Write-Host "`n=== Log Monitor Settings ===" -ForegroundColor Cyan
    Write-Host "Path: $Path" -ForegroundColor White
    Write-Host "Pattern: $FilePattern" -ForegroundColor White
    Write-Host "Search Term: $SearchTerm" -ForegroundColor White
    Write-Host "Context Lines: $ContextLines before and after" -ForegroundColor White
    Write-Host "Pause Duration: $PauseOnMatch seconds" -ForegroundColor White
    Write-Host "Poll Interval: $($PollInterval/1000) seconds" -ForegroundColor White
    Write-Host "=========================`n" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop monitoring`n" -ForegroundColor Yellow

    while ($true) {
        $currentFiles = Get-ChildItem -Path $Path -Filter $FilePattern -Recurse
        
        foreach ($file in $currentFiles) {
            if (-not $filePositions.ContainsKey($file.FullName)) {
                $filePositions[$file.FullName] = 0  # Start from beginning
                Write-Host "Now monitoring: $($file.FullName)" -ForegroundColor Green
            }
        }
        
        foreach ($file in $filePositions.Keys.Clone()) {
            if (Test-Path $file) {
                $newPosition = Process-NewContent -FilePath $file `
                                               -StartLine $filePositions[$file] `
                                               -ContextLines $ContextLines
                $filePositions[$file] = $newPosition
            }
            else {
                $filePositions.Remove($file)
                Write-Host "Removed monitoring for deleted file: $file" -ForegroundColor Yellow
            }
        }
        
        Start-Sleep -Milliseconds $PollInterval
    }
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Write-Host "`nMonitoring stopped." -ForegroundColor Cyan
}
```
No pause
```powershell
# Real-time log monitor with debug output
$Path = "C:\ProgramData\Tableau\Tableau Server\data\tabsvc\logs"  # Modified to your actual path
$FilePattern = "*.log"               # Modified to catch all logs
$PollInterval = 1000                 # Milliseconds between checks (1 second)
$ContextLines = 2                    # Number of lines before/after to show
$SearchTerm = "ERROR"                 # Term to search for
$Debug = $false                       # Enable debug output

# Function to process new content
function Process-NewContent {
    param (
        [string]$FilePath,
        [int]$StartLine,
        [int]$ContextLines
    )
    
    try {
        # Read all content every time - inefficient but reliable for testing
        $content = Get-Content -Path $FilePath -Raw | ForEach-Object {$_ -split "`r`n"}
        $totalLines = $content.Count
        
        if ($Debug) {
            Write-Host "Debug: File $FilePath has $totalLines total lines, starting from line $StartLine" -ForegroundColor Gray
        }
        
        if ($totalLines -gt $StartLine) {
            $newLines = $content[$StartLine..($totalLines - 1)]
            if ($Debug) {
                Write-Host "Debug: Processing $(($totalLines - $StartLine)) new lines" -ForegroundColor Gray
            }
            
            $currentLine = $StartLine
            foreach ($line in $newLines) {
                if ($Debug) {
                    Write-Host "Debug: Checking line: $line" -ForegroundColor Gray
                }
                
                if ($line -match $SearchTerm) {
                    Write-Host "`nMatch found at line $($currentLine + 1):" -ForegroundColor Green
                    Write-Host $line -ForegroundColor Yellow
                }
                $currentLine++
            }
            return $totalLines
        }
        return $StartLine
    }
    catch {
        Write-Warning "Error in Process-NewContent: $($_.Exception.Message)"
        return $StartLine
    }
}

try {
    if (-not (Test-Path $Path)) {
        throw "Path '$Path' does not exist!"
    }

    $filePositions = @{}
    Write-Host "`nStarting monitoring of $Path" -ForegroundColor Cyan
    Write-Host "Looking for '$SearchTerm' in files matching '$FilePattern'" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Cyan

    while ($true) {
        # Get current files
        $currentFiles = Get-ChildItem -Path $Path -Filter $FilePattern -Recurse
        
        # Add any new files to monitoring
        foreach ($file in $currentFiles) {
            if (-not $filePositions.ContainsKey($file.FullName)) {
                $filePositions[$file.FullName] = 0  # Start from beginning
                Write-Host "Now monitoring: $($file.FullName)" -ForegroundColor Green
            }
        }
        
        # Process each file
        foreach ($file in $filePositions.Keys.Clone()) {
            if (Test-Path $file) {
                $newPosition = Process-NewContent -FilePath $file `
                                               -StartLine $filePositions[$file] `
                                               -ContextLines $ContextLines
                $filePositions[$file] = $newPosition
            }
            else {
                $filePositions.Remove($file)
                Write-Host "Removed monitoring for deleted file: $file" -ForegroundColor Yellow
            }
        }
        
        Start-Sleep -Milliseconds $PollInterval
    }
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Write-Host "`nMonitoring stopped." -ForegroundColor Cyan
}
```
Format is correct but the lines are limited
```bash
# Real-time log monitor with pause on match
$Path = "C:\ProgramData\Tableau\Tableau Server\data\tabsvc\logs\apigateway"  # Modified to your actual path
$FilePattern = "*.log"               # Modified to catch all logs
$PollInterval = 1000                 # Milliseconds between checks (1 second)
$ContextLines = 2                    # Number of lines before/after to show
$SearchTerm = "INFO"                 # Term to search for
$PauseSeconds = 3                    # How long to pause when match is found
$Debug = $false                      # Enable debug output

# Function to process new content
function Process-NewContent {
    param (
        [string]$FilePath,
        [int]$StartLine,
        [int]$ContextLines
    )
    
    try {
        $content = Get-Content -Path $FilePath -Raw | ForEach-Object {$_ -split "`r`n"}
        $totalLines = $content.Count
        
        if ($Debug) {
            Write-Host "Debug: File $FilePath has $totalLines total lines, starting from line $StartLine" -ForegroundColor Gray
        }
        
        if ($totalLines -gt $StartLine) {
            $newLines = $content[$StartLine..($totalLines - 1)]
            $matchFound = $false
            
            $currentLine = $StartLine
            foreach ($line in $newLines) {
                if ($line -match $SearchTerm) {
                    $matchFound = $true
                    Write-Host "`n===================================================" -ForegroundColor Cyan
                    Write-Host "Match found at line $($currentLine + 1) in file:" -ForegroundColor Green
                    Write-Host "$FilePath" -ForegroundColor Yellow
                    Write-Host "===================================================`n" -ForegroundColor Cyan
                    
                    # Show the matched line with word wrapping for better readability
                    $wrappedLine = $line -replace "(.{100})", "$1`n  "
                    Write-Host $wrappedLine -ForegroundColor White
                    Write-Host "`nPausing for $PauseSeconds seconds..." -ForegroundColor Gray
                    Start-Sleep -Seconds $PauseSeconds
                    Write-Host "Continuing scan...`n" -ForegroundColor Gray
                }
                $currentLine++
            }
            return $totalLines
        }
        return $StartLine
    }
    catch {
        Write-Warning "Error in Process-NewContent: $($_.Exception.Message)"
        return $StartLine
    }
}

try {
    if (-not (Test-Path $Path)) {
        throw "Path '$Path' does not exist!"
    }

    $filePositions = @{}
    Clear-Host
    Write-Host "`nStarting monitoring of $Path" -ForegroundColor Cyan
    Write-Host "Looking for '$SearchTerm' in files matching '$FilePattern'" -ForegroundColor Cyan
    Write-Host "Will pause for $PauseSeconds seconds when matches are found" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Cyan

    while ($true) {
        $currentFiles = Get-ChildItem -Path $Path -Filter $FilePattern -Recurse
        
        foreach ($file in $currentFiles) {
            if (-not $filePositions.ContainsKey($file.FullName)) {
                $filePositions[$file.FullName] = 0  # Start from beginning
                Write-Host "Now monitoring: $($file.FullName)" -ForegroundColor Green
            }
        }
        
        foreach ($file in $filePositions.Keys.Clone()) {
            if (Test-Path $file) {
                $newPosition = Process-NewContent -FilePath $file `
                                               -StartLine $filePositions[$file] `
                                               -ContextLines $ContextLines
                $filePositions[$file] = $newPosition
            }
            else {
                $filePositions.Remove($file)
                Write-Host "Removed monitoring for deleted file: $file" -ForegroundColor Yellow
            }
        }
        
        Start-Sleep -Milliseconds $PollInterval
    }
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    Write-Host "`nMonitoring stopped." -ForegroundColor Cyan
}
```
### Key Changes:
1. **Hardcoded Configuration**: 
   - Removed the `param` block and moved the configuration variables (`$Path`, `$FilePattern`, `$PollInterval`, `$ContextLines`) to the top of the script.
   - You can now edit these values directly in the script file. For example, change `$Path = "C:\Logs"` to whatever directory you want to monitor.

2. **Path Validation**: 
   - Added a check with `Test-Path` to ensure the specified `$Path` exists before starting the monitoring. If it doesn’t, the script will exit with an error message.

3. **Usage**:
   - Simply save this as a .ps1 file (e.g., `Monitor-Logs.ps1`), edit the `$Path` variable to your desired directory (e.g., `$Path = "C:\MyApp\Logs"`), and run it:
     ```powershell
     .\Monitor-Logs.ps1
     ```
   - No need to pass parameters each time since the path is now inside the script.

### How to Customize:
- **Change the Path**: Open the script in any text editor (like Notepad or VS Code) and modify the line `$Path = "C:\Logs"` to point to your log directory.
- **Adjust Other Settings**: You can also tweak `$FilePattern` (e.g., to `"*.txt"`), `$PollInterval` (e.g., to `500` for half-second checks), or `$ContextLines` (e.g., to `5` for more context).

This version retains all the real-time monitoring functionality and ServiceTimeoutException focus from the previous script, just with the path embedded. Let me know if you need further adjustments!
