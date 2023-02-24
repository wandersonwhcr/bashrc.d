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

kubenodesh() {
    KUBENODESH_NAMESPACE_ARGS=""
    KUBENODESH_METADATA_NAME="alpine-`date-to-identifier`"
    KUBENODESH_NODESELECTOR_HOSTNAME="$1"
    shift

    while test "$1"; do
        case "$1" in
            --namespace|-n)
                shift
                KUBENODESH_NAMESPACE_ARGS="--namespace $1"
                ;;
        esac
        shift
    done

    KUBENODESH_SPEC='
        {
            "apiVersion": "v1",
            "kind": "Pod",
            "metadata": {
                "name": $KUBENODESH_METADATA_NAME
            },
            "spec": {
                "restartPolicy": "Never",
                "terminationGracePeriodSeconds": 0,
                "hostPID": true,
                "hostIPC": true,
                "hostNetwork": true,
                "tolerations": [ { "operator": "Exists" } ],
                "nodeSelector": { "kubernetes.io/hostname": $KUBENODESH_NODESELECTOR_HOSTNAME },
                "containers": [
                    {
                        "name": "alpine",
                        "image": "alpine",
                        "securityContext": { "privileged": true },
                        "command": ["nsenter"],
                        "args": ["-t", "1", "-m", "-u", "-i", "-n", "sleep", "infinity"]
                    }
                ]
            }
        }
    '

    jq "$KUBENODESH_SPEC" \
        --null-input \
        --arg KUBENODESH_METADATA_NAME "$KUBENODESH_METADATA_NAME" \
        --arg KUBENODESH_NODESELECTOR_HOSTNAME "$KUBENODESH_NODESELECTOR_HOSTNAME" \
        --compact-output \
        | kubectl create $KUBENODESH_NAMESPACE_ARGS --filename - >/dev/null

    kubectl wait pods --for condition=Ready $KUBENODESH_NAMESPACE_ARGS "$KUBENODESH_METADATA_NAME"
    kubectl exec --stdin --tty $KUBENODESH_NAMESPACE_ARGS "$KUBENODESH_METADATA_NAME" -- /bin/sh
    kubectl delete pods $KUBENODESH_NAMESPACE_ARGS "$KUBENODESH_METADATA_NAME"
}

kubesecr() {
    kubectl get secrets --output json $* \
        | jq 'if .kind == "List" then .items[] else . end' \
        | jq '.data[] |= @base64d' \
        | jq '{ name: .metadata.name, data: .data}'
}
