#!/usr/bin/env bash
set -euo pipefail

: "${INPUT_PLUGINS:?INPUT_PLUGINS is required}"
: "${AWF_PLUGINS_PATH:?AWF_PLUGINS_PATH is required}"

export AWF_PLUGINS_PATH
mkdir -p "${AWF_PLUGINS_PATH}"

FAILED=0

while IFS= read -r line; do
  # Skip empty lines and comments
  line=$(echo "${line}" | xargs)
  [ -z "${line}" ] && continue
  [[ "${line}" == \#* ]] && continue

  # Parse owner/repo@version
  if [[ "${line}" == *@* ]]; then
    PLUGIN="${line%%@*}"
    VERSION="${line##*@}"
  else
    PLUGIN="${line}"
    VERSION=""
  fi

  echo "::group::Install plugin ${PLUGIN}"

  INSTALL_CMD="awf plugin install ${PLUGIN}"
  if [ -n "${VERSION}" ]; then
    INSTALL_CMD="${INSTALL_CMD} --version ${VERSION}"
  fi

  if ! eval "${INSTALL_CMD}"; then
    echo "::error::Failed to install plugin ${PLUGIN}"
    FAILED=1
  fi

  echo "::endgroup::"
done <<< "${INPUT_PLUGINS}"

if [ "${FAILED}" -ne 0 ]; then
  echo "::error::One or more plugins failed to install"
  exit 1
fi

echo "All plugins installed to ${AWF_PLUGINS_PATH}"
