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

kubenode() {
    KUBENODE_NAMESPACE_ARGS=""
    KUBENODE_METADATA_NAME="alpine-`date-to-identifier`"
    KUBENODE_NODESELECTOR_HOSTNAME="$1"
    shift

    while test "$1"; do
        case "$1" in
            --namespace|-n)
                shift
                KUBENODE_NAMESPACE_ARGS="--namespace $1"
                ;;
        esac
        shift
    done

    KUBENODE_SPEC='
        {
            "apiVersion": "v1",
            "kind": "Pod",
            "metadata": {
                "name": $KUBENODE_METADATA_NAME
            },
            "spec": {
                "restartPolicy": "Never",
                "terminationGracePeriodSeconds": 0,
                "hostPID": true,
                "hostIPC": true,
                "hostNetwork": true,
                "tolerations": [ { "operator": "Exists" } ],
                "nodeSelector": { "kubernetes.io/hostname": $KUBENODE_NODESELECTOR_HOSTNAME },
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

    jq "$KUBENODE_SPEC" \
        --null-input \
        --arg KUBENODE_METADATA_NAME "$KUBENODE_METADATA_NAME" \
        --arg KUBENODE_NODESELECTOR_HOSTNAME "$KUBENODE_NODESELECTOR_HOSTNAME" \
        --compact-output \
        | kubectl create $KUBENODE_NAMESPACE_ARGS --filename - >/dev/null

    kubectl wait pods --for condition=Ready $KUBENODE_NAMESPACE_ARGS "$KUBENODE_METADATA_NAME"
    kubectl exec --stdin --tty $KUBENODE_NAMESPACE_ARGS "$KUBENODE_METADATA_NAME" -- /bin/sh
    kubectl delete pods $KUBENODE_NAMESPACE_ARGS "$KUBENODE_METADATA_NAME"
}

kubesecr() {
    kubectl get secrets --output json $* \
        | jq 'if .kind == "List" then .items[] else . end' \
        | jq '.data[] |= @base64d' \
        | jq '{ name: .metadata.name, data: .data}'
}
