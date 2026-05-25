$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Set-Location $projectDir

# Default to the docker profile unless caller already set COMPOSE_PROFILES.
if (-not $env:COMPOSE_PROFILES) {
    $env:COMPOSE_PROFILES = "docker"
}

if ($args.Count -gt 1) {
    Write-Error "Usage: .\scripts\dc-up.ps1 [service]"
    exit 1
}

$requestedService = if ($args.Count -eq 1) { $args[0] } else { $null }

$composeFiles = @("docker-compose.windows.yml")
$envFile = Join-Path $projectDir ".env"

$composeArgs = @("compose")
if (Test-Path -LiteralPath $envFile) {
    $composeArgs += @("--env-file", $envFile)
    Write-Host "Using env file: $envFile"
}

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
    docker @composeArgs up -d $services
} else {
    Write-Host "No services selected."
}

