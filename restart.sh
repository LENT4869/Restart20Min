#!/bin/bash

# 定义常量
SCREEN_NAME="quili"
NODE_DIR="$HOME/ceremonyclient/node"
NODE_EXEC="./node-2.0.1-linux-amd64"
CPU_RANGE="0"  # CPU 核心范围，若为 "0"，则为空，为全部核心
TIMEOUT_LIMIT=300  # 超时时间，单位为秒（5分钟）

# 函数：关闭旧的 screen 会话
close_old_session() {
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "正在关闭旧的 $SCREEN_NAME 会话..."
        screen -S "$SCREEN_NAME" -X quit
        # 等待旧会话完全关闭
        while screen -list | grep -q "$SCREEN_NAME"; do
            sleep 1
        done
        echo "$SCREEN_NAME 会话已关闭"
    fi
}

# 函数：启动新的 screen 会话
start_new_session() {
    echo "启动新的 $SCREEN_NAME 会话..."
    if [ "$CPU_RANGE" == "0" ]; then
        CPU_CMD=""
    else
        CPU_CMD="taskset -c $CPU_RANGE"
    fi

    if ! screen -dmS "$SCREEN_NAME" bash -c "cd \"$NODE_DIR\" && $CPU_CMD $NODE_EXEC"; then
        echo "启动 $SCREEN_NAME 会话失败！"
        exit 1
    fi
}

# 函数：获取并显示最新的 frame_number 和 error/info 出现次数
get_frame_info() {
    local last_frame_number="N/A"  # 初始值
    local error_count=0  # error 出现次数
    local info_count=0  # info 出现次数
    local last_update_time=$(date +%s)  # 上次更新时间

    while screen -list | grep -q "$SCREEN_NAME"; do
        # 创建硬拷贝并提取最新的输出
        screen -S "$SCREEN_NAME" -p 0 -X hardcopy -h /tmp/screen_output

        # 从输出中提取最新的 frame_number
        frame_number=$(grep -oP '"frame_number":\s*\K\d+' /tmp/screen_output | tail -n 1)

        # 检查是否获取到 frame_number
        if [[ -n "$frame_number" ]]; then
            if [[ "$frame_number" != "$last_frame_number" ]]; then
                last_frame_number="$frame_number"  # 更新为最新值
                last_update_time=$(date +%s)  # 更新最后时间
            fi
        fi

        # 统计 error 和 info 出现次数
        error_count=$(grep -c '"level":"error"' /tmp/screen_output)
        info_count=$(grep -c '"level":"info"' /tmp/screen_output)

        # 检查是否超时
        local current_time=$(date +%s)
        if (( current_time - last_update_time > TIMEOUT_LIMIT )); then
            echo "frame_number 未更新超过 5 分钟，重启脚本..."
            > /tmp/screen_output  # 清空 screen_output 文件
            clear  # 清空终端
            exec "$0"  # 重启当前脚本
        fi

        # 计算未更新时间
        local elapsed=$((current_time - last_update_time))
        local minutes=$((elapsed / 60))
        local seconds=$((elapsed % 60))

        # 显示当前 frame_number、error 出现次数、info 出现次数和未更新时间
        echo -ne "frame_number: $last_frame_number    |    error: $error_count    |    info: $info_count    |    未更新时间: ${minutes}分${seconds}秒\r"
        sleep 1  # 每秒获取一次
    done
}

# 捕捉中断信号并关闭会话
trap 'close_old_session; exit' SIGINT SIGTERM

# 主循环
while true; do
    close_old_session
    start_new_session

    # 启动获取 frame_info 的后台进程
    get_frame_info &

    # 等待进程结束
    wait
done
