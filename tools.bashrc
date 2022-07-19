toBase64() {
    cat <&0 \
        | openssl enc -base64 -A
}

toBase64Url() {
    cat <&0 \
        | toBase64 \
        | tr '+/' '-_' \
        | tr --delete '='
}

export -f toBase64
export -f toBase64Url
