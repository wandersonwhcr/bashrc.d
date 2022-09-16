kubesh() {
    KUBESH_ARGS=""

    while test "$1"; do
        case "$1" in
            --serviceaccount)
                shift;
                KUBESH_OVERRIDES=`
                    jq '{ "spec": { "serviceAccountName": $KUBESH_SERVICEACCOUNT } }' \
                        --null-input \
                        --arg KUBESH_SERVICEACCOUNT "$1" \
                        --compact-output
                `
                KUBESH_ARGS="$KUBESH_ARGS --overrides $KUBESH_OVERRIDES"
                ;;
            *)
                KUBESH_ARGS="$KUBESH_ARGS $1"
                ;;
        esac
        shift
    done

    set -- $KUBESH_ARGS

    kubectl run --rm --stdin --tty --image=alpine alpine-`date-to-identifier` $* -- /bin/sh
}

kubesecr() {
    kubectl get secrets --output json $* \
        | jq 'if .kind == "List" then .items[] else . end' \
        | jq '.data[] |= @base64d' \
        | jq '{ name: .metadata.name, data: .data}'
}
