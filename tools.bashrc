b64enc() {
    CONTENT="$1"
    shift 1
    echo -n "$CONTENT" | base64 --wrap 0 $*; echo
}

export -f b64enc
