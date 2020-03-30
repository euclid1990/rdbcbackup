#!/bin/bash

pattern=${1:-}

if [[ -n "${BACKUP_RETAIN_DAYS}" ]]; then
    echo "-- Find and delete [${pattern}] backup files older than ${BACKUP_RETAIN_DAYS} days"
    find ${BACKUP_DIR} -name ${pattern}* -mtime +5 -exec rm {} \;
fi

if [[ "${BACKUP_MAX_FILES}" -ne "0" ]]; then
    numLines=$((BACKUP_MAX_FILES+1))
    echo "-- Find and delete if there are more than ${BACKUP_MAX_FILES} [${pattern}] backup files"
    ls ${BACKUP_DIR}/${pattern}* -1t | tail -n +${numLines} | xargs rm -f
fi