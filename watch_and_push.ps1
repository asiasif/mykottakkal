# watch_and_push.ps1
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $PSScriptRoot
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

Write-Host "=============================================" -ForegroundColor Green
Write-Host "   MyKottakkal Auto-Sync Watcher Active      " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Watching: $PSScriptRoot"
Write-Host "Press Ctrl+C in this window to stop watching."
Write-Host ""

$script:lastRun = [DateTime]::MinValue

$action = {
    $path = $Event.SourceEventArgs.FullPath
    
    # Exclude temporary, git, vercel, dart, and build folders
    if ($path -match '\\.git\\' -or $path -match '\\.vercel\\' -or $path -match '\\build\\' -or $path -match '\\.dart_tool\\' -or $path -match '\\mykottakkal_qr\.png') {
        return
    }
    
    # Debounce events within 3 seconds to avoid double execution on multiple saves
    $now = Get-Date
    if (($now - $script:lastRun).TotalSeconds -lt 3) {
        return
    }
    $script:lastRun = $now
    
    Write-Host "Change detected in: $path" -ForegroundColor Cyan
    Start-Sleep -Seconds 1 # Wait for editor to release file lock
    
    # Check if there are actual git changes
    $status = git status --porcelain
    if ([string]::IsNullOrEmpty($status)) {
        Write-Host "No changes to push." -ForegroundColor Gray
        return
    }
    
    Write-Host "Changes found, pushing..." -ForegroundColor Yellow
    git add .
    git commit -m "auto: updates at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git push origin main
    
    Write-Host "Done! Vercel is now building and deploying." -ForegroundColor Green
    Write-Host "Waiting for new changes..." -ForegroundColor Gray
    Write-Host ""
}

# Register file system events
$handlers = @()
$handlers += Register-ObjectEvent $watcher -EventName "Changed" -Action $action
$handlers += Register-ObjectEvent $watcher -EventName "Created" -Action $action
$handlers += Register-ObjectEvent $watcher -EventName "Deleted" -Action $action

try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Unregister events on exit
    foreach ($handler in $handlers) {
        Unregister-Event -SourceIdentifier $handler.Name
    }
}
