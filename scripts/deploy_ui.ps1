$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$scriptDir = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$uiRoot = if ($args.Count -ge 1 -and -not [string]::IsNullOrWhiteSpace($args[0])) {
    $args[0]
} else {
    Join-Path $scriptDir '..\..\invest_userinterfaces'
}

$deployDir = if ($args.Count -ge 2 -and -not [string]::IsNullOrWhiteSpace($args[1])) {
    $args[1]
} else {
    Join-Path $scriptDir '..\deploy'
}

if (-not (Test-Path -LiteralPath $uiRoot -PathType Container)) {
    Write-Error "UI root directory not found: $uiRoot"
    exit 1
}

New-Item -ItemType Directory -Path $deployDir -Force | Out-Null

$resolvedUiRoot = (Resolve-Path -LiteralPath $uiRoot).Path
$resolvedDeployDir = (Resolve-Path -LiteralPath $deployDir).Path

Write-Host "UI root: $resolvedUiRoot"
Write-Host "Deploy dir: $resolvedDeployDir"

function Copy-UiDist {
    param(
        [Parameter(Mandatory = $true)]
        [string] $UiName
    )

    $srcDir = Join-Path $resolvedUiRoot (Join-Path $UiName "dist\$UiName")
    $destDir = Join-Path $resolvedDeployDir (Join-Path $UiName "dist\$UiName")

    if (-not (Test-Path -LiteralPath $srcDir -PathType Container)) {
        Write-Error "Source dist directory not found for ${UiName}: $srcDir"
        return
    }

    # Keep the destination directory itself stable so running bind mounts stay valid.
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    Get-ChildItem -LiteralPath $destDir -Force | Remove-Item -Recurse -Force
    Copy-Item -Path (Join-Path $srcDir '*') -Destination $destDir -Recurse -Force

    Write-Host "Copied $UiName dist -> $destDir"
}

Copy-UiDist 'adminui'
Copy-UiDist 'consultui'

Write-Host 'UI deployment complete.'
