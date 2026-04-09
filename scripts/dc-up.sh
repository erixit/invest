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

compose_files=()
if [[ -n "${COMPOSE_FILE:-}" ]]; then
  IFS=':' read -r -a compose_files <<< "${COMPOSE_FILE}"
else
  case "${OSTYPE:-}" in
    linux*)
      compose_files=("docker-compose.yml")
      ;;
    msys*|cygwin*|win32*)
      compose_files=("docker-compose.windows.yml")
      ;;
    *)
      compose_files=("docker-compose.yml")
      ;;
  esac
fi

compose_cmd=(docker compose)
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
