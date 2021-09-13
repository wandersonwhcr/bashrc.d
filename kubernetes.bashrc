kubesh() {
    kubectl run --rm --stdin --tty --image=alpine alpine-`date-to-identifier` $* -- /bin/sh
}

export -f kubesh
