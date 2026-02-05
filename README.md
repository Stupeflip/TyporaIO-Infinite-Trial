# Typora Trial Reset

A simple PowerShell script to reset your Typora trial period to 15 days.

## How It Works

Typora tracks your trial period using **AWS Cognito** - a cloud-based identity service. When you first install Typora, it generates a unique identity ID that's stored locally and linked to your trial status on their servers.

This script works by:
1. **Deleting the AWS Cognito identity** stored in `Local Storage`
2. **Removing the installation date** from `profile.data`
3. **Clearing all cached data** and registry entries

When you launch Typora after running this script, it will:
- Generate a **new AWS identity**
- Start a **fresh 15-day trial**

## Usage

### Method 1: Right-click (Recommended)
1. Right-click on `FULL_RESET.ps1`
2. Select **"Run with PowerShell"**

### Method 2: Command Line
```powershell
cd path\to\typora-reset
.\FULL_RESET.ps1
```

### Method 3: If scripts are blocked
```powershell
powershell -ExecutionPolicy Bypass -File "FULL_RESET.ps1"
```

## Features

- Resets trial to **15 days**
- **Backs up your drafts** before reset
- Auto-applies **Night theme**
- Works on any Windows PC
- No admin rights required

## What Gets Deleted

| Item | Purpose |
|------|---------|
| `Local Storage/` | AWS Cognito identity (trial tracking) |
| `profile.data` | Installation date & settings |
| `Session Storage/` | Session data |
| `Cache/` | Cached files |
| `Preferences` | App preferences |
| Registry keys | License info |

Your drafts are automatically backed up to `typora_drafts_backup/` in the script folder before deletion.

## Requirements

- Windows 10/11
- PowerShell 5.0+
- Typora installed

## Disclaimer

This script is for educational purposes only. Please support the developers by purchasing a license if you find Typora useful.
