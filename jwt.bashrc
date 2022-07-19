jwt() {
    RSA_KEY_FILENAME="$1"

    openssl rsa \
        -in "$RSA_KEY_FILENAME" \
        -noout

    if [ $? -ne 0 ]; then
        return $?
    fi

    JWT_HEADER_DECODED='{"alg":"RS256","typ":"JWT"}'

    JWT_HEADER=`echo -n "$JWT_HEADER_DECODED" | toBase64Url`
    JWT_PAYLOAD=`cat <&0 | jq --compact-output | toBase64Url`

    JWT_SIGNATURE=`
        echo -n "$JWT_HEADER.$JWT_PAYLOAD" \
            | openssl dgst -sha256 -binary -sign "$RSA_KEY_FILENAME" \
            | toBase64Url
    ` # JWT_SIGNATURE

    echo "$JWT_HEADER.$JWT_PAYLOAD.$JWT_SIGNATURE"
}

export -f jwt
