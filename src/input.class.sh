
#!/bin/bash
# ======================================================================
#
# Tab completion for read
#
# based on
# https://stackoverflow.com/questions/4819819/get-autocompletion-when-invoking-a-read-inside-a-bash-script
#
# -----------------------------------------------           -----------------------
# 2025-09-02   0.1   Initial version
# ======================================================================

# ----------------------------------------------------------------------
# functions select
# ----------------------------------------------------------------------

function input.select {
#   local header="\nAdd A Header\nWith\nAs Many\nLines as you want"
#   header+="\n\nPlease choose an option:\n\n"
#   printf "$header"
    local options=("$@")
    local itemsPre="   "

    # helpers for terminal print control and key input
    ESC=$(printf "\033")

    cursor_blink_on()       { printf "$ESC[?25h"; }
    cursor_blink_off()      { printf "$ESC[?25l"; }
    cursor_to()                     { printf "$ESC[$1;${2:-1}H"; }
    print_option()          { printf "${itemsPre} $1 "; }
    print_selected()        { printf "${itemsPre}${COLOR_GREEN}$ESC[7m $1 $ESC[27m${NC}"; }
    get_cursor_row()        { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }

    key_input() {
        local key
        # read 3 chars, 1 at a time
        for ((i=0; i < 3; ++i)); do
            read -s -n1 input 2>/dev/null >&2
            # concatenate chars together
            key+="$input"
            # if a number is encountered, echo it back
            if [[ $input =~ ^[1-9]$ ]]; then
                echo $input; return;
            # if enter, early return
            elif [[ $input = "" ]]; then
                echo enter; return;
            # if we encounter something other than [1-9] or "" or the escape sequence
            # then consider it an invalid input and exit without echoing back
            elif [[ ! $input = $ESC && i -eq 0 ]]; then
                return
            fi
        done

        if [[ $key = $ESC[A ]]; then echo up; fi;
        if [[ $key = $ESC[B ]]; then echo down; fi;
    }

    function cursorUp() { printf "$ESC[A"; }
    function clearRow() { printf "$ESC[2K\r"; }
    function eraseMenu() {
        cursor_to $lastrow
        clearRow
        numHeaderRows=$(printf "$header" | wc -l)
        numOptions=${#options[@]}
        numRows=$(($numHeaderRows + $numOptions))
        for ((i=0; i<$numRows; ++i)); do
        cursorUp; clearRow;
        done
    }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt in "${options[@]}"; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))
    local selected=0

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt in "${options[@]}"; do
            cursor_to $(($startrow + $idx))
            # add an index to the option
            local label="$(($idx + 1)). $opt"
            if [ $idx -eq $selected ]; then
                print_selected "$label"
            else
                print_option "$label"
            fi
            ((idx++))
        done

        # user key control
        input=$(key_input)

        case $input in
            enter) break;;
            [1-9])
                # If a digit is encountered, consider it a selection (if within range)
                if [ $input -lt $(($# + 1)) ]; then
                selected=$(($input - 1))
                break
                fi
                ;;
            up)     ((selected--));
                if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    eraseMenu
    cursor_blink_on

    return $selected
}



# ----------------------------------------------------------------------
# functions tab completion
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
