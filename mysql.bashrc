mysqlz() {
    if [ -z "$1" ]; then
        sed 's/^\[client_\(.\+\)\]$/\1/p' ~/.my.cnf --silent \
            | sort
        return 0
    fi

    MYSQL_DEFAULTS_GROUP_SUFFIX="_$1"

    shift 1

    mysql \
        "--defaults-group-suffix=$MYSQL_DEFAULTS_GROUP_SUFFIX" \
        "$@"
}
