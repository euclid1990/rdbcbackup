#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
set -eu

timestamp=`date "+%Y-%m-%d %H:%M:%S"`

check_variables_exist() {
    echo $MYSQL_HOST > /dev/null
    echo $MYSQL_PORT > /dev/null
    echo $MYSQL_USER > /dev/null
    echo $MYSQL_PASSWORD > /dev/null
    echo $BACKUP_DATABASE > /dev/null
    echo "- Environment variables are existing"
}

check_variables_not_empty() {
    [ -z "${MYSQL_HOST}" ] && echo "MYSQL_HOST cannot be empty" 1>&2 && exit 1;
    [ -z "${MYSQL_PORT}" ] && echo "MYSQL_PORT cannot be empty" 1>&2 && exit 1;
    [ -z "${MYSQL_USER}" ] && echo "MYSQL_USER cannot be empty" 1>&2 && exit 1;
    [ -z "${MYSQL_PASSWORD}" ] && echo "MYSQL_PASSWORD cannot be empty" 1>&2 && exit 1;
    echo "- Environment variables are set"
}

before_after_backup() {
    scriptsDir=${1:-}
    # Execute additional scripts before/after backup.
    if [ -z "$(ls -A ${scriptsDir}/*.sh 2>/dev/null | wc -l)" ]; then
        echo "Execute scripts in $scriptsDir"
        for i in $(ls ${scriptsDir}/*.sh); do
            if [ -x $i ]; then
                $i
                # If exit code of the last run command not equal zero
                [ $? -ne 0 ] && return 1
            fi
        done
    fi
}

get_compress() {
    # Using the -n option to the "declare" or "local" builtin commands
    # to create a nameref, or a reference to another variable
    local -n compressUtils=$1
    case ${COMPRESSION} in
    gzip)
        compressUtils=("gzip" "gunzip" "tgz")
        ;;
    bzip2)
        compressUtils=("bzip2" "bzip2 -d" "tbz2")
        ;;
    *)
        echo "Unknown compression requested: $COMPRESSION" 1>&2
        exit 1
    esac
}

backup() {
    before_after_backup "/scripts/before"

    # Get compress/uncompress tools
    local utils
    get_compress utils
    read zipUtil unzipUtil zipExt <<< $(echo ${utils[0]} ${utils[1]} ${utils[2]})
    echo "- Zip utils: $zipUtil $unzipUtil $zipExt"

    # Define single backup database from user specified database
    local databases=${BACKUP_DATABASE}
    if [ -z ${databases} ]; then
        #  Or get a list of all of the databases if it empty
        databases=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW DATABASES;" | grep -Ev "(Database|${BACKUP_IGNORES})")
    else
        # Convert a string with space delimited tokens to an array
        databases=( ${BACKUP_DATABASE} )
    fi
    echo "- Database List:" ${databases[*]}

    # Retrieve backup time
    now=$(date -u +"%Y%m%d%H%M%S")
    ext="sql"

    # Take each and dump
    for db in ${databases}; do
        local dumpFilename="${db}-${now}.${ext}"

        mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --databases ${db} ${MYSQLDUMP_OPTS} > ${BACKUP_DIR}/${dumpFilename}
        if [ $? -eq 0 ]; then
            echo "- Database [${db}] backup successfully completed"
        else
            echo "- Error found during backup [${db}]" 1>&2
            exit 1
        fi
    done

    before_after_backup "/scripts/after"
}

main() {
    echo "--- Backup starting ---"
    check_variables_exist
    check_variables_not_empty
    backup
    echo "--- Backup completed ---"
}

main
