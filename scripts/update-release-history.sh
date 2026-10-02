#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/.build"
PUBLIC_DIR="${ROOT_DIR}/public"
HISTORY_FILE="${PUBLIC_DIR}/releases.json"

mkdir -p "${PUBLIC_DIR}"

if [ ! -f "${HISTORY_FILE}" ]; then
  echo "[]" > "${HISTORY_FILE}"
fi

if [ ! -f "${BUILD_DIR}/version.txt" ]; then
  echo "No version.txt found; skipping release history update."
  exit 0
fi

VERSION="$(cat "${BUILD_DIR}/version.txt")"
UPSTREAM_SHA="$(cat "${BUILD_DIR}/upstream_sha.txt")"
BUILD_TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

PKG_FILE="$(ls -1 "${PUBLIC_DIR}/pool/main/jibo-automod/jibo-automod_"*.deb 2>/dev/null | head -1)"
if [ -z "${PKG_FILE}" ]; then
  echo "No .deb package found; skipping release history update."
  exit 0
fi

PKG_FILENAME="$(basename "${PKG_FILE}")"
PKG_SIZE="$(stat -c%s "${PKG_FILE}")"
PKG_MD5="$(md5sum "${PKG_FILE}" | awk '{print $1}')"
PKG_SHA256="$(sha256sum "${PKG_FILE}" | awk '{print $1}')"

RELEASE_ENTRY="{
  \"version\": \"${VERSION}\",
  \"upstream_sha\": \"${UPSTREAM_SHA}\",
  \"timestamp\": \"${BUILD_TIMESTAMP}\",
  \"package\": \"${PKG_FILENAME}\",
  \"size\": ${PKG_SIZE},
  \"md5\": \"${PKG_MD5}\",
  \"sha256\": \"${PKG_SHA256}\"
}"

TMP_JSON="$(mktemp)"
cat > "${TMP_JSON}" <<EOF
[
  ${RELEASE_ENTRY}
]
EOF

# Append instead of replacing if existing entries exist
if [ "$(wc -c < "${HISTORY_FILE}")" -gt 2 ]; then
  python3 - <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
data = json.loads(p.read_text())
new = json.loads(sys.argv[2])
data.insert(0, new)
p.write_text(json.dumps(data, indent=2))
PY
"${HISTORY_FILE}" "${RELEASE_ENTRY}"
else
  cat "${TMP_JSON}" > "${HISTORY_FILE}"
fi

echo "Release history updated: ${HISTORY_FILE}"
