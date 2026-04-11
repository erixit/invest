#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "${script_dir}/.." && pwd)"
cd "${project_dir}"

# Default to the docker profile unless caller already set COMPOSE_PROFILES.
export COMPOSE_PROFILES="${COMPOSE_PROFILES:-docker}"

if (($# > 2)); then
  echo "Usage: $0 [-f] [service]" >&2
  exit 1
fi
follow=false
requested_service=""

if (($# > 0)); then
  case "$1" in
    -f|--follow)
      follow=true
      shift
      ;;
  esac
fi

requested_service="${1:-}"

compose_files=("docker-compose.debian.yml")

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
  if [[ "${follow}" == "true" ]]; then
    "${compose_cmd[@]}" logs -f "${services[@]}"
  else
    "${compose_cmd[@]}" logs "${services[@]}"
  fi
else
  echo "No services selected."
fi
