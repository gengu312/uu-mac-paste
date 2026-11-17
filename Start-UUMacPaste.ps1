param(
    [Parameter(Mandatory = $true)][string]$AutoHotkeyPath,
    [string]$ScriptPath = (Join-Path $PSScriptRoot 'UU-Mac-Paste.ahk')
)

$ErrorActionPreference = 'Stop'
$exe = (Get-Item -LiteralPath $AutoHotkeyPath).FullName
$script = (Get-Item -LiteralPath $ScriptPath).FullName
$sessionId = (Get-Process -Id $PID).SessionId

while (!(Get-Process -Name GameViewer -ErrorAction SilentlyContinue |
        Where-Object SessionId -eq $sessionId)) {
    Start-Sleep -Milliseconds 500
}

Start-Process -FilePath $exe -ArgumentList ('"' + $script + '"') -WorkingDirectory (Split-Path -Parent $script) -WindowStyle Hidden
