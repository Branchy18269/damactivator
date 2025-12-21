# ==============================================================================
# 1. ADMIN PRIVILEGE CHECK
# ==============================================================================
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Add-Type -AssemblyName System.Windows.Forms
    $msg = "DamActivator requires Administrator privileges.`n`nRestart as Administrator?"
    $choice = [System.Windows.Forms.MessageBox]::Show($msg, "Admin Required", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($choice -eq 'Yes') {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==============================================================================
# 2. KEY DATABASE (COMPLETE)
# ==============================================================================
$Keys = @{
    # --- CONSUMER ---
    "Windows Home and Home N" = [ordered]@{ "Windows Home" = "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"; "Windows Home N" = "3KHY7-WNT83-DGQKR-F7HPR-844BM" }
    "Windows Home SL and Home SL N" = [ordered]@{ "Windows Home Single Language" = "7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH"; "Windows Home Single Language N" = "4CPRK-NM3K3-X6XXQ-RXX86-WXCHW" }
    "Windows Pro and Pro N" = [ordered]@{ "Windows Pro" = "W269N-WFGWX-YVC9B-4J6C9-T83GX"; "Windows Pro N" = "MH37W-N47XK-V7XM9-C7227-GCQG9" }

    # --- ENTERPRISE ---
    "Windows Pro for Workstations" = @{ "Pro for Workstations" = "NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J" }
    "Windows Pro Education" = @{ "Pro Education" = "6TP4R-GNPTD-KYYHQ-7B7DP-J447Y" }
    "Windows Education" = @{ "Education" = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" }
    "Windows Enterprise and Enterprise N and Enterprise G" = [ordered]@{ "Enterprise" = "NPPR9-FWDCX-D2C8J-H872K-2YT43"; "Enterprise N" = "DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4" }
    "Windows Enterprise LTSC (2024&2021&2019)" = @{ "Enterprise LTSC" = "M7XTQ-FN8P6-TTKYV-9D4CC-J462D" }
    "Windows IoT LTSC 2024" = @{ "IoT Enterprise LTSC" = "KBN8V-HFGQ4-MGXVD-347P6-PDQGT" }
    "Windows Enterprise LTSB (2015&2016)" = @{ "Enterprise LTSB 2016" = "DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ" }

    # --- LEGACY ---
    "Windows Vista Business and Business N" = [ordered]@{ "Vista Business" = "YFKBB-PQJJV-G996G-VWGXY-2V3X8"; "Vista Business N" = "HMBQG-8H2RH-C77VX-27R82-VMQBT" }
    "Windows Vista Enterprise and Enterprise N" = [ordered]@{ "Vista Enterprise" = "VKK3X-68KWM-X2YGT-QR4M6-4BWMV"; "Vista Enterprise N" = "VTC42-BM838-43QHV-84HX6-XJXKV" }
    "Windows 7 Professional, Professional N, and Professional E" = [ordered]@{ "Win 7 Professional" = "FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4"; "Win 7 Professional N" = "MRPKT-YTG23-K7D7T-X2JMM-QY7MG" }
    "Windows 7 Enterprise, Enterprise N and Enterprise E" = [ordered]@{ "Win 7 Enterprise" = "33PXH-7Y6KF-2VJC9-XBBR8-HVTHH"; "Win 7 Enterprise N" = "YDRBP-3D83W-TY26F-D46B2-XCKRJ" }
    "Windows 8 Pro and Pro N" = [ordered]@{ "Windows 8 Pro" = "NG4HW-VH26C-733KW-K6F98-J8CK4"; "Windows 8 Pro N" = "XCVCF-2NXM9-723PB-MHCB7-2RYQQ" }
    "Windows 8 Enterprise and Enterprise N" = [ordered]@{ "Windows 8 Enterprise" = "32JNW-9KQ84-P47T8-D8GGY-CWCK7"; "Windows 8 Enterprise N" = "JMNMF-RHW7P-DMY6X-RF3DR-X2BQT" }
    "Windows 8.1 Pro and Pro N" = [ordered]@{ "Windows 8.1 Pro" = "GCRJD-8NW9H-F2CDX-CCM8D-9D6T9"; "Windows 8.1 Pro N" = "HMCNV-VVBFX-7HMBH-CTY9B-B4FXY" }
    "Windows 8.1 Enterprise and Enterprise N" = [ordered]@{ "Windows 8.1 Enterprise" = "MHF9N-XY6XB-WVXMC-BTDCT-MKKG7"; "Windows 8.1 Enterprise N" = "TT4HM-HN7YT-62K67-RGRQJ-JFFXW" }

    # --- SERVER ---
    "Windows Server 2008 Web Server" = @{ "Key" = "WYR28-R7TFJ-3X2YQ-YCY4H-M249D" }
    "Windows Server 2008 Standard" = @{ "Key" = "TM24T-X9RMF-VWXK6-X8JC9-BFGM2" }
    "Windows Server 2008 Standard (No Hyper-V)" = @{ "Key" = "W7VD6-7JFBR-RX26B-YKQ3Y-6FFFJ" }
    "Windows Server 2008 Enterprise" = @{ "Key" = "YQGMW-MPWTJ-34KDK-48M3W-X4Q6V" }
    "Windows Server 2008 Enterprise (No Hyper-V)" = @{ "Key" = "39BXF-X8Q23-P2WWT-38T2F-G3FPG" }
    "Windows Server 2008 HPC" = @{ "Key" = "RCTX3-KWVHP-BR6TB-RB6DM-6X7HP" }
    "Windows Server 2008 Datacenter" = @{ "Key" = "7M67G-PC374-GR742-YH8V4-TCBY3" }
    "Windows Server 2008 Datacenter (No Hyper-V)" = @{ "Key" = "22XQ2-VRXRG-P8D42-K34TD-G3QQC" }
    "Windows Server 2008 For IBS" = @{ "Key" = "4DWFP-JF3DJ-B7DTH-78FJB-PDRHK" }
    "Windows Server 2008 R2 Web Server" = @{ "Key" = "6TPJF-RBVHG-WBW2R-86QPH-6RTM4" }
    "Windows Server 2008 R2 HPC" = @{ "Key" = "TT8MH-CG224-D3D7Q-498W2-9QCTX" }
    "Windows Server 2008 R2 Standard" = @{ "Key" = "YC6KT-GKW9T-YTKYR-T4X34-R7VHC" }
    "Windows Server 2008 R2 Enterprise" = @{ "Key" = "489J6-VHDMP-X63PK-3K798-CPX3Y" }
    "Windows Server 2008 R2 Datacenter" = @{ "Key" = "74YFP-3QFB3-KQT8W-PMXWJ-7M648" }
    "Windows Server 2008 R2 for IBS" = @{ "Key" = "GT63C-RJFQ3-4GMB6-BRFB9-CB83V" }
    "Windows Server 2012" = @{ "Key" = "BN3D2-R7TKB-3YPBD-8DRP2-27GG4" }
    "Windows Server 2012 N" = @{ "Key" = "8N2M2-HWPGY-7PGT9-HGDD8-GVGGY" }
    "Windows Server 2012 SL" = @{ "Key" = "2WN2H-YGCQR-KFX6K-CD6TF-84YXQ" }
    "Windows Server 2012 CS" = @{ "Key" = "4K36P-JN4VD-GDC6V-KDT89-DYFKP" }
    "Windows Server 2012 Standard" = @{ "Key" = "XC9B7-NBPP2-83J2H-RHMBY-92BT4" }
    "Windows Server 2012 Multipoint Standard" = @{ "Key" = "HM7DN-YVMH3-46JC3-XYTG7-CYQJJ" }
    "Windows Server 2012 Multipoint Premium" = @{ "Key" = "XNH6W-2V9GX-RGJ4K-Y8X6F-QGJ2G" }
    "Windows Server 2012 Datacenter" = @{ "Key" = "48HP8-DN98B-MYWDG-T2DCC-8W83P" }
    "Windows Server 2012 Essentials" = @{ "Key" = "HTDQM-NBMMG-KGYDT-2DTKT-J2MPV" }
    "Windows Server 2012 R2 Standard" = @{ "Key" = "D2N9P-3P6X9-2R39C-7RTCD-MDVJX" }
    "Windows Server 2012 R2 Datacenter" = @{ "Key" = "W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9" }
    "Windows Server 2012 R2 Essentials" = @{ "Key" = "KNC87-3J2TX-XB4WP-VCPJV-M4FWM" }
    "Windows Server v.1709 Standard" = @{ "Key" = "DPCNP-XQFKJ-BJF7R-FRC8D-GF6G4" }
    "Windows Server v.1709 Datacenter" = @{ "Key" = "6Y6KB-N82V8-D8CQV-23MJW-BWTG6" }
    "Windows Server v.1803 Standard" = @{ "Key" = "PTXN8-JFHJM-4WC78-MPCBR-9W4KR" }
    "Windows Server v.1803 Datacenter" = @{ "Key" = "2HXDN-KRXHB-GPYC7-YCKFJ-7FVDG" }
    "Windows Server Semi-Anual Stnadard" = @{ "Key" = "N2KJX-J94YW-TQVFB-DG9YT-724CC" }
    "Windows Server Semi-Anual Datacenter" = @{ "Key" = "6NMRW-2C8FM-D24W7-TQWMY-CWH2D" }
    "Windows Server 2016 Standard" = @{ "Key" = "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY" }
    "Windows Server 2016 Datacenter" = @{ "Key" = "CB7KF-BWN84-R7R2Y-793K2-8XDDG" }
    "Windows Server 2016 Essentials" = @{ "Key" = "JCKRF-N37P4-C2D82-9YXRT-4M63B" }
    "Windows Server 2019 Standard" = @{ "Key" = "N69G4-B89J2-4G8F4-WWYCC-J464C" }
    "Windows Server 2019 Datacenter" = @{ "Key" = "WMDGN-G9PQG-XVVXX-R3X43-63DFG" }
    "Windows Server 2019 Essentials" = @{ "Key" = "WVDHN-86M7X-466P6-VHXV7-YY726" }
    "Windows Server 2022 Standard" = @{ "Key" = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H" }
    "Windows Server 2022 Datacenter" = @{ "Key" = "WX4NM-KYWYW-QJJ82-FBPG2-M9WTT" }
    "Windows Server 2022 Datacenter (Azure)" = @{ "Key" = "NTBV8-9K7Q8-V27C6-M2BTV-KHMXV" }
    "Windows Server 2025 Standard" = @{ "Key" = "TVRH6-WHNXV-R9WG3-9XRFY-MY832" }
    "Windows Server 2025 Datacenter" = @{ "Key" = "D764K-2NDRG-47T6Q-P8T8W-YP6DF" }
    "Windows Server 2025 Datacenter (Azure)" = @{ "Key" = "XGN3F-F394H-FD2MY-PP6FD-8MCRC" }
}

$KmsServerList = @("kms.msguides.com", "kms8.msguides.com", "kms.digiboy.ir", "kms.lotro.cc")

# ==============================================================================
# 3. STYLING
# ==============================================================================
$Colors = @{
    Bg = [System.Drawing.Color]::FromArgb(20, 24, 30)
    Btn = [System.Drawing.Color]::FromArgb(35, 40, 50)
    Accent = [System.Drawing.Color]::FromArgb(0, 120, 215)
    Text = [System.Drawing.Color]::White
    DimText = [System.Drawing.Color]::FromArgb(160, 160, 160)
}

# ==============================================================================
# 4. FORM INIT
# ==============================================================================
$MainForm = New-Object System.Windows.Forms.Form
$MainForm.Text = "DamActivator"
$MainForm.Size = New-Object System.Drawing.Size(600, 850)
$MainForm.StartPosition = "CenterScreen"
$MainForm.FormBorderStyle = "FixedDialog"
$MainForm.MaximizeBox = $false
$MainForm.BackColor = $Colors.Bg

# Define UI Components EARLY
$txtLog = New-Object System.Windows.Forms.TextBox
$lblA = New-Object System.Windows.Forms.Label
# Fail button defined later

# Panels
$P_Main = New-Object System.Windows.Forms.Panel; $P_Main.Dock="Fill"; $null = $MainForm.Controls.Add($P_Main)
$P_Con = New-Object System.Windows.Forms.Panel; $P_Con.Dock="Fill"; $P_Con.Visible=$false; $null = $MainForm.Controls.Add($P_Con)
$P_Ent = New-Object System.Windows.Forms.Panel; $P_Ent.Dock="Fill"; $P_Ent.Visible=$false; $null = $MainForm.Controls.Add($P_Ent)
$P_Srv = New-Object System.Windows.Forms.Panel; $P_Srv.Dock="Fill"; $P_Srv.Visible=$false; $P_Srv.AutoScroll=$true; $null = $MainForm.Controls.Add($P_Srv)
$P_Srv_Gen = New-Object System.Windows.Forms.Panel; $P_Srv_Gen.Dock="Fill"; $P_Srv_Gen.Visible=$false; $null = $MainForm.Controls.Add($P_Srv_Gen)
$P_Srv_Edit = New-Object System.Windows.Forms.Panel; $P_Srv_Edit.Dock="Fill"; $P_Srv_Edit.Visible=$false; $P_Srv_Edit.AutoScroll=$true; $null = $MainForm.Controls.Add($P_Srv_Edit)
$P_Leg = New-Object System.Windows.Forms.Panel; $P_Leg.Dock="Fill"; $P_Leg.Visible=$false; $null = $MainForm.Controls.Add($P_Leg)
$P_Act = New-Object System.Windows.Forms.Panel; $P_Act.Dock="Fill"; $P_Act.Visible=$false; $null = $MainForm.Controls.Add($P_Act)
$P_Res = New-Object System.Windows.Forms.Panel; $P_Res.Dock="Fill"; $P_Res.Visible=$false; $null = $MainForm.Controls.Add($P_Res)

# --- HELPER FUNCTIONS ---

function Get-ImageFromFile($filename) {
    $path = Join-Path $PSScriptRoot $filename
    if (Test-Path $path) {
        return [System.Drawing.Image]::FromFile($path)
    }
    return $null
}

function Write-Log([string]$msg) {
    $txtLog.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $msg`r`n")
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Show-Recommendation {
    $os = (Get-WmiObject -Class Win32_OperatingSystem).Caption
    $rec = "Manual Selection Required"
    if ($os -match "Home") { $rec = "Consumer -> Windows Home" }
    elseif ($os -match "Pro") { $rec = "Consumer -> Windows Pro" }
    elseif ($os -match "Enterprise") { $rec = "Enterprise -> Windows Enterprise" }
    elseif ($os -match "Education") { $rec = "Enterprise -> Windows Education" }
    elseif ($os -match "Server 2025") { $rec = "Server -> Server 2025 -> Standard/Data" }
    elseif ($os -match "Server 2022") { $rec = "Server -> Server 2022 -> Standard/Data" }
    elseif ($os -match "Server 2019") { $rec = "Server -> Server 2019 -> Standard/Data" }
    elseif ($os -match "Server 2016") { $rec = "Server -> Server 2016 -> Standard/Data" }
    [System.Windows.Forms.MessageBox]::Show("Detected System: $os`n`nSuggested Selection:`n$rec", "DamActivator Suggestion", "OK", "Information")
}

function New-NavButton([string]$text, [int]$width, [int]$yPos, [scriptblock]$action, [bool]$isMain=$false, [object]$tagData=$null, [int]$xPos=$null) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text; $btn.Tag = $tagData; $btn.Size = New-Object System.Drawing.Size($width, 100)
    if ($xPos) { $btn.Location = New-Object System.Drawing.Point($xPos, $yPos) }
    else { 
        $formW = [int]$MainForm.ClientSize.Width
        $calcX = [int](($formW - $width) / 2)
        $btn.Location = New-Object System.Drawing.Point($calcX, $yPos)
        $btn.Size = New-Object System.Drawing.Size($width, 45)
    }
    $btn.FlatStyle = "Flat"
    if ($isMain) { $btn.BackColor = $Colors.Accent; $btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold) } 
    else { $btn.BackColor = $Colors.Btn; $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10) }
    $btn.ForeColor = $Colors.Text; $btn.FlatAppearance.BorderSize = 0; $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath; $rad = 15; $rect = New-Object System.Drawing.Rectangle(0,0,$btn.Width,$btn.Height)
    $path.AddArc($rect.X,$rect.Y,$rad,$rad,180,90); $path.AddArc($rect.X+$rect.Width-$rad,$rect.Y,$rad,$rad,270,90)
    $path.AddArc($rect.X+$rect.Width-$rad,$rect.Y+$rect.Height-$rad,$rad,$rad,0,90); $path.AddArc($rect.X,$rect.Y+$rect.Height-$rad,$rad,$rad,90,90); $path.CloseAllFigures()
    $btn.Region = New-Object System.Drawing.Region($path)
    $btn.Add_Click($action)
    return $btn
}

function New-RoundedButton([string]$text, [int]$width, [int]$yPos, [string]$tagData) {
    return New-NavButton $text $width $yPos { Invoke-Activation $this.Tag } $false $tagData
}

function Add-Header($panel, $title, $sub) {
    $t = New-Object System.Windows.Forms.Label; $t.Text = $title; $t.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold); $t.ForeColor = $Colors.Accent; $t.AutoSize = $true; $t.Location = New-Object System.Drawing.Point(30, 20); $null = $panel.Controls.Add($t)
    $s = New-Object System.Windows.Forms.Label; $s.Text = $sub; $s.Font = New-Object System.Drawing.Font("Segoe UI", 12); $s.ForeColor = $Colors.DimText; $s.AutoSize = $true; $s.Location = New-Object System.Drawing.Point(35, 70); $null = $panel.Controls.Add($s)
}

function Add-Footer($panel, [bool]$dock=$true, [int]$yPos=0) {
    if ($null -eq $panel) { return }
    $l = New-Object System.Windows.Forms.Label; $l.Text = "DamActivator (C)"; $l.ForeColor = $Colors.DimText; $l.AutoSize = $false; $l.TextAlign = "MiddleCenter"; $l.Height = 30
    if ($dock) { $l.Dock = "Bottom" } else { $l.Width = 580; $l.Location = New-Object System.Drawing.Point(0, $yPos) }
    if ($null -ne $l) { $null = $panel.Controls.Add($l) }
}

# --- FAIL HOME BUTTON (Global Scope) ---
$btnFailHome = New-NavButton "Return Home" 300 500 { $P_Act.Visible=$false; $P_Main.Visible=$true }
$btnFailHome.Visible = $false

function Invoke-Activation($EditionName) {
    $P_Main.Visible=$false; $P_Con.Visible=$false; $P_Ent.Visible=$false; $P_Srv_Gen.Visible=$false; $P_Srv_Edit.Visible=$false; $P_Leg.Visible=$false; $P_Act.Visible=$true
    
    # Reset UI
    $lblA.Text = "Activating..."; $lblA.ForeColor = $Colors.Accent; $btnFailHome.Visible = $false; $txtLog.Text = ""; Write-Log "Initializing..."
    
    $TargetKeys = $Keys[$EditionName]
    if ($TargetKeys.Contains("Key")) { $KeysToTry = @($TargetKeys["Key"]) } else { $KeysToTry = $TargetKeys.Values }
    
    try {
        Write-Log "Cleaning Registry..."; & cscript //nologo C:\Windows\System32\slmgr.vbs /cpky 2>&1 | Out-String | ForEach-Object { Write-Log $_.Trim() }
        Write-Log "Uninstalling Keys..."; & cscript //nologo C:\Windows\System32\slmgr.vbs /upk 2>&1 | Out-String | ForEach-Object { Write-Log $_.Trim() }
        $installedKey = $null; $installedName = "Unknown Edition"
        foreach ($k in $KeysToTry) {
            $keyName = "Unknown"; $TargetKeys.GetEnumerator() | ForEach-Object { if ($_.Value -eq $k) { $keyName = $_.Key } }
            Write-Log "Trying: $keyName..."; $res = & cscript //nologo C:\Windows\System32\slmgr.vbs /ipk $k 2>&1 | Out-String
            if ($res -match "successfully") { Write-Log "Key Accepted: $keyName"; $installedKey = $k; $installedName = $keyName; break } else { Write-Log "Key Rejected." }
        }
        if ($null -eq $installedKey) { throw "Could not install any valid key." }
        $activated = $false
        foreach ($server in $KmsServerList) {
            Write-Log "Connecting to $server..."; & cscript //nologo C:\Windows\System32\slmgr.vbs /skms $server 2>&1 | Out-String | ForEach-Object { Write-Log $_.Trim() }
            Write-Log "Activating..."; $res = & cscript //nologo C:\Windows\System32\slmgr.vbs /ato 2>&1 | Out-String
            if ($res -match "successfully" -or $res -match "Product activated") { Write-Log "SUCCESS!"; $activated = $true; break } else { Write-Log "Failed. Switching..." }
        }
        if ($activated) {
            Start-Sleep -s 1; $P_Act.Visible=$false; $P_Res.Visible=$true
            
            # --- BUILD RESULT SCREEN ---
            $P_Res.Controls.Clear()
            
            # 1. Edition Name (TOP)
            $lblEd = New-Object System.Windows.Forms.Label; $lblEd.Text = $installedName; $lblEd.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold); $lblEd.ForeColor = $Colors.Text; $lblEd.AutoSize = $false; $lblEd.Size = New-Object System.Drawing.Size(580, 50); $lblEd.TextAlign = "MiddleCenter"; $lblEd.Location = New-Object System.Drawing.Point(10, 30); $P_Res.Controls.Add($lblEd)

            # 2. Banner
            $img1 = Get-ImageFromFile "image_1.png"
            if ($img1) { $pb1 = New-Object System.Windows.Forms.PictureBox; $pb1.Image = $img1; $pb1.SizeMode = "AutoSize"; $pb1.Location = New-Object System.Drawing.Point(([int]($P_Res.Width - $pb1.Image.Width) / 2), 90); $P_Res.Controls.Add($pb1) } 
            else { $lblS = New-Object System.Windows.Forms.Label; $lblS.Text="Product Successfully Activated"; $lblS.ForeColor=[System.Drawing.Color]::LimeGreen; $lblS.Font=New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold); $lblS.AutoSize=$false; $lblS.Size=New-Object System.Drawing.Size(580,40); $lblS.TextAlign="MiddleCenter"; $lblS.Location=New-Object System.Drawing.Point(10,90); $P_Res.Controls.Add($lblS) }

            # 3. Main Graphic
            $img0 = Get-ImageFromFile "image_0.png"
            if ($img0) { $pb0 = New-Object System.Windows.Forms.PictureBox; $pb0.Image = $img0; $pb0.SizeMode = "AutoSize"; $pb0.Location = New-Object System.Drawing.Point(([int]($P_Res.Width - $pb0.Image.Width) / 2), 150); $P_Res.Controls.Add($pb0) } 
            else { $lblAc = New-Object System.Windows.Forms.Label; $lblAc.Text="ACTIVATED!"; $lblAc.ForeColor=[System.Drawing.Color]::LimeGreen; $lblAc.Font=New-Object System.Drawing.Font("Segoe UI",28,[System.Drawing.FontStyle]::Bold); $lblAc.AutoSize=$false; $lblAc.Size=New-Object System.Drawing.Size(580,100); $lblAc.TextAlign="MiddleCenter"; $lblAc.Location=New-Object System.Drawing.Point(10,200); $P_Res.Controls.Add($lblAc) }

            # 4. Button
            $btnReturn = New-NavButton "Return Home" 300 0 { $P_Res.Visible=$false; $P_Main.Visible=$true }; $btnReturn.Location = New-Object System.Drawing.Point(([int]($P_Res.Width - 300) / 2), 500); $P_Res.Controls.Add($btnReturn)

        } else { throw "All KMS servers failed." }
    } catch {
        Write-Log "ERROR: $($_.Exception.Message)"; $lblA.Text = "Activation Failed"; $lblA.ForeColor = [System.Drawing.Color]::Tomato; $btnFailHome.Visible = $true
    }
}

function Build-Grid($panel, $dataArray) {
    [int]$yS = 130; $i = 0
    foreach ($g in $dataArray) {
        $col = $i % 2; $xPos = if ($col -eq 0) { 25 } else { 305 }
        $row = [math]::Floor($i / 2); $currY = [int]($yS + ($row * 110))
        $fullText = "$($g.T)`n$($g.D)`n$($g.R) | $($g.E)"
        if ($g.ContainsKey("B")) {
            $action = { Show-ServerEditions $this.Tag.Title $this.Tag.Editions }; $tagPayload = @{ Title=$g.T; Editions=$g.B }
            $null = $panel.Controls.Add((New-NavButton $fullText 270 $currY $action $false $tagPayload $xPos))
        } else {
            $action = { Invoke-Activation $this.Tag }; $null = $panel.Controls.Add((New-NavButton $fullText 270 $currY $action $false $g.Key $xPos))
        }
        $i++
    }
    $totalRows = [math]::Ceiling($dataArray.Count / 2); return [int]($yS + ($totalRows * 110) + 20)
}

function Show-ServerEditions([string]$GenName, [array]$Buttons) {
    $P_Srv_Gen.Visible = $false; $P_Srv_Edit.Controls.Clear(); $P_Srv_Edit.Visible = $true
    Add-Header $P_Srv_Edit $GenName "Select Edition"; $yBack = Build-Grid $P_Srv_Edit $Buttons
    $null = $P_Srv_Edit.Controls.Add((New-NavButton "Back" 200 $yBack { $P_Srv_Edit.Visible=$false; $P_Srv_Gen.Visible=$true })); Add-Footer $P_Srv_Edit $false ($yBack + 60)
}

# --- DATA DEFINITIONS ---
$con_data = @( @{ T="Windows Home"; D="Standard Consumer"; R="Rel: 2015"; E="EOL: Oct 2025"; Key="Windows Home and Home N" }, @{ T="Windows Pro"; D="Small Business/Power"; R="Rel: 2015"; E="EOL: Oct 2025"; Key="Windows Pro and Pro N" }, @{ T="Windows Home SL"; D="Single Language"; R="Rel: 2015"; E="EOL: Oct 2025"; Key="Windows Home SL and Home SL N" } )
$ent_data = @( @{ T="Enterprise"; D="Volume Lic"; R="Rel: Various"; E="EOL: Varies"; Key="Windows Enterprise and Enterprise N and Enterprise G" }, @{ T="Education"; D="Academic Lic"; R="Rel: Various"; E="EOL: Varies"; Key="Windows Education" }, @{ T="Pro Workstation"; D="High-end HW"; R="Rel: 2017"; E="EOL: Varies"; Key="Windows Pro for Workstations" }, @{ T="Pro Education"; D="K-12 Specific"; R="Rel: 2016"; E="EOL: Varies"; Key="Windows Pro Education" }, @{ T="Enterprise LTSC"; D="Long Term"; R="Rel: 2024/21/19"; E="EOL: 5-10 Yrs"; Key="Windows Enterprise LTSC (2024&2021&2019)" }, @{ T="IoT Enterprise"; D="Embedded"; R="Rel: 2024"; E="EOL: 10 Yrs"; Key="Windows IoT LTSC 2024" } )
$leg_data = @( @{ T="Windows 8.1"; D="Start Button"; R="Rel: 2013"; E="EOL: Jan 2023"; Key="Windows 8.1 Pro and Pro N" }, @{ T="Windows 8"; D="Metro UI"; R="Rel: 2012"; E="EOL: Jan 2016"; Key="Windows 8 Pro and Pro N" }, @{ T="Windows 7"; D="Fan Favorite"; R="Rel: 2009"; E="EOL: Jan 2020"; Key="Windows 7 Professional, Professional N, and Professional E" }, @{ T="Windows Vista"; D="Aero Glass"; R="Rel: 2007"; E="EOL: Apr 2017"; Key="Windows Vista Business and Business N" } )
$gen_btns = @(
    @{ T="Server 2025"; D="AI & Cloud"; R="Rel: 2024"; E="EOL: 2034"; B=@( @{ T="Standard"; D="2 VMs Included"; R="Nov 2024"; E="Oct 2034"; Key="Windows Server 2025 Standard" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Nov 2024"; E="Oct 2034"; Key="Windows Server 2025 Datacenter" }, @{ T="Azure Edit."; D="HCI & Hotpatch"; R="Nov 2024"; E="Oct 2034"; Key="Windows Server 2025 Datacenter (Azure)" } ) },
    @{ T="Server 2022"; D="Secure Core"; R="Rel: 2021"; E="EOL: 2031"; B=@( @{ T="Standard"; D="2 VMs Included"; R="Aug 2021"; E="Oct 2031"; Key="Windows Server 2022 Standard" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Aug 2021"; E="Oct 2031"; Key="Windows Server 2022 Datacenter" }, @{ T="Azure Edit."; D="HCI Features"; R="Aug 2021"; E="Oct 2031"; Key="Windows Server 2022 Datacenter (Azure)" } ) },
    @{ T="Server 2019"; D="Hybrid Cloud"; R="Rel: 2018"; E="EOL: 2029"; B=@( @{ T="Standard"; D="2 VMs Included"; R="Oct 2018"; E="Jan 2029"; Key="Windows Server 2019 Standard" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Oct 2018"; E="Jan 2029"; Key="Windows Server 2019 Datacenter" }, @{ T="Essentials"; D="25 Users/50 Dev"; R="Oct 2018"; E="Jan 2029"; Key="Windows Server 2019 Essentials" } ) },
    @{ T="Server 2016"; D="Identity Focus"; R="Rel: 2016"; E="EOL: 2027"; B=@( @{ T="Standard"; D="2 VMs Included"; R="Oct 2016"; E="Jan 2027"; Key="Windows Server 2016 Standard" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Oct 2016"; E="Jan 2027"; Key="Windows Server 2016 Datacenter" }, @{ T="Essentials"; D="Small Business"; R="Oct 2016"; E="Jan 2027"; Key="Windows Server 2016 Essentials" } ) },
    @{ T="Server 2012 R2"; D="Cloud OS"; R="Rel: 2013"; E="EOL: 2023"; B=@( @{ T="Standard"; D="2 VMs Included"; R="Oct 2013"; E="Oct 2023"; Key="Windows Server 2012 R2 Standard" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Oct 2013"; E="Oct 2023"; Key="Windows Server 2012 R2 Datacenter" }, @{ T="Essentials"; D="Small Business"; R="Oct 2013"; E="Oct 2023"; Key="Windows Server 2012 R2 Essentials" } ) },
    @{ T="Server 2012"; D="First Cloud OS"; R="Rel: 2012"; E="EOL: 2023"; B=@( @{ T="Standard"; D="2 VMs Included"; R="Sep 2012"; E="Oct 2023"; Key="Windows Server 2012 Standard" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Sep 2012"; E="Oct 2023"; Key="Windows Server 2012 Datacenter" }, @{ T="Essentials"; D="Small Business"; R="Sep 2012"; E="Oct 2023"; Key="Windows Server 2012 Essentials" }, @{ T="Multipoint"; D="Shared Comp."; R="Sep 2012"; E="Oct 2023"; Key="Windows Server 2012 Multipoint Standard" }, @{ T="Multipoint Prem"; D="Premium"; R="Sep 2012"; E="Oct 2023"; Key="Windows Server 2012 Multipoint Premium" }, @{ T="Server 2012 N"; D="Europe Ed."; R="Sep 2012"; E="Oct 2023"; Key="Windows Server 2012 N" }, @{ T="Server 2012 SL"; D="Single Lang"; R="Sep 2012"; E="Oct 2023"; Key="Windows Server 2012 SL" } ) },
    @{ T="Server 2008 R2"; D="Win7 Kernel"; R="Rel: 2009"; E="EOL: 2020"; B=@( @{ T="Standard"; D="Virtualization"; R="Oct 2009"; E="Jan 2020"; Key="Windows Server 2008 R2 Standard" }, @{ T="Enterprise"; D="High Availability"; R="Oct 2009"; E="Jan 2020"; Key="Windows Server 2008 R2 Enterprise" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Oct 2009"; E="Jan 2020"; Key="Windows Server 2008 R2 Datacenter" }, @{ T="Web Server"; D="IIS Only"; R="Oct 2009"; E="Jan 2020"; Key="Windows Server 2008 R2 Web Server" }, @{ T="HPC Edition"; D="Cluster Compute"; R="Oct 2009"; E="Jan 2020"; Key="Windows Server 2008 R2 HPC" }, @{ T="Itanium"; D="IA-64 Arch"; R="Oct 2009"; E="Jan 2020"; Key="Windows Server 2008 R2 for IBS" } ) },
    @{ T="Server 2008"; D="Vista Kernel"; R="Rel: 2008"; E="EOL: 2020"; B=@( @{ T="Standard"; D="Base Server"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 Standard" }, @{ T="Enterprise"; D="Clustering Support"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 Enterprise" }, @{ T="Datacenter"; D="Unlimited VMs"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 Datacenter" }, @{ T="Web Server"; D="IIS Only"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 Web Server" }, @{ T="HPC"; D="High Performance"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 HPC" }, @{ T="Standard NoHV"; D="No Hyper-V"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 Standard (No Hyper-V)" }, @{ T="Enterp. NoHV"; D="No Hyper-V"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 Enterprise (No Hyper-V)" }, @{ T="DataCen NoHV"; D="No Hyper-V"; R="Feb 2008"; E="Jan 2020"; Key="Windows Server 2008 Datacenter (No Hyper-V)" } ) },
    @{ T="Semi-Annual"; D="v1709 / v1803"; R="Various"; E="EOL: Expired"; B=@( @{ T="v.1803"; D="Standard"; R="Apr 2018"; E="Nov 2019"; Key="Windows Server v.1803 Standard" }, @{ T="v.1803 DC"; D="Datacenter"; R="Apr 2018"; E="Nov 2019"; Key="Windows Server v.1803 Datacenter" }, @{ T="v.1709"; D="Standard"; R="Oct 2017"; E="Apr 2019"; Key="Windows Server v.1709 Standard" }, @{ T="v.1709 DC"; D="Datacenter"; R="Oct 2017"; E="Apr 2019"; Key="Windows Server v.1709 Datacenter" } ) }
)

# --- GUI CONSTRUCTION ---
Add-Header $P_Main "DamActivator" "Project by Branchy18269"
$lblK = New-Object System.Windows.Forms.Label; $lblK.Text = "KMS Provided by msguides"; $lblK.ForeColor = $Colors.DimText; $lblK.AutoSize = $true; $lblK.Location = New-Object System.Drawing.Point(35, 100); $null = $P_Main.Controls.Add($lblK)
$lblDesc = New-Object System.Windows.Forms.Label; $lblDesc.Text = "This application allows you to activate all possible versions of Windows that support the KMS License Activation. It has all product keys preloaded and is 100% legal. Issues? contact@damvan.ca"; $lblDesc.ForeColor = $Colors.Text; $lblDesc.Font = New-Object System.Drawing.Font("Segoe UI", 10); $lblDesc.Location = New-Object System.Drawing.Point(35, 140); $lblDesc.Size = New-Object System.Drawing.Size(520, 60); $null = $P_Main.Controls.Add($lblDesc)
$null = $P_Main.Controls.Add((New-NavButton "Check System & Recommend Key" 520 220 { Show-Recommendation } $true))
$lblSel = New-Object System.Windows.Forms.Label; $lblSel.Text = "Select Your Windows"; $lblSel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold); $lblSel.ForeColor = $Colors.Text; $lblSel.AutoSize = $true; $lblSel.Location = New-Object System.Drawing.Point(30, 280); $null = $P_Main.Controls.Add($lblSel)
$null = $P_Main.Controls.Add((New-NavButton "Consumer Windows (Home/Pro)" 520 330 { $P_Main.Visible=$false; $P_Con.Visible=$true })); $null = $P_Main.Controls.Add((New-NavButton "Enterprise Windows (Edu/Ent)" 520 390 { $P_Main.Visible=$false; $P_Ent.Visible=$true })); $null = $P_Main.Controls.Add((New-NavButton "Server (2008-2025)" 520 450 { $P_Main.Visible=$false; $P_Srv_Gen.Visible=$true })); $null = $P_Main.Controls.Add((New-NavButton "Legacy Windows (Vista/7/8/8.1)" 520 510 { $P_Main.Visible=$false; $P_Leg.Visible=$true })); Add-Footer $P_Main

# Build the other grids using the now-defined data
Add-Header $P_Con "Consumer" "For Windows 10 and 11"; $yC = Build-Grid $P_Con $con_data; $null = $P_Con.Controls.Add((New-NavButton "Back" 200 $yC { $P_Con.Visible=$false; $P_Main.Visible=$true })); Add-Footer $P_Con
Add-Header $P_Ent "Enterprise" "For Workstations & Edu"; $yE = Build-Grid $P_Ent $ent_data; $null = $P_Ent.Controls.Add((New-NavButton "Back" 200 $yE { $P_Ent.Visible=$false; $P_Main.Visible=$true })); Add-Footer $P_Ent
Add-Header $P_Leg "Legacy" "Vista / 7 / 8 / 8.1"; $yL = Build-Grid $P_Leg $leg_data; $null = $P_Leg.Controls.Add((New-NavButton "Back" 200 $yL { $P_Leg.Visible=$false; $P_Main.Visible=$true })); Add-Footer $P_Leg
Add-Header $P_Srv_Gen "Windows Server" "Select Generation"; $yS = Build-Grid $P_Srv_Gen $gen_btns; $null = $P_Srv_Gen.Controls.Add((New-NavButton "Back" 200 $yS { $P_Srv_Gen.Visible=$false; $P_Main.Visible=$true })); Add-Footer $P_Srv_Gen

# --- ACTIVATION UI ---
$lblA.Text="Activating..."; $lblA.Font=$lblSel.Font; $lblA.ForeColor=$Colors.Accent; $lblA.Location=New-Object System.Drawing.Point(30,30); $lblA.AutoSize=$true; $null = $P_Act.Controls.Add($lblA)
$txtLog.Multiline=$true; $txtLog.ScrollBars="Vertical"; $txtLog.Location=New-Object System.Drawing.Point(30,80); $txtLog.Size=New-Object System.Drawing.Size(520,400); $txtLog.BackColor=[System.Drawing.Color]::Black; $txtLog.ForeColor=[System.Drawing.Color]::Lime; $txtLog.Font=New-Object System.Drawing.Font("Consolas",10); $null = $P_Act.Controls.Add($txtLog)
$null = $P_Act.Controls.Add($btnFailHome) # Add the fail button to the panel

# --- RESULT ---
$null = $P_Res.Controls.Add((New-NavButton "Return Home" 300 500 { $P_Res.Visible=$false; $P_Main.Visible=$true }))

$null = $MainForm.ShowDialog()