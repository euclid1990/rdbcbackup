FROM alpine:3.11

RUN apk add --update bash vim mysql-client gzip bzip2 openssl tzdata && rm -rf /var/cache/apk/*

ENV TIMEZONE="UTC" \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306" \
    MYSQL_USER="" \
    MYSQL_PASSWORD="" \
    MYSQLDUMP_OPTS="" \
    CONNECT_TIMEOUT="180" \
    BACKUP_COMPRESSION="gzip" \
    BACKUP_DATABASE="" \
    BACKUP_SCHEDULE="0 0 * * *" \
    BACKUP_IGNORES="information_schema|performance_schema" \
    BACKUP_DIR="/backup" \
    BACKUP_LOG_COMBINE="1" \
    BACKUP_OUTPUT_LOGFILE="/proc/self/fd/1" \
    BACKUP_ERROR_LOGFILE="/proc/self/fd/2" \
    BACKUP_MAX_FILES="100" \
    BACKUP_RETAIN_DAYS="3"

COPY scripts /scripts

RUN chmod u+x /scripts/*.sh

RUN mkdir ${BACKUP_DIR} ${BACKUP_LOG_DIR}

ENTRYPOINT ["/scripts/entrypoint.sh"]

CMD ["/scripts/command.sh"]
