<#
.SYNOPSIS
    Menu script to select Windows Edition and apply KMS settings.
.DESCRIPTION
    This script presents a menu of Windows editions, selects the appropriate GVLK,
    and runs the slmgr sequence: /upk, /skms, /ipk, /ato.
.NOTES
    Run as Administrator.
#>

# --- CONFIGURATION ---
# REPLACE THIS with your specific KMS server address
$kmsServer = "kms.msguides.com" 

# --- GVLK DICTIONARY (Generic Volume License Keys) ---
# Sourced from official Microsoft KMS Client Setup documentation
$editions = @{
    "1"  = @{ Name = "Home";                       Key = "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99" }
    "2"  = @{ Name = "Home N";                     Key = "3KHY7-WNT83-DGQKR-F7HPR-844BM" }
    "3"  = @{ Name = "Home (Single Language)";     Key = "7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH" }
    "4"  = @{ Name = "Home (Single Language) N";   Key = "4CPRK-NM3K3-X6XXQ-RXX86-WXCHW" }
    "5"  = @{ Name = "Pro";                        Key = "W269N-WFGWX-YVC9B-4J6C9-T83GX" }
    "6"  = @{ Name = "Pro N";                      Key = "MH37W-N47XK-V7XM9-C7227-GCQG9" }
    "7"  = @{ Name = "Pro for Workstations";       Key = "NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J" }
    "8"  = @{ Name = "Pro for Workstations N";     Key = "9FNHH-K3HBT-3W4TD-6383H-6XYWF" }
    "9"  = @{ Name = "Pro for Education";          Key = "6TP4R-GNPTD-KYYHQ-7B7DP-J447Y" }
    "10" = @{ Name = "Pro for Education N";        Key = "YVWGF-BXNMC-HTQYQ-CPQ99-66QFC" }
    "11" = @{ Name = "Education";                  Key = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" }
    "12" = @{ Name = "Education N";                Key = "2WH4N-8QGBV-H22JP-CT43Q-MDWWJ" }
    "13" = @{ Name = "Enterprise";                 Key = "NPPR9-FWDCX-D2C8J-H872K-2YT43" }
    "14" = @{ Name = "Enterprise N";               Key = "DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4" }
    "15" = @{ Name = "Server 2019 (Standard)";     Key = "N69G4-B89J2-4G8F4-WWYCC-J464C" }
    "16" = @{ Name = "Server 2022 (Standard)";     Key = "VDYBN-27JQH-46J9R-3J4V9-GGJ92" }
    "17" = @{ Name = "Server 2025 (Standard)";     Key = "TVRH6-WHNXV-R9WG3-9XRFY-MY832" } 
    "18" = @{ Name = "Server 2019 (Datacenter)";   Key = "WMDGN-G9PQG-XVVXX-R3X43-63DFG" }
    "19" = @{ Name = "Server 2022 (Datacenter)";   Key = "WX4NM-KYWXW-QJJ82-FBPG2-M9WTT" }
    "20" = @{ Name = "Server 2025 (Datacenter)";   Key = "D764K-2NDRG-47T6Q-P8T8W-YP6DF" }
}

# --- FUNCTIONS ---

function Show-Menu {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "    WINDOWS EDITION SELECTION MENU       " -ForegroundColor White
    Write-Host "=========================================" -ForegroundColor Cyan
	Write-Host "      CREATED BY BRANCHY OF DRTC         " -ForegroundColor White
	Write-Host "=========================================" -ForegroundColor Cyan
	Write-Host "    KMS SERVER PROVIDED BY MSGUIDES      " -ForegroundColor White
	Write-Host "=========================================" -ForegroundColor Cyan
    
    # Sort keys numerically to display in order
    $sortedKeys = $editions.Keys | Sort-Object { [int]$_ }
    
    foreach ($key in $sortedKeys) {
        $entry = $editions[$key]
        Write-Host "$key. $($entry.Name)" -ForegroundColor Yellow
    }
    Write-Host "Q. Quit" -ForegroundColor Gray
    Write-Host "=========================================" -ForegroundColor Cyan
}

function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "This script requires Administrator privileges to run slmgr commands."
        Write-Host "Please right-click the script and select 'Run as Administrator'." -ForegroundColor Red
        Start-Sleep -Seconds 5
        Exit
    }
}

# --- MAIN EXECUTION ---

Check-Admin

while ($true) {
    Show-Menu
    $selection = Read-Host "Please enter the number of your choice"

    if ($selection -eq 'Q' -or $selection -eq 'q') {
        Write-Host "Exiting..." -ForegroundColor Green
        break
    }

    if ($editions.ContainsKey($selection)) {
        $selectedEdition = $editions[$selection]
        $productKey = $selectedEdition.Key
        $editionName = $selectedEdition.Name

        Write-Host "`nYou selected: $editionName" -ForegroundColor Cyan
        Write-Host "Applying Key: $productKey" -ForegroundColor DarkGray
        Write-Host "Setting KMS Host: $kmsServer" -ForegroundColor DarkGray
        
        $confirm = Read-Host "Type 'Y' to proceed with these changes and activate Windows $editionName"
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            
            Write-Host "1. Uninstalling current product key (if any)..." -ForegroundColor Yellow
            slmgr /upk
            
            Write-Host "2. Setting KMS host to $kmsServer..." -ForegroundColor Yellow
            slmgr /skms $kmsServer
            
            Write-Host "3. Installing new product key Windows $editionName..." -ForegroundColor Yellow
            slmgr /ipk $productKey
            
            Write-Host "4. Activating your computer..." -ForegroundColor Yellow
            slmgr /ato
            
            Write-Host "`nProcess Complete. You've successfully activated Windows $editionName" -ForegroundColor Green
            Write-Host "Check the pop-up windows for status details." -ForegroundColor White
            Pause
        } else {
            Write-Host "Operation cancelled. Please Try Again Later." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } else {
        Write-Host "Invalid selection. Please try again." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}