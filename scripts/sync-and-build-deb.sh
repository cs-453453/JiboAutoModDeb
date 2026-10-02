#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/.build"
SOURCE_REPO="${SOURCE_REPO:-Jibo-Revival-Group/JiboAutoMod}"
SOURCE_BRANCH="${SOURCE_BRANCH:-main}"
TARGET_PACKAGE_NAME="jibo-automod"
PUBLIC_DIR="${ROOT_DIR}/public"
TMP_SOURCE_DIR="${BUILD_DIR}/source"

BUILD_DATE="$(date -u +%Y%m%d)"
UPSTREAM_SHA="$(git ls-remote "https://github.com/${SOURCE_REPO}.git" "refs/heads/${SOURCE_BRANCH}" | awk '{print $1}' | cut -c1-8 || echo "unknown")"
TARGET_PACKAGE_VERSION="${BUILD_DATE}+${UPSTREAM_SHA}"

rm -rf "${BUILD_DIR}" "${PUBLIC_DIR}"
mkdir -p "${BUILD_DIR}" "${PUBLIC_DIR}" "${PUBLIC_DIR}/pool/main/jibo-automod"

echo "Fetching upstream source: ${SOURCE_REPO}@${SOURCE_BRANCH}"
git clone --depth=1 --branch "${SOURCE_BRANCH}" "https://github.com/${SOURCE_REPO}.git" "${TMP_SOURCE_DIR}"

PKG_ROOT="${BUILD_DIR}/deb/${TARGET_PACKAGE_NAME}_${TARGET_PACKAGE_VERSION}_amd64"
mkdir -p "${PKG_ROOT}/DEBIAN" \
         "${PKG_ROOT}/usr/lib/jibo-automod" \
         "${PKG_ROOT}/usr/bin" \
         "${PKG_ROOT}/usr/share/doc/jibo-automod"

cp -a "${TMP_SOURCE_DIR}/." "${PKG_ROOT}/usr/lib/jibo-automod/"

cat > "${PKG_ROOT}/usr/bin/jibo-automod" <<'EOF'
#!/bin/sh
exec /usr/lib/jibo-automod/jibo_automod.sh "$@"
EOF
chmod 0755 "${PKG_ROOT}/usr/bin/jibo-automod"
chmod 0755 "${PKG_ROOT}/usr/lib/jibo-automod/jibo_automod.sh"

cat > "${PKG_ROOT}/DEBIAN/control" <<EOF
Package: ${TARGET_PACKAGE_NAME}
Version: ${TARGET_PACKAGE_VERSION}
Section: utils
Priority: optional
Architecture: amd64
Maintainer: ${PACKAGE_MAINTAINER:-JiboAutoModDeb Maintainers} <cs-453453@users.noreply.github.com>
Homepage: https://github.com/Jibo-Revival-Group/JiboAutoMod
Description: Jibo Auto-Mod Tool
 This package contains the upstream Jibo Auto-Mod source and a launcher script.
EOF

dpkg-deb --build --root-owner-group "${PKG_ROOT}" "${PUBLIC_DIR}/pool/main/jibo-automod/${TARGET_PACKAGE_NAME}_${TARGET_PACKAGE_VERSION}_amd64.deb"

echo "Built binary package: ${PUBLIC_DIR}/pool/main/jibo-automod/${TARGET_PACKAGE_NAME}_${TARGET_PACKAGE_VERSION}_amd64.deb"

cd "${TMP_SOURCE_DIR}"
tar --exclude='.git' --exclude='.build' --exclude='public' -czf "${PUBLIC_DIR}/pool/main/jibo-automod/${TARGET_PACKAGE_NAME}_${TARGET_PACKAGE_VERSION}.tar.gz" .

SOURCE_TARBALL="${PUBLIC_DIR}/pool/main/jibo-automod/${TARGET_PACKAGE_NAME}_${TARGET_PACKAGE_VERSION}.tar.gz"
SOURCE_TARBALL_SIZE="$(stat -c%s "${SOURCE_TARBALL}")"
SRC_TARBALL_MD5="$(md5sum "${SOURCE_TARBALL}" | awk '{print $1}')"

cat > "${PUBLIC_DIR}/pool/main/jibo-automod/${TARGET_PACKAGE_NAME}_${TARGET_PACKAGE_VERSION}.dsc" <<EOF
Format: 3.0 (quilt)
Source: ${TARGET_PACKAGE_NAME}
Binary: ${TARGET_PACKAGE_NAME}
Architecture: amd64
Version: ${TARGET_PACKAGE_VERSION}
Maintainer: ${PACKAGE_MAINTAINER:-JiboAutoModDeb Maintainers} <cs-453453@users.noreply.github.com>
Homepage: https://github.com/Jibo-Revival-Group/JiboAutoMod
Standards-Version: 4.6.1
Build-Depends: debhelper-compat (= 13)
Files:
 ${SRC_TARBALL_MD5} ${SOURCE_TARBALL_SIZE} ${TARGET_PACKAGE_NAME}_${TARGET_PACKAGE_VERSION}.tar.gz
EOF

echo "${TARGET_PACKAGE_VERSION}" > "${BUILD_DIR}/version.txt"
echo "${UPSTREAM_SHA}" > "${BUILD_DIR}/upstream_sha.txt"
