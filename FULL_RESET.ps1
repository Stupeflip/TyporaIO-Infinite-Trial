Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "         TYPORA TRIAL RESET" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This will reset your Typora trial to 15 days" -ForegroundColor Yellow
Write-Host ""

# Kill Typora if running
Stop-Process -Name "Typora" -Force -ErrorAction SilentlyContinue
Start-Sleep 1

# Typora data folder (works on any Windows PC)
$typoraData = Join-Path $env:APPDATA "Typora"

if (!(Test-Path $typoraData)) {
    Write-Host "[-] Typora data folder not found. Is Typora installed?" -ForegroundColor Red
    Read-Host "  Press ENTER to close"
    exit
}

# Backup drafts to script directory
$drafts = Join-Path $typoraData "draftsRecover"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = Get-Location }
$draftBackup = Join-Path $scriptDir "typora_drafts_backup"

if (Test-Path $drafts) {
    Write-Host "[*] Backing up drafts..." -ForegroundColor Yellow
    if (Test-Path $draftBackup) { Remove-Item $draftBackup -Recurse -Force -ErrorAction SilentlyContinue }
    Copy-Item $drafts $draftBackup -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Drafts backed up to: $draftBackup" -ForegroundColor Green
}

# Delete Local Storage (contains AWS Cognito identity - this is the key!)
$localStorage = Join-Path $typoraData "Local Storage"
if (Test-Path $localStorage) {
    Remove-Item $localStorage -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Deleted Local Storage (AWS identity)" -ForegroundColor Green
}

# Delete profile.data (contains install date)
$profile = Join-Path $typoraData "profile.data"
if (Test-Path $profile) {
    Remove-Item $profile -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Deleted profile.data" -ForegroundColor Green
}

# Delete Preferences
$prefs = Join-Path $typoraData "Preferences"
if (Test-Path $prefs) {
    Remove-Item $prefs -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Deleted Preferences" -ForegroundColor Green
}

# Delete Session Storage
$session = Join-Path $typoraData "Session Storage"
if (Test-Path $session) {
    Remove-Item $session -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Deleted Session Storage" -ForegroundColor Green
}

# Delete caches
@("Cache", "Code Cache", "GPUCache", "DawnGraphiteCache", "DawnWebGPUCache") | ForEach-Object {
    $cachePath = Join-Path $typoraData $_
    if (Test-Path $cachePath) {
        Remove-Item $cachePath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Deleted $_" -ForegroundColor Green
    }
}

# Clear registry
reg delete "HKCU\Software\Typora" /f 2>$null | Out-Null
Write-Host "[+] Cleared registry" -ForegroundColor Green

# Create new profile.data with night theme
$today = Get-Date -Format "MM/dd/yyyy"
$newUuid = [guid]::NewGuid().ToString()
$profileJson = @{
    version = "1.12.4"
    initialize_ver = "1.0.0"
    line_ending_crlf = $true
    preLinebreakOnExport = $true
    uuid = $newUuid
    strict_mode = $true
    copy_markdown_by_default = $true
    _iD = $today
    didShowWelcomePanel2 = $true
    backgroundColor = "#363B40"
    isDarkMode = $true
    theme = "night.css"
    sidebar_tab = ""
} | ConvertTo-Json -Compress

# Encode to hex (Typora format)
$profileBytes = [System.Text.Encoding]::UTF8.GetBytes($profileJson)
$profileHex = -join ($profileBytes | ForEach-Object { $_.ToString("x2") })

# Write profile.data
$profilePath = Join-Path $typoraData "profile.data"
Set-Content $profilePath -Value $profileHex -NoNewline
Write-Host "[+] Created profile.data with Night theme" -ForegroundColor Green

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "            RESET COMPLETE" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Typora will now:" -ForegroundColor White
Write-Host "    - Generate a new AWS identity" -ForegroundColor Gray
Write-Host "    - Have a fresh 15-day trial" -ForegroundColor Gray
Write-Host ""
Write-Host "  Your drafts are backed up in the script folder." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Launch Typora and enjoy!" -ForegroundColor Green
Write-Host ""
Read-Host "  Press ENTER to close"
