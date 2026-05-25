#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "${script_dir}/.." && pwd)"
cd "${project_dir}"

# Default to the docker profile unless caller already set COMPOSE_PROFILES.
export COMPOSE_PROFILES="${COMPOSE_PROFILES:-docker}"

if (($# > 1)); then
  echo "Usage: $0 [service]" >&2
  exit 1
fi
requested_service="${1:-}"

compose_files=("docker-compose.debian.yml")
env_file="${project_dir}/.env"

compose_cmd=(docker compose)
if [[ -f "${env_file}" ]]; then
  compose_cmd+=( --env-file "${env_file}" )
  echo "Using env file: ${env_file}"
fi

for required_var in INVEST_DB_PASSWORD INVEST_ARTEMIS_PASSWORD; do
  if [[ -z "${!required_var:-}" ]] && ! grep -Eq "^[[:space:]]*${required_var}[[:space:]]*=[[:space:]]*.+" "${env_file}" 2>/dev/null; then
    echo "${required_var} must be set in ${env_file} or in the current environment." >&2
    exit 1
  fi
done

for file in "${compose_files[@]}"; do
  compose_cmd+=( -f "$file" )
done

echo "Using compose file(s): ${compose_files[*]}"

mapfile -t available_services < <("${compose_cmd[@]}" config --services || true)

if [[ -n "${requested_service}" ]]; then
  if ! printf '%s\n' "${available_services[@]}" | grep -Fxq "${requested_service}"; then
    echo "Unknown service: ${requested_service}" >&2
    echo "Available services: ${available_services[*]}" >&2
    exit 1
  fi
  services=("${requested_service}")
else
  mapfile -t services < <(printf '%s\n' "${available_services[@]}" | grep -Ev '_debug$' || true)
fi

if ((${#services[@]} > 0)); then
  "${compose_cmd[@]}" up -d "${services[@]}"
else
  echo "No services selected."
fi
