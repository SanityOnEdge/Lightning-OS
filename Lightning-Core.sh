#!/bin/bash
# Lightning-Core V3.6.2: Power & Status
STATUS_FILE="/tmp/lightning_status"

start_turbo() {
    if [[ ! -f $STATUS_FILE ]] || [[ $(cat $STATUS_FILE) != "LIGHTNING: ON" ]]; then
        echo "LIGHTNING: ON" > $STATUS_FILE
        cpupower frequency-set --governor performance > /dev/null 2>&1
        sysctl -w vm.max_map_count=2147483642 > /dev/null
        sysctl -w vm.swappiness=10 > /dev/null
    fi
}

stop_turbo() {
    if [[ ! -f $STATUS_FILE ]] || [[ $(cat $STATUS_FILE) != "LIGHTNING: OFF" ]]; then
        echo "LIGHTNING: OFF" > $STATUS_FILE
        cpupower frequency-set --governor powersave > /dev/null 2>&1
    fi
}

case "$1" in
    start) start_turbo ;;
    stop)  stop_turbo ;;
    *) echo "Użycie: $0 {start|stop}" ;;
esac