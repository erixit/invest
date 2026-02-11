$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Set-Location $projectDir

# Default to the docker profile unless caller already set COMPOSE_PROFILES.
if (-not $env:COMPOSE_PROFILES) {
    $env:COMPOSE_PROFILES = "docker"
}

$services = docker compose config --services | Where-Object { $_ -notmatch "_debug$" }
if ($services) {
    docker compose up -d $services
}
