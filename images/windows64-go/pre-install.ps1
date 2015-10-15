[CmdletBinding()]
Param(
   [Parameter()]
   [string]$machine_name="Win64En"
)

# Get Chatty with output - helps debug
#$VerbosePreference="continue"
#$DebugPreference="continue"

# Restart Transcript
Stop-Transcript
Start-Transcript -Path C:\Users\Administrator\image\preinstall.txt -Force

# everyone needs a little help
Update-Help -Force

# This gets rid of those OTT IE security policies on Windows Server.
function Disable-IEESC {
  $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
  $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
  Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
  Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
  Stop-Process -Name Explorer
  Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

$le.Log("Disabling IEESC")
Disable-IEESC

Rename-Computer -NewName $machine_name

# this is the chocolatey package manager
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# and this is the latest powershell (5 at time of writing
choco install -y powershell -pre -force

Stop-Transcript
Restart-Computer