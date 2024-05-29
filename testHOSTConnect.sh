#!/bin/bash

HOST="localhost"

PORTS=(443 8000 8080 9090 9091 9098 9102 9104 9290 19102 {49001..49025})


TIMEOUT=2


test_port() {
    local port=$1
    echo -n "Testing $HOST:$port... "
    if timeout $TIMEOUT bash -c "</dev/tcp/$HOST/$port" &> /dev/null; then
        echo "Connected"
    else
        echo "Failed"
    fi
}


for port in "${PORTS[@]}"; do
    test_port $port
done