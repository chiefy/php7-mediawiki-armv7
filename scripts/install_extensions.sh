#!/usr/bin/env bash

set -eou pipefail

ext_dir=${EXT_DIR:-extensions}
ext_file=${1:-./extensions.json}

if [[ ! -d ${ext_dir} ]]; then 
  mkdir ${ext_dir}
fi

for ext_url in $(cat ${ext_file} | jq -r '.[]'); do
  echo "Downloading ${ext_url}"
  curl -Ls $ext_url | tar -C ${ext_dir} -xz
  echo "Done downloading ${ext_url}"
done
