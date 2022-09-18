export HISTTIMEFORMAT="%F %T "

toBase64() {
    cat <&0 \
        | sed --null-data 's/\n$//' \
        | openssl enc -base64 -A
    echo
}

toBase64Url() {
    cat <&0 \
        | toBase64 \
        | tr '+/' '-_' \
        | tr --delete '='
}
