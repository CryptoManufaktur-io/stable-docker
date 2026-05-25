#!/usr/bin/env bash
set -euo pipefail

WORK_DIR=/home/stable/.stabled

__get_snapshot() {
  __dont_rm=0
  mkdir -p "${WORK_DIR}/snapshot"
  cd "${WORK_DIR}/snapshot"
  eval "__url=$1"
#shellcheck disable=SC2154
  if [[ "${__url}" == "https://storage.cloud.google.com/"* ]]; then
    echo "Google Cloud URL detected, using gsutil"
    __path="gs://${__url#https://storage.cloud.google.com/}"
    gsutil -m cp "${__path}" .
  else
    aria2c -c -x6 -s6 --auto-file-renaming=false --conditional-get=true --allow-overwrite=true "${__url}"
  fi
  echo "Copy completed, extracting"
  if ! __final_url=$(curl -s -I -L -o /dev/null -w '%{url_effective}' "$__url"); then
    printf "Error: Failed to retrieve final URL for %s\n" "$__url" >&2
    return 1
  fi
  __filename=$(basename "$__final_url")
  __filename="${__filename%%\?*}"
  if [[ "${__filename}" =~ \.tar\.zst$ ]]; then
    pzstd -c -d "${__filename}" | tar xvf - -C "${WORK_DIR}"
  elif [[ "${__filename}" =~ \.tar\.gz$ || "${__filename}" =~ \.tgz$ ]]; then
    tar xzvf "${__filename}" -C "${WORK_DIR}"
  elif [[ "${__filename}" =~ \.tar$ ]]; then
    tar xvf "${__filename}" -C "${WORK_DIR}"
  elif [[ "${__filename}" =~ \.lz4$ ]]; then
    lz4 -c -d "${__filename}" | tar xvf - -C "${WORK_DIR}"
  else
    __dont_rm=1
    echo "The snapshot file has a format that Morph Docker can't handle."
    echo "Please come to CryptoManufaktur Discord to work through this."
  fi
  if [ "${__dont_rm}" -eq 0 ]; then
    rm -f "${__filename}"
  fi

  mkdir -p "${WORK_DIR}/initialized"
  echo "Done snapshot download"
  chmod -R 777 "${WORK_DIR}"
}

# Prep datadir
if [ -n "${SNAPSHOT}" ] && [ ! -d "${WORK_DIR}/initialized" ]; then
  __get_snapshot "${SNAPSHOT}"
else
  echo "No snapshot fetch necessary"
fi
