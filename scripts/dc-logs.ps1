$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Set-Location $projectDir

# Default to the docker profile unless caller already set COMPOSE_PROFILES.
if (-not $env:COMPOSE_PROFILES) {
    $env:COMPOSE_PROFILES = "docker"
}

if ($args.Count -gt 2) {
    Write-Error "Usage: .\scripts\dc-logs.ps1 [-f] [service]"
    exit 1
}

$follow = $false
$remainingArgs = @($args)
if ($remainingArgs.Count -gt 0 -and ($remainingArgs[0] -eq "-f" -or $remainingArgs[0] -eq "--follow")) {
    $follow = $true
    $remainingArgs = $remainingArgs[1..($remainingArgs.Count - 1)]
}

$requestedService = if ($remainingArgs.Count -eq 1) { $remainingArgs[0] } else { $null }

$composeFiles = @("docker-compose.windows.yml")

$composeArgs = @("compose")
foreach ($file in $composeFiles) {
    $composeArgs += @("-f", $file)
}

Write-Host "Using compose file(s): $($composeFiles -join ', ')"

$availableServices = @(docker @composeArgs config --services)

if ($requestedService) {
    if ($availableServices -notcontains $requestedService) {
        Write-Error "Unknown service: $requestedService`nAvailable services: $($availableServices -join ' ')"
        exit 1
    }
    $services = @($requestedService)
} else {
    $services = @($availableServices | Where-Object { $_ -notmatch "_debug$" })
}

if ($services.Count -gt 0) {
    if ($follow) {
        docker @composeArgs logs -f $services
    } else {
        docker @composeArgs logs $services
    }
} else {
    Write-Host "No services selected."
}

