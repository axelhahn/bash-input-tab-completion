#!/bin/bash

# source file for input functions
. "$( dirname "$0" )/../src/input.class.sh" || exit 1

echo "
----------------------------------------------------------------------

Select box example

----------------------------------------------------------------------
"

lines=(
    "anton was here"
    berta
    cesar
    doris
)

input.select "${lines[@]}"
result="${lines[$?]}"

echo "Your choice was: '$result'"

