<# PowerShell script to bulk fix deprecation issues #>
Write-Host "Starting bulk deprecation fixes..." -ForegroundColor Green

# Fix withOpacity -> withValues(alpha:X)
Get-ChildItem -Path "lib" -Recurse -Include "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $before = $content
    $content = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
    if ($content -ne $before) {
        Write-Host "Fixed withOpacity in: $($_.Name)" -ForegroundColor Yellow
        Set-Content -Path $_.FullName -Value $content -NoNewline
    }
}

# Fix Color.value -> toARGB32()
Get-ChildItem -Path "lib" -Recurse -Include "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $before = $content
    $content = $content -replace '\.value\)', '.toARGB32())'
    if ($content -ne $before) {
        Write-Host "Fixed Color.value in: $($_.Name)" -ForegroundColor Yellow
        Set-Content -Path $_.FullName -Value $content -NoNewline
    }
}

# Fix Material surfaceVariant -> surfaceContainerHighest
Get-ChildItem -Path "lib" -Recurse -Include "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $before = $content
    $content = $content -replace '\.surfaceVariant', '.surfaceContainerHighest'
    if ($content -ne $before) {
        Write-Host "Fixed surfaceVariant in: $($_.Name)" -ForegroundColor Yellow
        Set-Content -Path $_.FullName -Value $content -NoNewline
    }
}

# Fix onPopInvoked -> onPopInvokedWithResult
Get-ChildItem -Path "lib" -Recurse -Include "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $before = $content
    $content = $content -replace 'onPopInvoked', 'onPopInvokedWithResult'
    if ($content -ne $before) {
        Write-Host "Fixed onPopInvoked in: $($_.Name)" -ForegroundColor Yellow
        Set-Content -Path $_.FullName -Value $content -NoNewline
    }
}

Write-Host "Bulk fixes completed!" -ForegroundColor Green
