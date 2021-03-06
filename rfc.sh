#!/bin/bash

RFC_URL='https://www.rfc-editor.org/rfc/rfc%d.txt'
INDEX_FILE='/usr/share/rfc-get/rfc-index.txt'

online_rfc()
{
    curl -L -- $(printf "$RFC_URL" $1) 2>/dev/null
}

deformat_rfc()
{
    # Remove page headers, footers and form-feeds
    sed -n '
        /^\x0c$/ {
             n; n; x; d
        }
        x; 1d; p
        $ {
            x; p
        }' |
    # Collapse multiple blank lines into one
    awk '!NF {
             if (++n <= 1)
                 print
             next
         }
         {
             n=0
             print
         }'
}

highlight_rfc() {
    # Make headlines etc. highlighted for console use
    awk '/^ /, /^$/ {
            print
        }
        /^[^ ]/ {
            split($0, chars, "")
            for(i = 1; i <= length(chars); i++) {
                printf("%s\x08%s", chars[i], chars[i])
            }
            printf("\n")
        }'
}

display_rfc()
{
    less
}

search_index()
{
    grep -i "$1" "$INDEX_FILE"
}

if [ "x$1" = 'x-h' -o "$#" -ne 1 -o -z "$1" ]; then
    echo 'Usage: rfc [number or search string]' >/dev/null
    exit 1
fi

if [ "$1" -eq "$1" ] 2>/dev/null; then
    # Numeric input
    if [ -t 1 ]; then
        # Interactive tty
        online_rfc $1 | deformat_rfc | highlight_rfc | display_rfc
    else
        online_rfc $1 | deformat_rfc
    fi
else
    # Search
    if ! [ -e "$INDEX_FILE" ]; then
        echo 'Index not available, search aborted.' >/dev/null
    fi
    search_index $1
fi

