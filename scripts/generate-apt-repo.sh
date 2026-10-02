#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_DIR="${ROOT_DIR}/public"

mkdir -p "${PUBLIC_DIR}/dists/stable/main/binary-amd64" \
         "${PUBLIC_DIR}/dists/stable/main/source" \
         "${PUBLIC_DIR}/keys"

echo "Generating binary Packages index..."
apt-ftparchive packages "${PUBLIC_DIR}/pool/main" > "${PUBLIC_DIR}/dists/stable/main/binary-amd64/Packages"
gzip -9 -n -c "${PUBLIC_DIR}/dists/stable/main/binary-amd64/Packages" > "${PUBLIC_DIR}/dists/stable/main/binary-amd64/Packages.gz"

echo "Generating source Sources index..."
apt-ftparchive sources "${PUBLIC_DIR}/pool/main" > "${PUBLIC_DIR}/dists/stable/main/source/Sources"
gzip -9 -n -c "${PUBLIC_DIR}/dists/stable/main/source/Sources" > "${PUBLIC_DIR}/dists/stable/main/source/Sources.gz"

echo "Generating Release file..."
apt-ftparchive release "${PUBLIC_DIR}/dists/stable" > "${PUBLIC_DIR}/dists/stable/Release"

if [ -n "${APT_GPG_PRIVATE_KEY:-}" ] && [ -n "${APT_GPG_PASSPHRASE:-}" ]; then
  echo "${APT_GPG_PRIVATE_KEY}" > /tmp/jibo-automod-private.key
  gpg --batch --yes --pinentry-mode loopback --passphrase "${APT_GPG_PASSPHRASE}" --import /tmp/jibo-automod-private.key
  gpg --batch --yes --pinentry-mode loopback --passphrase "${APT_GPG_PASSPHRASE}" \
    --armor --detach-sign -o "${PUBLIC_DIR}/dists/stable/Release.gpg" "${PUBLIC_DIR}/dists/stable/Release"
  gpg --batch --yes --pinentry-mode loopback --passphrase "${APT_GPG_PASSPHRASE}" \
    --clearsign -o "${PUBLIC_DIR}/dists/stable/InRelease" "${PUBLIC_DIR}/dists/stable/Release"

  if [ -n "${APT_GPG_PUBLIC_KEY:-}" ]; then
    printf '%s' "${APT_GPG_PUBLIC_KEY}" > "${PUBLIC_DIR}/keys/jibo-automod.asc"
  fi
else
  echo "No signing key configured; apt repo will be unsigned."
fi

echo "APT repo generated in ${PUBLIC_DIR}"
