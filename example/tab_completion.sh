#!/bin/bash

# source file for input functions
. "$( dirname "$0" )/../src/input.class.sh" || exit 1

echo "
----------------------------------------------------------------------

Tab completion example

----------------------------------------------------------------------

Press tab to show suggestions.
Exit by just pressing enter.
"


words=(
    anton
    berta
    cesar
    doris
)

# input.setCompletion "anton berta cesar doris"
input.setCompletion "${words[@]}"

while :; do
    read -rep"names > " inp
    test -z "$inp" && break
    # process command
    echo "You entered '$inp'"
    echo
done
echo "Bye."
