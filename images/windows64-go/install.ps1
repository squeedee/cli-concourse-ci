[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$deploymentDir,

   [Parameter(Mandatory=$True,Position=2)]
   [string]$atcHost
)

# Get Chatty with output - helps debug
#$VerbosePreference="continue"
#$DebugPreference="continue"

# Restart Transcript
Stop-Transcript
Start-Transcript -Path C:\Users\Administrator\image\install.log.txt -Force

Install-Package git -RequiredVersion 2.5.3 -Provider Chocolatey -Force -ForceBootstrap
#Install-Package putty.install -RequiredVersion 0.65 -Provider Chocolatey -Force -ForceBootstrap

# register Nuget package provider so we can get Pscx (and other things)
Register-PackageSource NuGet -Location 'https://www.nuget.org/api/v2' -ForceBootstrap -ProviderName NuGet

# the Pscx module gives us some really useful Powershell cmdlets and modules (libraries)
Install-Module Pscx -Force

# Make psgallery modules not prompt  on install
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# nssm is a service-from-anything tool
choco install nssm -y

# get houdini
Invoke-WebRequest 'https://github.com/vito/houdini/releases/download/2015-10-09/houdini_windows_amd64.exe' -OutFile 'C:\windows\system32\houdini.exe' 

#make houdini launch as a service
nssm install Houdini C:\Windows\System32\houdini.exe
nssm set Houdini AppParameters "-depot z:\containers"
nssm set Houdini Description "Houdini service allowing machine to act as a concourse agent"
nssm set Houdini DisplayName "Houdini Garden Emulator *"
nssm set Houdini Start "SERVICE_AUTO_START"
nssm set Houdini AppStdOut "z:\houdini.log.txt"
nssm set Houdini AppStdErr "z:\houdini.log.txt"

# you can ignore a message saying "nssm: Houdini: Unexpected status SERVICE_PAUSED in response to START 
nssm start Houdini

# get our TSA key
Copy-item (Join-Path $deploymentDir artifacts\keypair\id_rsa_concourse_windows_workers ) C:\Users\Administrator\image

# cygwin is needed for ssh
choco install cyg-get -y
cyg-get openssh

echo "$atcHost C:\Users\Administrator\image\id_rsa_concourse_windows_workers"
#make Concourse tunnel launch as a service
nssm install ConcourseTunnel powershell.exe 
nssm set ConcourseTunnel AppParameters "-File C:\Users\Administrator\image\HoudiniHeartbeat.ps1 $atcHost C:\Users\Administrator\image\id_rsa_concourse_windows_workers"
nssm set ConcourseTunnel Description "Concourse worker tunnel for Houdini"
nssm set ConcourseTunnel DisplayName "Concourse Tunnel *"
nssm set ConcourseTunnel Start "SERVICE_AUTO_START"
nssm set ConcourseTunnel AppStdOut "z:\concoursetunnel.log.txt"
nssm set ConcourseTunnel AppStdErr "z:\concoursetunnel.log.txt"

# you can ignore a message saying "nssm: ConcourseTunnel: Unexpected status SERVICE_PAUSED in response to START 
# SERVICE_STOPPED on the other hand, is bad.
nssm start ConcourseTunnel

# ALERT! You have to manually change the service to run as administrator (to deal with ssh /dev/tty error)
# FIXME: Lets fix this!

Stop-Transcript
#Restart-Computer