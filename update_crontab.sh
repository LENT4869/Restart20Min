#!/bin/bash

# 設置腳本的路徑
SCRIPT_PATH="/ceremonyclient/node/Restart.sh"

# 創建新的 cron 任務
NEW_CRON="*/5 * * * * $SCRIPT_PATH"

# 將當前的 crontab 輸出到變量中
CURRENT_CRON=$(crontab -l 2>/dev/null)

# 檢查是否已經存在相同的 cron 任務
if echo "$CURRENT_CRON" | grep -q "$SCRIPT_PATH"; then
    echo "Cron job already exists. Updating the existing job."
    # 使用 sed 來替換掉舊的 cron 任務
    (echo "$CURRENT_CRON" | sed "s|.*$SCRIPT_PATH|$NEW_CRON|"; crontab -l | grep -v "$SCRIPT_PATH") | crontab -
else
    echo "Adding new cron job."
    # 如果不存在，則將新的任務添加到 crontab
    (echo "$CURRENT_CRON"; echo "$NEW_CRON") | crontab -
fi

echo "Crontab updated successfully."

chmod +x update_crontab.sh
