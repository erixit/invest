#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.debian.yml}"

exec "${script_dir}/dc-down.sh" "$@"
