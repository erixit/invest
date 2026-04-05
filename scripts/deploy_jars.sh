#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

microservices_root="${1:-${script_dir}/../../invest_microservices}"
deploy_dir="${2:-${script_dir}/../deploy}"

if [[ ! -d "${microservices_root}" ]]; then
  echo "Target directory not found: ${microservices_root}" >&2
  exit 1
fi

mkdir -p "${deploy_dir}"

resolved_microservices_root="$(cd "${microservices_root}" && pwd)"
resolved_deploy_dir="$(cd "${deploy_dir}" && pwd)"

echo "Microservices root: ${resolved_microservices_root}"
echo "Deploy dir: ${resolved_deploy_dir}"

services=(
  "corems:corems"
  "adminms:adminms"
  "consultms:consultms"
  "messaging:messaging"
)

get_latest_jar() {
  local target_dir="$1"
  local artifact_prefix="$2"

  if [[ ! -d "${target_dir}" ]]; then
    echo "Target directory not found: ${target_dir}" >&2
    return 1
  fi

  local jar
  jar="$(
    find "${target_dir}" -maxdepth 1 -type f -name "${artifact_prefix}-*.jar" \
      | grep -Ev '(sources|javadoc|original)' \
      | xargs -r ls -1t \
      | head -n 1
  )"

  if [[ -z "${jar}" ]]; then
    echo "No jar found for artifact '${artifact_prefix}' in ${target_dir}" >&2
    return 1
  fi

  printf '%s\n' "${jar}"
}

for service in "${services[@]}"; do
  module="${service%%:*}"
  artifact="${service##*:}"
  target_dir="${resolved_microservices_root}/${module}/target"

  jar_path="$(get_latest_jar "${target_dir}" "${artifact}")"
  jar_name="$(basename "${jar_path}")"
  dest_path="${resolved_deploy_dir}/${jar_name}"

  cp -f "${jar_path}" "${dest_path}"
  echo "Copied ${jar_name} -> ${dest_path}"
done

echo "JAR deployment complete."