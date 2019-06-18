#!/usr/bin/env bash

set -eou pipefail

declare -A MW_EXTENSIONS

: ${EXT_DIR:-extensions}
: ${MW_EXTENSIONS:-""}

for ext_url in ${MW_EXTENSIONS[@]}; do
  echo "Downloading ${ext_url}"
  wget -qO - $ext_url | tar -C ${EXT_DIR} -xz
  echo "Done downloading ${ext_url}"
done
