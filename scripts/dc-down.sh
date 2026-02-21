#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "${script_dir}/.." && pwd)"
cd "${project_dir}"

# Default to the docker profile unless caller already set COMPOSE_PROFILES.
export COMPOSE_PROFILES="${COMPOSE_PROFILES:-docker}"

mapfile -t services < <(docker compose config --services | grep -Ev '_debug$' || true)
if ((${#services[@]} > 0)); then
  docker compose stop "${services[@]}"
  docker compose rm -f "${services[@]}"
fi
