#!/usr/bin/env bash

set -euo pipefail

DEBUG=${DEBUG:-""}
[[ ! -z ${DEBUG} ]] && set -x

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-""}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-""}

if [[ -z ${AWS_ACCESS_KEY_ID} || -z ${AWS_SECRET_ACCESS_KEY} ]]; then
	echo "AWS keys not set, exiting"
	exit 1
fi

if [[ -z $@ ]]; then
	echo "Usage: sync_s3.sh <source> <destination>"; exit 1
fi
ls -lah /images
aws s3 sync ${1} ${2}
