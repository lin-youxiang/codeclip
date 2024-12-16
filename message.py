import os
import sqlite3
import re
import time
import pyperclip
from pathlib import Path

def get_latest_message_text(db_path):
    # 连接数据库（只读）
    # 使用 uri 模式打开只读连接： "file:{}?mode=ro"
    # 参考: https://sqlite.org/c3ref/open.html
    uri = f"file:{db_path}?mode=ro"
    conn = sqlite3.connect(uri, uri=True)
    cursor = conn.cursor()
    
    # message 表通常包含 text 字段存储文本消息
    # date 字段存储消息时间戳，但为 Apple 特定格式
    # 这里我们简单根据 ROWID 或 date DESC 来取最新消息
    cursor.execute("SELECT text FROM message ORDER BY date DESC LIMIT 1;")
    row = cursor.fetchone()
    
    conn.close()
    
    if row and row[0]:
        return row[0]
    return None

def extract_verification_code(text):
    # 使用正则匹配 4~8 位连续数字
    pattern = r"\b\d{4,8}\b"
    matches = re.findall(pattern, text)
    if matches:
        # 假设第一个匹配即为所需验证码
        return matches[0]
    return None

def copy_to_clipboard(text):
    pyperclip.copy(text)

def main():
    db_path = str(Path.home() / "Library" / "Messages" / "chat.db")
    last_copied_code = None
    
    while True:
        latest_msg = get_latest_message_text(db_path)
        if latest_msg:
            code = extract_verification_code(latest_msg)
            if code and code != last_copied_code:
                copy_to_clipboard(code)
                print(f"发现新验证码并已复制到剪贴板: {code}")
                last_copied_code = code
        else:
            print("未找到最新消息或消息内容为空。")
        
        # 每 10 秒检查一次
        time.sleep(10)

if __name__ == "__main__":
    main()