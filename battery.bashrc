battery () {
    for BAT in `echo /sys/class/power_supply/BAT*`; do
        echo "$BAT"
        echo -n "Status: "
        cat "$BAT/status"
        echo -n "Capacity: "
        cat "$BAT/capacity"
    done
}
