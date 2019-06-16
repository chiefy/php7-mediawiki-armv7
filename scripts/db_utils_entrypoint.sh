#/usr/bin/env bash

set -euo pipefail

DEBUG=${DEBUG:-""}
[[ ! -z ${DEBUG} ]] && set -x

# Only restore DB once
RESTORED_BIT=/root/.dbrestored

# Default backup to every 12 hours
DB_RESTORE_SCHEDULE=${DB_RESTORE_SCHEDULE:-"* */12 * * *"}

# Ensure AWS keys exist
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-""}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-""}
if [[ -z ${AWS_ACCESS_KEY_ID} || -z ${AWS_SECRET_ACCESS_KEY} ]]; then
  echo "AWS keys not set, exiting"
  exit 1
fi

restore() {
  local backup= /tmp/backup.sql
  if [[ ! -z ${RESTORE_DB} ]]; then
    echo "RESTORE_DB env not set, not restoring db"
    return
  fi
  if [[ -f ${RESTORED_BIT} ]]; then
    echo "${RESTORED_BIT} already exists, not restoring db"
    return
  fi
  aws s3 cp ${S3_DB_BUCKET}/${S3_DB_BUCKET_KEY}/${S3_DB_BUCKET_BACKUP_NAME} ${backup}.gz
  gunzip ${backup}.gz
  mysql -u${DB_USER} -p${DB_PASS} -hdb ${DATABASE} <${backup}
  rm -f ${backup} ${backup}.gz
  touch ${RESTORED_BIT}
}

backup() {
  local backup=$(date +%Y-%m-%d-%H%M%S).sql.gz
  cd /tmp
  mysqldump --add-drop-table -hdb -p${DB_PASS} -u${DB_USER} ${DATABASE} | gzip >${backup}
  aws s3 cp ${backup} ${S3_DB_BUCKET}/${S3_DB_BUCKET_KEY}
  rm -f ${backup}
}

start() {
  restore
  echo "Starting crond..."
  crond -f -l 2
}

${1}