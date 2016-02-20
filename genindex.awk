BEGIN {
    RS="\n\n"
    FS=" "
}

$1 ~ /^[0-9]+$/ {
    rec = $0
    sub(/\..*/, "", rec)
    sub(/\n */," ", rec)
    sub(/\n.*/, "", rec)
    if (!match(rec, /^ /))
        print rec
}
