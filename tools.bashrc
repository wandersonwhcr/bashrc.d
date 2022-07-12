base64enc() {
    echo -n $* | base64 --wrap 0; echo
}

export -f base64enc
