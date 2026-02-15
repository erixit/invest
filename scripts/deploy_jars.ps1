param(
    [string]$MicroservicesRoot = (Join-Path $PSScriptRoot "..\..\invest_microservices"),
    [string]$DeployDir = (Join-Path $PSScriptRoot "..\deploy")
)

$ErrorActionPreference = "Stop"

function Get-LatestJar {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDir,

        [Parameter(Mandatory = $true)]
        [string]$ArtifactPrefix
    )

    if (-not (Test-Path -Path $TargetDir)) {
        throw "Target directory not found: $TargetDir"
    }

    $jar = Get-ChildItem -Path $TargetDir -Filter "$ArtifactPrefix-*.jar" -File |
        Where-Object { $_.Name -notmatch 'sources|javadoc|original' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $jar) {
        throw "No jar found for artifact '$ArtifactPrefix' in $TargetDir"
    }

    return $jar
}

$services = @(
    @{ Module = "corems"; Artifact = "corems" },
    @{ Module = "adminapi"; Artifact = "adminapi" },
    @{ Module = "adminms"; Artifact = "adminms" },
    @{ Module = "consultms"; Artifact = "consultms" },
    @{ Module = "messaging"; Artifact = "messaging" }
)

$resolvedMicroservicesRoot = (Resolve-Path $MicroservicesRoot).Path
if (-not (Test-Path -Path $DeployDir)) {
    New-Item -Path $DeployDir -ItemType Directory -Force | Out-Null
}
$resolvedDeployDir = (Resolve-Path $DeployDir).Path

Write-Host "Microservices root: $resolvedMicroservicesRoot"
Write-Host "Deploy dir: $resolvedDeployDir"

foreach ($service in $services) {
    $targetDir = Join-Path $resolvedMicroservicesRoot (Join-Path $service.Module "target")
    $jar = Get-LatestJar -TargetDir $targetDir -ArtifactPrefix $service.Artifact
    $destPath = Join-Path $resolvedDeployDir $jar.Name
    Copy-Item -Path $jar.FullName -Destination $destPath -Force
    Write-Host ("Copied {0} -> {1}" -f $jar.Name, $destPath)
}

Write-Host "JAR deployment complete."
