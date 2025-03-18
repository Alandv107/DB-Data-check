# 影片發燒系統使用說明

## 系統概述

「影片發燒系統」是一個基於命令行界面的應用程式，使用 dialog 提供互動式界面，能夠查詢和顯示不同社交媒體平台（Instagram、TikTok 和 YouTube）上熱門影片的數據統計資訊。系統從 MySQL 數據庫中提取信息，幫助用戶快速了解各平台上最受歡迎的內容。

## 系統需求

- Linux 或類 Unix 作業系統
- Bash Shell
- dialog 套件（用於互動式界面）
- MySQL 客戶端
- 網絡連接以訪問數據庫

## 安裝

1. 確保系統已安裝 dialog 和 MySQL 客戶端：
   ```bash
   sudo apt-get update
   sudo apt-get install dialog mysql-client
   ```

2. 下載腳本並設置執行權限：
   ```bash
   chmod +x 腳本名稱.sh
   ```

## 配置

腳本開頭部分包含數據庫連接配置，根據需要修改以下參數：

```bash
DB_HOST="labdb.coded2.fun"  # 數據庫主機地址
DB_USER="alan"              # 數據庫用戶名
DB_PASS="123456"            # 數據庫密碼
DB_NAME="KOL_ALAN"          # 數據庫名稱
```

## 使用說明

### 啟動系統

```bash
./腳本名稱.sh
```

### 登入流程

1. 系統啟動後會顯示登入界面，要求輸入用戶名和密碼
2. 預設登入憑證：
   - 用戶名：admin
   - 密碼：password
3. 用戶有三次嘗試機會，超過後系統將自動退出

### 主要功能

登入成功後，系統提供以下功能：

1. **選擇平台**：
   - Instagram
   - TikTok
   - YouTube

2. **查詢類型**：
   - 觀看數最高前五名
   - 讚數最高前五名
   - 取消查詢

3. **查詢結果顯示**：
   - 系統將顯示所選平台的查詢結果
   - 結果包含影片相關資訊（用戶名/頻道名、影片ID、觀看數、讚數等）

4. **繼續操作**：
   - 每次查詢後，系統會詢問是否繼續查詢其他資料
   - 選擇「否」將退出系統

## 數據庫結構

系統使用以下三張表格來存儲各平台的數據：

1. **instagram_videos**：
   - 包含欄位：username, video_id, views, likes, comments, link, saves, shares

2. **tiktok_videos**：
   - 包含欄位：username, video_number, views, url, likes, comments, saves, shares

3. **youtube_videos**：
   - 包含欄位：channel_name, video_id, views, likes, comments

## 錯誤處理

系統提供以下錯誤處理機制：

- 登入失敗超過三次後退出
- 平台選擇無效時顯示錯誤信息
- 查詢無結果時提示用戶確認數據是否已匯入

## 安全注意事項

- 本腳本中包含明文數據庫憑證，僅用於測試環境
- 在生產環境中，建議使用環境變量或外部配置文件存儲敏感信息
- 建議定期更改系統登入密碼

## 程序流程圖

```
開始
 ↓
登入（最多嘗試3次）
 ↓
選擇平台（Instagram/TikTok/YouTube）
 ↓
選擇查詢類型（觀看數/讚數最高）
 ↓
執行查詢並顯示結果
 ↓
是否繼續查詢？→ 是 → 返回平台選擇
 ↓ 否
結束
```

## 常見問題

1. **Q: 無法連接到數據庫怎麼辦？**  
   A: 請檢查數據庫連接參數是否正確，以及網絡連接是否正常。

2. **Q: 查詢結果為空怎麼辦？**  
   A: 請確認所選平台的數據是否已匯入數據庫。

3. **Q: 如何添加新的查詢類型？**  
   A: 修改腳本中的 `query_type` 部分，添加新的 case 分支和對應的 SQL 查詢。
