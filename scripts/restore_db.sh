#/usr/bin/env bash

set -euo pipefail

DEBUG=${DEBUG:-""}
[[ ! -z ${DEBUG} ]] && set -x

RESTORE_DB=${RESTORE_DB:-0}
if [[ ${RESTORE_DB} -ne 1 ]]; then
	echo "RESTORE_DB not set, NOT restoring DB"
	exit 0
fi

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-""}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-""}

BACKUP=/tmp/backup.sql
if [[ -f ${BACKUP} ]]; then
	rm -f ${BACKUP}
fi

if [[ -z ${AWS_ACCESS_KEY_ID} || -z ${AWS_SECRET_ACCESS_KEY} ]]; then
	echo "AWS keys not set, exiting"
	exit 1
fi

aws s3 cp ${S3_DB_BUCKET}/${S3_DB_BUCKET_KEY}/${S3_DB_BUCKET_BACKUP_NAME} ${BACKUP}.gz
gunzip ${BACKUP}.gz
mysql -u${DB_USER} -p${DB_PASS} -hdb ${DATABASE} < ${BACKUP}

