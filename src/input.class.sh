
#!/bin/bash
# ======================================================================
#
# Tab completion for read
#
# based on
# https://stackoverflow.com/questions/4819819/get-autocompletion-when-invoking-a-read-inside-a-bash-script
#
# ----------------------------------------------------------------------
# 2025-09-02   0.1   Initial version
# ======================================================================

# ----------------------------------------------------------------------
# functions
# ----------------------------------------------------------------------

# Define the completion data
# param  string  words separated by space
input.setCompletion(){
    INPUT_COMPLETIONDATA=($*)
    # INPUT_COMPLETIONDATA="$*[@]"
}

# Callback function to draw matching suggestions
input._callbackTab() {
    # Here we have two variables that can be used to manipulate the read-line
    # 1) $READLINE_LINE:  The current line
    # 2) $READLINE_POINT: Position of cursor
    #
    # If either is changed in this function, it is reflected on the read-line
    #

    local iHits; typeset -i iHits=0
    local sLastword=$( rev <<< "$READLINE_LINE" | cut -f 1 -d " " | rev )
    local sSuggest
    local sHit

    local NL="
"
    # scan for matches in tab completion items
    for word in "${INPUT_COMPLETIONDATA[@]}"
    do
        if grep -q "$sLastword" <<< "$word"; then
            sHit="$word"
            sSuggest+="  $word$NL"
            iHits+=1
        fi
    done

    case $iHits in
        0)
            printf "(no matches)\n" >&2
            ;;
        1)
            local sBefore=$( echo "$READLINE_LINE" | sed "s#$sLastword\$##" )
            READLINE_LINE="$sBefore$sHit "
            READLINE_POINT="${#READLINE_LINE}"
            ;;
        *)
            # multiple hits? Then suggest
            test $iHits -gt 1 && printf "%s" "$sSuggest" >&2
    esac

}

# ----------------------------------------------------------------------
# init
# ----------------------------------------------------------------------

typeset -a INPUT_COMPLETIONDATA=()

# Make it available to bind
export -f input._callbackTab

# Enable readline mode
set -o emacs

# Bind TAB to our custom completion function
bind -x '"\t"':input._callbackTab

# ----------------------------------------------------------------------
