Get-ChildItem "C:\code\PSUniversalLogging\TestLogs" -Recurse -Filter "*.log" | 
    Select-Object -First 1 | 
    ForEach-Object { 
        Write-Host "Log file: $($_.FullName)" -ForegroundColor Yellow
        Write-Host "Last 10 lines:" -ForegroundColor Cyan
        Get-Content $_.FullName -Tail 10
    }