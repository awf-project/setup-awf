#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_TOKEN:?GITHUB_TOKEN is required}"
: "${AWF_VERSION:?AWF_VERSION is required}"
: "${AWF_OS:?AWF_OS is required}"
: "${AWF_ARCH:?AWF_ARCH is required}"
: "${AWF_INSTALL_DIR:?AWF_INSTALL_DIR is required}"

REPO="awf-project/cli"
TAG="v${AWF_VERSION}"

# Determine archive format
if [ "${AWF_OS}" = "darwin" ]; then
  EXT="zip"
else
  EXT="tar.gz"
fi

ARCHIVE_NAME="awf_${AWF_OS}_${AWF_ARCH}.${EXT}"
BASE_URL="https://github.com/${REPO}/releases/download/${TAG}"
ARCHIVE_URL="${BASE_URL}/${ARCHIVE_NAME}"
CHECKSUMS_URL="${BASE_URL}/checksums.txt"

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

echo "::group::Download AWF ${TAG}"

# Download archive and checksums
curl -fsSL -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/octet-stream" \
  -o "${TMPDIR}/${ARCHIVE_NAME}" \
  -L "${ARCHIVE_URL}"

curl -fsSL -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/octet-stream" \
  -o "${TMPDIR}/checksums.txt" \
  -L "${CHECKSUMS_URL}"

echo "::endgroup::"

# Verify checksum
echo "::group::Verify checksum"
EXPECTED=$(grep "${ARCHIVE_NAME}" "${TMPDIR}/checksums.txt" | awk '{print $1}')
if [ -z "${EXPECTED}" ]; then
  echo "::error::No checksum found for ${ARCHIVE_NAME} in checksums.txt"
  exit 1
fi

if command -v sha256sum &>/dev/null; then
  ACTUAL=$(sha256sum "${TMPDIR}/${ARCHIVE_NAME}" | awk '{print $1}')
else
  ACTUAL=$(shasum -a 256 "${TMPDIR}/${ARCHIVE_NAME}" | awk '{print $1}')
fi
if [ "${EXPECTED}" != "${ACTUAL}" ]; then
  echo "::error::Checksum mismatch for ${ARCHIVE_NAME}: expected ${EXPECTED}, got ${ACTUAL}"
  exit 1
fi
echo "Checksum verified: ${ACTUAL}"
echo "::endgroup::"

# Extract
echo "::group::Extract AWF binary"
mkdir -p "${AWF_INSTALL_DIR}"

if [ "${EXT}" = "zip" ]; then
  unzip -o "${TMPDIR}/${ARCHIVE_NAME}" -d "${AWF_INSTALL_DIR}"
else
  tar -xzf "${TMPDIR}/${ARCHIVE_NAME}" -C "${AWF_INSTALL_DIR}"
fi

chmod +x "${AWF_INSTALL_DIR}/awf"
echo "::endgroup::"

echo "AWF ${TAG} installed to ${AWF_INSTALL_DIR}/awf"
