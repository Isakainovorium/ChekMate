# Manual PowerShell-based duplicate analysis
# Enterprise-grade file comparison

Write-Host "🔍 ENTERPRISE-GRADE DUPLICATE ANALYSIS" -ForegroundColor Cyan
Write-Host "=" * 70
Write-Host ""

function Analyze-DartFile {
    param(
        [string]$FilePath,
        [string]$GroupName
    )
    
    if (-not (Test-Path $FilePath)) {
        return $null
    }
    
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    $fileSize = (Get-Item $FilePath).Length
    $lineCount = $lines.Count
    
    $analysis = @{
        FilePath = $FilePath
        FileName = Split-Path $FilePath -Leaf
        Content = $content
        LineCount = $lineCount
        FileSize = $fileSize
        QualityScore = 0
        CompletenessScore = 0
        IsStub = $false
        StateManagement = "None"
        HasErrorHandling = $false
        HasLoadingStates = $false
        HasFormValidation = $false
        HasRiverpod = $false
        HasDocumentation = $false
        Issues = @()
    }
    
    # Check for stub/placeholder
    if ($content -match "To be implemented|TODO|Coming soon") {
        $analysis.IsStub = $true
        $analysis.Issues += "Contains placeholder/stub code"
    }
    
    # Check state management
    if ($content -match "ConsumerWidget|ConsumerStatefulWidget") {
        $analysis.StateManagement = "Riverpod (Consumer)"
        $analysis.HasRiverpod = $true
    } elseif ($content -match "ref\.watch|ref\.read") {
        $analysis.StateManagement = "Riverpod"
        $analysis.HasRiverpod = $true
    } elseif ($content -match "StatefulWidget") {
        $analysis.StateManagement = "StatefulWidget"
    } elseif ($content -match "StatelessWidget") {
        $analysis.StateManagement = "StatelessWidget"
    }
    
    # Check error handling
    if ($content -match "try.*catch|AsyncValue|\.when\(") {
        $analysis.HasErrorHandling = $true
    }
    
    # Check loading states
    if ($content -match 'isLoading|CircularProgressIndicator|loading:') {
        $analysis.HasLoadingStates = $true
    }
    
    # Check form validation
    if ($content -match 'validator:|_formKey|GlobalKey<FormState>') {
        $analysis.HasFormValidation = $true
    }
    
    # Check documentation
    $docCount = ([regex]::Matches($content, '///')).Count
    if ($docCount -gt 2) {
        $analysis.HasDocumentation = $true
    }
    
    # Calculate completeness score
    $completeness = 0
    if (-not $analysis.IsStub) { $completeness += 30 }
    if ($analysis.HasErrorHandling) { $completeness += 15 }
    if ($analysis.HasLoadingStates) { $completeness += 10 }
    if ($analysis.HasFormValidation) { $completeness += 10 }
    if ($analysis.HasRiverpod) { $completeness += 15 }
    if ($analysis.HasDocumentation) { $completeness += 10 }
    if ($lineCount -gt 100) { $completeness += 10 }
    $analysis.CompletenessScore = $completeness
    
    # Calculate quality score
    $score = $completeness
    if ($analysis.IsStub) { $score -= 50 }
    if ($lineCount -lt 30) { $score -= 20 }
    if (-not $analysis.HasErrorHandling) { $score -= 10 }
    if (-not $analysis.HasRiverpod) { $score -= 10 }
    if ($analysis.HasRiverpod) { $score += 15 }
    if ($analysis.HasErrorHandling) { $score += 10 }
    if ($analysis.HasLoadingStates) { $score += 10 }
    
    $analysis.QualityScore = [Math]::Max(0, [Math]::Min(100, $score))
    
    if ($lineCount -lt 50 -and -not $analysis.IsStub) {
        $analysis.Issues += 'Very small file - may be incomplete'
    }
    
    return $analysis
}

function Compare-DuplicateGroup {
    param(
        [string]$GroupName,
        [string[]]$FilePaths
    )
    
    Write-Host "[*] Analyzing: $GroupName" -ForegroundColor Yellow
    Write-Host ("-" * 70)
    
    $analyses = @()
    foreach ($path in $FilePaths) {
        $fullPath = Join-Path $PSScriptRoot $path
        $analysis = Analyze-DartFile -FilePath $fullPath -GroupName $GroupName
        if ($analysis) {
            $analyses += $analysis
        } else {
            Write-Host "  ⚠️  File not found: $path" -ForegroundColor DarkYellow
        }
    }
    
    if ($analyses.Count -eq 0) {
        Write-Host "  ❌ No files found in this group`n"
        return $null
    }
    
    # Sort by quality score (highest first)
    $analyses = $analyses | Sort-Object -Property QualityScore -Descending
    
    # Print comparison
    for ($i = 0; $i -lt $analyses.Count; $i++) {
        $analysis = $analyses[$i]
        $badgeText = if ($i -eq 0) { "RECOMMENDED" } else { "DELETE" }
        $badgeIcon = if ($i -eq 0) { "✅" } else { "❌" }
        $color = if ($i -eq 0) { "Green" } else { "Red" }
        
        Write-Host ""
        Write-Host "  $badgeIcon $badgeText $($analysis.FileName)" -ForegroundColor $color
        Write-Host "  Path: $($analysis.FilePath.Replace($PSScriptRoot, '.'))"
        Write-Host "  Quality Score: $($analysis.QualityScore)/100" -ForegroundColor $(if ($analysis.QualityScore -ge 70) { "Green" } elseif ($analysis.QualityScore -ge 40) { "Yellow" } else { "Red" })
        Write-Host "  Size: $($analysis.FileSize) bytes ($($analysis.LineCount) lines)"
        Write-Host "  Completeness: $($analysis.CompletenessScore)%"
        Write-Host "  Enterprise Features:"
        Write-Host "    - Error Handling: $(if ($analysis.HasErrorHandling) { '✓' } else { '✗' })"
        Write-Host "    - State Management: $($analysis.StateManagement)"
        Write-Host "    - Riverpod Integration: $(if ($analysis.HasRiverpod) { '✓' } else { '✗' })"
        Write-Host "    - Loading States: $(if ($analysis.HasLoadingStates) { '✓' } else { '✗' })"
        Write-Host "    - Form Validation: $(if ($analysis.HasFormValidation) { '✓' } else { '✗' })"
        Write-Host "    - Documentation: $(if ($analysis.HasDocumentation) { '✓' } else { '✗' })"
        
        if ($analysis.Issues.Count -gt 0) {
            Write-Host "  Issues:"
            foreach ($issue in $analysis.Issues) {
                Write-Host "    - $issue" -ForegroundColor DarkYellow
            }
        }
    }
    
    Write-Host ""
    Write-Host "  💡 Recommendation: Keep $($analyses[0].FileName)" -ForegroundColor Green
    if ($analyses.Count -gt 1) {
        $toDelete = ($analyses | Select-Object -Skip 1 | ForEach-Object { $_.FileName }) -join ", "
        Write-Host "  🗑️  Delete: $toDelete" -ForegroundColor Red
    }
    Write-Host ""
    
    return @{
        GroupName = $GroupName
        Recommended = $analyses[0]
        ToDelete = $analyses | Select-Object -Skip 1
    }
}

# Define duplicate groups
$groups = @{
    "AUTH_LOGIN" = @(
        "lib\features\feed\pages\auth\pages\login_page.dart",
        "lib\features\feed\pages\auth\presentation\pages\login_page.dart"
    )
    "AUTH_SIGNUP" = @(
        "lib\features\feed\pages\auth\pages\signup_page.dart",
        "lib\features\feed\pages\auth\presentation\pages\signup_page.dart"
    )
    "HOME" = @(
        "lib\features\feed\pages\home\pages\home_page.dart",
        "lib\features\feed\pages\home\presentation\pages\home_page.dart",
        "lib\features\feed\pages\home\presentation\pages\home_page_new.dart"
    )
    "LIVE" = @(
        "lib\features\feed\pages\live\pages\live_page.dart",
        "lib\features\feed\pages\live\pages\live_feed_page.dart",
        "lib\features\feed\pages\live\presentation\pages\live_page.dart"
    )
    "PROFILE_MAIN" = @(
        "lib\features\feed\pages\profile\pages\profile_page.dart",
        "lib\features\feed\pages\profile\presentation\pages\profile_page.dart"
    )
    "PROFILE_EDIT" = @(
        "lib\features\feed\pages\profile\pages\edit_profile_page.dart",
        "lib\features\feed\pages\profile\presentation\pages\edit_profile_page.dart"
    )
    "FOLLOWING" = @(
        "lib\features\feed\pages\following_page.dart",
        "lib\features\feed\pages\following_page_riverpod.dart"
    )
    "NOTIFICATIONS" = @(
        "lib\features\feed\pages\messaging\pages\notifications\pages\notifications_page.dart",
        "lib\features\feed\pages\messaging\pages\notifications\presentation\pages\notifications_page.dart"
    )
    "RATE_DATE" = @(
        "lib\features\feed\pages\messaging\pages\rate_date\pages\rate_your_date_page.dart",
        "lib\features\feed\pages\messaging\pages\rate_date\presentation\pages\rate_date_page.dart"
    )
}

# Analyze all groups
$reports = @()
foreach ($group in $groups.GetEnumerator()) {
    $report = Compare-DuplicateGroup -GroupName $group.Key -FilePaths $group.Value
    if ($report) {
        $reports += $report
    }
}

# Print summary
Write-Host ("=" * 70)
Write-Host "📊 SUMMARY REPORT" -ForegroundColor Cyan
Write-Host ("=" * 70)
Write-Host ""

$totalToKeep = $reports.Count
$totalToDelete = ($reports | ForEach-Object { $_.ToDelete.Count } | Measure-Object -Sum).Sum

Write-Host "✅ FILES TO KEEP ($totalToKeep):" -ForegroundColor Green
foreach ($report in $reports) {
    Write-Host "  • $($report.GroupName): $($report.Recommended.FileName)"
    Write-Host "    Score: $($report.Recommended.QualityScore)/100"
}

Write-Host ""
Write-Host "❌ FILES TO DELETE ($totalToDelete):" -ForegroundColor Red
foreach ($report in $reports) {
    foreach ($file in $report.ToDelete) {
        Write-Host "  • $($report.GroupName): $($file.FileName)"
        $reason = if ($file.IsStub) { "(STUB)" } else { "" }
        Write-Host "    Reason: Score $($file.QualityScore)/100 $reason"
    }
}

Write-Host ""
Write-Host "📈 STATISTICS:" -ForegroundColor Cyan
Write-Host "  Total Groups Analyzed: $($reports.Count)"
Write-Host "  Files to Keep: $totalToKeep"
Write-Host "  Files to Delete: $totalToDelete"

$totalSpaceToReclaim = ($reports | ForEach-Object { 
    $_.ToDelete | ForEach-Object { $_.FileSize } | Measure-Object -Sum 
} | ForEach-Object { $_.Sum } | Measure-Object -Sum).Sum

Write-Host "  Space to Reclaim: $([Math]::Round($totalSpaceToReclaim / 1KB, 2)) KB"

Write-Host ""
Write-Host "💡 ENTERPRISE READINESS:" -ForegroundColor Cyan
$avgScore = ($reports | ForEach-Object { $_.Recommended.QualityScore } | Measure-Object -Average).Average
Write-Host "  Average Quality Score: $([Math]::Round($avgScore, 1))/100"

if ($avgScore -ge 80) {
    Write-Host "  Status: ✅ PRODUCTION READY" -ForegroundColor Green
} elseif ($avgScore -ge 60) {
    Write-Host "  Status: ⚠️  NEEDS IMPROVEMENT" -ForegroundColor Yellow
} else {
    Write-Host "  Status: ❌ NOT PRODUCTION READY" -ForegroundColor Red
}

Write-Host ""
Write-Host ("=" * 70)
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review the recommendations above"
Write-Host "  2. Run the cleanup script to delete duplicates"
Write-Host "  3. Test the application thoroughly"
Write-Host "  4. Update imports and router configuration"
