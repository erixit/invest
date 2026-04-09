#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ui_root="${1:-${script_dir}/../../invest_userinterfaces}"
deploy_dir="${2:-${script_dir}/../deploy}"

if [[ ! -d "${ui_root}" ]]; then
  echo "UI root directory not found: ${ui_root}" >&2
  exit 1
fi

mkdir -p "${deploy_dir}"

resolved_ui_root="$(cd "${ui_root}" && pwd)"
resolved_deploy_dir="$(cd "${deploy_dir}" && pwd)"

echo "UI root: ${resolved_ui_root}"
echo "Deploy dir: ${resolved_deploy_dir}"

copy_ui_dist() {
  local ui_name="$1"
  local src_dir="${resolved_ui_root}/${ui_name}/dist/${ui_name}"
  local dest_dir="${resolved_deploy_dir}/${ui_name}/dist/${ui_name}"

  if [[ ! -d "${src_dir}" ]]; then
    echo "Source dist directory not found for ${ui_name}: ${src_dir}" >&2
    return 1
  fi

  # Keep the destination directory inode stable so running bind mounts stay valid.
  mkdir -p "${dest_dir}"
  find "${dest_dir}" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

  cp -a "${src_dir}/." "${dest_dir}/"
  chmod -R 777 "${dest_dir}"
  echo "Copied ${ui_name} dist -> ${dest_dir}"
}

copy_ui_dist "adminui"
copy_ui_dist "consultui"

echo "UI deployment complete."
