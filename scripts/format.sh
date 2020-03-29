#!/bin/bash

output=${1:-}
print_out=${2:-}

while read pipe; do
    if [ -n "$output" ] ; then
        # Print formated string into output file
        echo $pipe | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' >> $output
    else
        # Print formated string into stdout
        echo $pipe | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }'
    fi
    if [ -n "$print_out" ] ; then
        # Print raw pipe data into stdout
        echo $pipe
    fi
done < /dev/stdin
