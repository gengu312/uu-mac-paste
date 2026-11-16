param([Parameter(Mandatory = $true)][string]$OutputPath)

$ErrorActionPreference = 'Stop'
$cliPath = Get-Process -Name GameViewer -ErrorAction SilentlyContinue |
    Where-Object Path |
    ForEach-Object { Join-Path (Split-Path -Parent $_.Path) 'uuyc-cli.exe' } |
    Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
    Select-Object -First 1
if (!$cliPath) { exit 1 }
$cli = New-Object System.Diagnostics.Process
$cli.StartInfo.FileName = $cliPath
$cli.StartInfo.Arguments = 'device list --json'
$cli.StartInfo.UseShellExecute = $false
$cli.StartInfo.CreateNoWindow = $true
$cli.StartInfo.RedirectStandardOutput = $true
$cli.StartInfo.StandardOutputEncoding = [Text.Encoding]::UTF8
try {
    [void]$cli.Start()
    $reply = $cli.StandardOutput.ReadToEndAsync()
    if (!$cli.WaitForExit(4000)) {
        $cli.Kill()
        exit 1
    }
    if ($cli.ExitCode -ne 0) { exit 1 }
    $list = $reply.GetAwaiter().GetResult() | ConvertFrom-Json
    if (!$list.success -or $null -eq $list.data.items) { exit 1 }

    $names = @($list.data.items | Group-Object -Property deviceName | ForEach-Object {
        if ($_.Count -eq 1 -and $_.Group[0].platform -ceq 'macOS' -and $_.Name -notmatch '[\r\n]') {
            [string]$_.Name
        }
    })
    [IO.File]::WriteAllLines($OutputPath, [string[]]$names, [Text.UTF8Encoding]::new($false))
} finally {
    $cli.Dispose()
}
