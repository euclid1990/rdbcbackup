#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
set -eu

# Just for testing file descriptor
echo 'Start connect'
echo >&2 'Error connect'
echo 'Start backup'
echo >&2 'Can not backup'
echo 'Finish'
