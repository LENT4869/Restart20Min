#!/bin/bash

# 檢查並關閉已有的進程
pkill -f "./node-2.0.1-linux-amd64"

# 重啟 ./node-2.0.1-linux-amd64
cd /path/to/ceremonyclient/node
./node-2.0.1-linux-amd64 &

chmod +x /path/to/restart_node.sh
