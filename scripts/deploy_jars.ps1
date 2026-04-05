$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$microservicesRoot = if ($args.Count -ge 1) { $args[0] } else { Join-Path $scriptDir "..\..\invest_microservices" }
$deployDir = if ($args.Count -ge 2) { $args[1] } else { Join-Path $scriptDir "..\deploy" }

if (-not (Test-Path -Path $microservicesRoot)) {
    Write-Error "Target directory not found: $microservicesRoot"
    exit 1
}

New-Item -ItemType Directory -Path $deployDir -Force | Out-Null

$resolvedMicroservicesRoot = (Resolve-Path $microservicesRoot).Path
$resolvedDeployDir = (Resolve-Path $deployDir).Path

Write-Host "Microservices root: $resolvedMicroservicesRoot"
Write-Host "Deploy dir: $resolvedDeployDir"

$deployItems = @(
    @{ Module = "corems"; Artifact = "corems" },
    @{ Module = "adminms"; Artifact = "adminms" },
    @{ Module = "consultms"; Artifact = "consultms" },
    @{ Module = "messaging"; Artifact = "messaging" }
)

function Get-LatestJar {
    param(
        [string]$TargetDir,
        [string]$ArtifactPrefix
    )

    if (-not (Test-Path -Path $TargetDir)) {
        Write-Error "Target directory not found: $TargetDir"
        return $null
    }

    $jar = Get-ChildItem -Path $TargetDir -Filter "$ArtifactPrefix-*.jar" -File |
        Where-Object { $_.Name -notmatch '(sources|javadoc|original)' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $jar) {
        Write-Error "No jar found for artifact '$ArtifactPrefix' in $TargetDir"
        return $null
    }

    return $jar.FullName
}

foreach ($item in $deployItems) {
    $module = $item.Module
    $artifact = $item.Artifact
    $targetDir = Join-Path $resolvedMicroservicesRoot "$module\target"

    $jarPath = Get-LatestJar -TargetDir $targetDir -ArtifactPrefix $artifact
    if (-not $jarPath) { exit 1 }

    $jarName = Split-Path $jarPath -Leaf
    $destPath = Join-Path $resolvedDeployDir $jarName

    Copy-Item -Path $jarPath -Destination $destPath -Force
    Write-Host "Copied $jarName -> $destPath"
}

Write-Host "JAR deployment complete."
