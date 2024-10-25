#!/bin/bash

# 設定要執行的程序相對路徑
PROGRAM="./node-2.0.1-linux-amd64"
# 設定要運行的時間（秒）
RUN_TIME=300  # 5分鐘 = 300秒
# 設定重新啟動的等待時間（秒）
RESTART_WAIT=10  # 10秒鐘

while true; do
    # 啟動程序
    $PROGRAM --core=16 --parent-process=$$ &  # 在後台運行，並獲取其進程 ID
    PID=$!  # 獲取最近一個後台進程的 PID

    # 等待指定的運行時間
    sleep $RUN_TIME

    # 發送終止信號 (SIGINT) 到進程
    kill -SIGINT $PID  # 這模擬 Ctrl+C

    # 等待進程結束
    wait $PID

    echo "程序已停止，等待 $RESTART_WAIT 秒後重新啟動..."
    
    # 等待指定的重新啟動時間
    sleep $RESTART_WAIT
done
