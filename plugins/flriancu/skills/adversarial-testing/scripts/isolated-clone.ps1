#Requires -Version 7
<#
  Makes an isolated copy of a repository for one testing agent: a clone of the committed state,
  its own dependency install (never shared with the real checkout: tool caches live inside
  node_modules), and free TCP ports to run its servers on.

    pwsh isolated-clone.ps1 -Repo D:\code\app -Dest C:\scratch\ut\ux -Ports 2
    pwsh isolated-clone.ps1 -Repo D:\code\app -Dest C:\scratch\ut\data -NoInstall

  Prints the clone path and the ports as JSON on the last line, e.g.
    {"clone":"C:\\scratch\\ut\\ux","ports":[51834,51835]}
  The clone holds the last commit only: uncommitted changes in the real repo are not in it
  (say so in the agent's brief when that matters).
#>
param(
  [Parameter(Mandatory)][string]$Repo,
  [Parameter(Mandatory)][string]$Dest,
  [int]$Ports = 2,
  [switch]$NoInstall
)
$ErrorActionPreference = 'Stop'

if (Test-Path -LiteralPath $Dest) { throw "$Dest already exists; pick a new folder per agent." }
# --no-hardlinks: hardlinks fail across drives, and a clone must never share objects it could alter
git clone --quiet --no-hardlinks $Repo $Dest
if ($LASTEXITCODE) { throw "git clone failed" }

if (-not $NoInstall) {
  Push-Location $Dest
  try {
    if (Test-Path package-lock.json) { npm ci --prefer-offline --no-audit --no-fund | Out-Host }
    elseif (Test-Path pnpm-lock.yaml) { pnpm install --frozen-lockfile | Out-Host }
    elseif (Test-Path yarn.lock) { yarn install --frozen-lockfile | Out-Host }
    elseif (Test-Path package.json) { npm install --no-audit --no-fund | Out-Host }
    if ($LASTEXITCODE) { throw "dependency install failed in $Dest" }
  } finally { Pop-Location }
}

# Free ports: ask the OS for ephemeral ones (port 0), then release them for the agent's servers.
$free = foreach ($i in 1..$Ports) {
  $l = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
  $l.Start(); $p = $l.LocalEndpoint.Port; $l.Stop(); $p
}
[ordered]@{ clone = (Resolve-Path -LiteralPath $Dest).Path; ports = @($free) } | ConvertTo-Json -Compress
