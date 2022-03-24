#!/bin/bash

# Wait for database connection ready
/scripts/wait-for-it.sh ${MYSQL_HOST}:${MYSQL_PORT} --timeout=${CONNECT_TIMEOUT} -- echo 'Ready for connection.'


# Set as environment variables by docker upon the containers creation
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env

# Set cron environment
echo "SHELL=/bin/bash" > /crontab.conf
echo "BASH_ENV=/container.env" >> /crontab.conf

# Generate crontab configuration and redirect command output to a log file or stdout/stderr stream
if [[ "${BACKUP_LOG_COMBINE}" == "1" || "${BACKUP_LOG_COMBINE}" == "yes" ]]; then
    # Combine into one stream
    echo "${BACKUP_SCHEDULE} /scripts/backup.sh 2>&1 | /scripts/format.sh >>${BACKUP_OUTPUT_LOGFILE}" >> /crontab.conf
else
    # Seperate into two stream: all and error only
    echo "${BACKUP_SCHEDULE} { /scripts/backup.sh 2>&1 1>&3 3>&- | /scripts/format.sh ${BACKUP_ERROR_LOGFILE} out; } 3>&1 | /scripts/format.sh >> ${BACKUP_OUTPUT_LOGFILE}" >> /crontab.conf
fi

# Apply cron job
crontab /crontab.conf

# Exexute cron job
echo "=> Running Cron Task Manager ..."
exec cron -f
