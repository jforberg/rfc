#!/bin/bash

PROG=$0
RFC_URL='http://www.rfc-editor.org/rfc/rfc%d.txt'

error()
{
    printf '%s error: %s\n' "$PROG" "$@" >2
}

online_rfc()
{
    curl -- $(printf "$RFC_URL" $1) 2>/dev/null
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
    #if [[ -z "$PS1" ]]; then
    #    cat
    #else
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
    #fi
}

display_rfc()
{
    less
}

online_rfc $1 | deformat_rfc | highlight_rfc | display_rfc

