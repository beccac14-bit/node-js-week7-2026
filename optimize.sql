-- ============================================================
-- 🚑 你的處方箋（工單 1~5 的解法寫在這裡）
--
-- 寫法：對症下索引，例如
--   CREATE INDEX idx_xxx ON 表名 (欄位);
--
-- 提醒：
-- 1. 跑 npm run optimize 會執行這個檔案（重複執行可在 CREATE INDEX 後加上 IF NOT EXISTS）
-- 2. 如果更換新索引，原先沒有使用的索引記得 DROP（索引並非越多越好）
-- 3. 工單 6 的撰寫可到：queries/06-rewrite.sql
-- ============================================================

-- 工單 1：客服查會員
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- 工單 2：企業會員的課表
CREATE INDEX IF NOT EXISTS idx_course_bookings_companycourselist on course_bookings(user_id, cancelled_at);

-- 工單 3：最新購買紀錄牆
CREATE INDEX IF NOT EXISTS idx_credit_purchases_purchase_at on credit_purchases(purchase_at);


-- 工單 4：首頁「進行中課程」
-- CREATE INDEX IF NOT EXISTS idx_courses_time on courses(start_at, end_at); 
/*>> 助教建議：複合索引 courses(start_at, end_at) 可以再優化順序，目前寫法 start_at 在前方，
實際上還是會先跑過大部份資料，沒有篩掉多少資料，因為 courses 課程總共有 15 萬筆，但目前大部分都是已結束的課程，
只剩 200 堂進行中 + 0.5% 未開課的部分（建置資料庫使用的 npm run seed 指令有該筆資訊），
所以這裡較適合使用 end_at 作為第一個篩選欄位，因為可以快速篩掉前面大部分已結束的歷史課程，
複合索引會建議優先使用選擇性高的欄位先篩掉大部分資料。
*/

-- 修正後
CREATE INDEX IF NOT EXISTS idx_courses_time on courses(end_at, start_at); 

-- 工單 5：上週開課課程的教練報名統計（思考方向：需新增兩個索引）


-- 修正後
    -- 因應工單 4 調整，新增以 start_at 排序的索引
    -- 複合索引 course_id, cancelled_at 調整為部分索引
CREATE INDEX IF NOT EXISTS idx_course_bookings_startat on courses(start_at);
CREATE INDEX IF NOT EXISTS idx_course_bookings_course_id_cancelled on course_bookings(course_id)
WHERE cancelled_at is NULL;

-- 加分題（選做）：使用部分索引（partial index）讓工單 2 的索引更小、更有效率

CREATE INDEX IF NOT EXISTS idx_course_bookings_companycourselist2 on course_bookings(user_id)
WHERE cancelled_at is NULL;