#!/usr/bin/bash

# source file for tab completion functionality
. "$( dirname "$0" )/../src/input.class.sh" || exit 1

words=(
    anton
    berta
    cesar
    doris
)

# input.setCompletion "anton berta cesar doris"
input.setCompletion "${words[@]}"

while :; do
    read -rep"> " inp
    test -z "$inp" && break
    # process command
    echo "You entered '$inp'"
    echo
done
echo "Bye."
