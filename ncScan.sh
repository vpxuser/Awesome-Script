#!/bin/bash

# 检查是否提供了IP地址和端口列表
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <target_host> <ports>"
    echo "Example: $0 192.168.1.1 8080,443,9090,443-1000"
    exit 1
fi

# 目标主机地址
HOST=$1

# 端口列表
IFS=',' read -r -a PORTS <<< "$2"

# 超时时间（秒）
TIMEOUT=1

# 测试端口函数
test_port() {
    local port=$1
    if nc -z -w $TIMEOUT $HOST $port &> /dev/null; then
        echo -en "Testing $HOST:$port... Connected\n"
    else
        echo -en "Testing $HOST:$port... Failed\n"
    fi
}

# 遍历端口列表并测试
for port_range in "${PORTS[@]}"; do
    if [[ $port_range == *"-"* ]]; then
        IFS='-' read -r start_port end_port <<< "$port_range"
        for ((port=start_port; port<=end_port; port++)); do
            test_port $port &
        done
    else
        test_port $port_range &
    fi
done

# 等待所有后台任务完成
wait
