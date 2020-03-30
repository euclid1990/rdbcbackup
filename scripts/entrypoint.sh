#!/bin/bash

if [ -f "/usr/share/zoneinfo/${TIMEZONE}" ]; then
    # Copy and write timezone to /etc/localtime in the container + Reset timezone
    cp -r -f /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
fi

# Create file and its parent directory
mkfile() { mkdir -p "$(dirname "$1")" && touch "$1" ; }

# Create empty logs file if it not exist
files=(${BACKUP_OUTPUT_LOGFILE} ${BACKUP_ERROR_LOGFILE})

# Using test operator checks whether a file exists if it not exists create new one
for f in ${files[@]} ; do
    [ -e $f ] && echo "$f: found." || echo "$f: not found and created new." && mkfile "$f"
done

# Grant execute permission to before/after scripts
chmod u+x /scripts/before/*.sh /scripts/after/*.sh 2>/dev/null

exec "$@"

