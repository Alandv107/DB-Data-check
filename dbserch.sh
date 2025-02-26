#!/bin/bash
DB_HOST="l"
DB_USER="alan"
DB_PASS=""
DB_NAME="KOL_ALAN"
TEMP_FILE="query_result.txt"
attempt=1
max_attempt=3
login_status=false
remain_chance=3

while [ $attempt -le $max_attempt ] && [ "$login_status" = false ]; do
    usr_name=$(dialog --stdout --title "影片發燒系統登入" --inputbox "請輸入用戶名稱: " 10 30);
    if [ "$usr_name" = "" ]; then
        dialog --title "System Information" --msgbox "已取消登入" 10 30;
        exit 1
    fi
    
    usr_pwd=$(dialog --stdout --title "影片發燒系統登入" --insecure --passwordbox "請輸入用戶密碼: " 10 30);
    if [ "$usr_pwd" = "" ]; then
        dialog --title "System Information" --msgbox "已取消登入" 10 30;
        exit 1
    fi
    
    if [ "$usr_name" = "admin" ] && [ "$usr_pwd" = "password" ]; then
        login_status=true
        dialog --title "System Information" --msgbox "歡迎登入系統" 10 30;
    else
        remain_chance=$((max_attempt - attempt));
        if [ $remain_chance -gt 0 ]; then
            dialog --title "System Information" --msgbox "帳號或密碼錯誤，您還有 $remain_chance 次機會" 10 36;
        else
            dialog --title "System Information" --msgbox "已嘗試超過 $max_attempt 次，請重新執行" 10 30;
            exit 1
        fi
        attempt=$((attempt + 1))
    fi
done

# 建立主查詢迴圈
while true; do
    platform=$(dialog --stdout --menu "選擇要檢查的平台" 15 50 3 \
        "1" "Instagram" \
        "2" "TikTok" \
        "3" "YouTube")
        
    if [ -z "$platform" ]; then
        dialog --msgbox "未選擇任何平台，程式結束。" 8 40
        exit 1
    fi
    
    if [ "$platform" = "1" ]; then
        table="instagram_videos"
        columns="username, video_id, views, likes, comments, link, saves, shares"
        filter_field="reel_index"
        filter_label="Reels 編號"
    elif [ "$platform" = "2" ]; then
        table="tiktok_videos"
        columns="username, video_number, views, url, likes, comments, saves, shares"
        filter_field="video_id"
        filter_label="影片 ID"
    elif [ "$platform" = "3" ]; then
        table="youtube_videos"
        columns="channel_name, video_id, views, likes, comments"
        filter_field="video_id"
        filter_label="影片 ID"
    else
        dialog --msgbox "⚠ 錯誤：無效的平台選擇！" 8 40
        exit 1
    fi
    
    query_type=$(dialog --stdout --menu "選擇查詢類型" 15 50 3 \
        "1" "觀看數最高前五名" \
        "2" "讚數最高前五名" \
        "3" "取消查詢")
        
    case $query_type in
        1)
            query="SELECT ${columns} FROM ${table} ORDER BY CAST(views AS DECIMAL(20,0)) DESC LIMIT 5;"
            ;;
        2)
            query="SELECT ${columns} FROM ${table} ORDER BY CAST(likes AS DECIMAL(20,0)) DESC LIMIT 5;"
            ;;
        3)
            dialog --msgbox "查詢已取消。" 8 40
            continue
            ;;
        *)
            dialog --msgbox "無效的選擇" 8 40
            continue
            ;;
    esac
    
    dialog --yesno "是否查詢 ${table} 的資料？" 8 40
    if [ $? -ne 0 ]; then
        dialog --msgbox "查詢已取消。" 8 40
        continue
    fi
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" --default-character-set=utf8mb4 -e "$query" > "$TEMP_FILE"
    
    if [ ! -s "$TEMP_FILE" ]; then
        dialog --msgbox "⚠ 沒有找到 ${platform} 的資料！請確認資料是否已匯入。" 8 50
        rm -f "$TEMP_FILE"
        continue
    fi
    
    dialog --textbox "$TEMP_FILE" 20 80
    rm -f "$TEMP_FILE"
    
    # 詢問使用者是否繼續查詢
    dialog --yesno "是否要繼續查詢其他資料？" 8 40
    if [ $? -ne 0 ]; then
        dialog --msgbox "程式結束，再見！" 8 40
        break
    fi
done