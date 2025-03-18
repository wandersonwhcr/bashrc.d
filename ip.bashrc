ip-in-cidr() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: ip-in-cidr 127.0.0.1 0.0.0.0/0"
        return 1
    fi

    python3 - "$1" "$2" <<EOF
import ipaddress
import sys

if ipaddress.ip_address(sys.argv[1]) in ipaddress.ip_network(sys.argv[2]):
    print("Found.")
else:
    print("Not Found.")
    sys.exit(2)
EOF
}
