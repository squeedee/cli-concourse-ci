[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True, Position=1)]
   [string]$atcHost,
   [Parameter(Mandatory=$True, Position=2)]
   [string]$atcKey
)

echo "{`"name`":`"$env:computername`", `"platform`":`"windows`"}" | `
  c:\tools\cygwin\bin\ssh `
  -t `
  -o UserKnownHostsFile=/dev/null `
  -o StrictHostKeyChecking=no `
  -o GlobalKnownHostsFile=/dev/null `
  -vvv `
  -i $atcKey `
  -R 0.0.0.0:0:127.0.0.1:7777 `
  -o ServerAliveInterval=10 `
  -p 2222 $atcHost `
  forward-worker
