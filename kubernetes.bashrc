kubesh() {
    kubectl run --rm --stdin --tty --image=alpine alpine-`date-to-identifier` $* -- /bin/sh
}

kubesecr() {
    kubectl get secrets --output json $* \
        | jq 'if .kind == "List" then .items[] else . end' \
        | jq '.data[] |= @base64d' \
        | jq '{ name: .metadata.name, data: .data}'
}
