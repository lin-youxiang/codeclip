import os
import sqlite3
import re
import time
import pyperclip
from pathlib import Path

def get_latest_message_text(db_path):
    # Connect to database (read-only)
    # Use URI mode to open read-only connection: "file:{}?mode=ro"
    # Reference: https://sqlite.org/c3ref/open.html
    uri = f"file:{db_path}?mode=ro"
    conn = sqlite3.connect(uri, uri=True)
    cursor = conn.cursor()
    
    # message table typically has a text field storing message content
    # date field stores timestamp in Apple-specific format
    # Here we simply get the latest message by ROWID or date DESC
    cursor.execute("SELECT text FROM message ORDER BY date DESC LIMIT 1;")
    row = cursor.fetchone()
    
    conn.close()
    
    if row and row[0]:
        return row[0]
    return None

def extract_verification_code(text):
    # Use regex to match 4-8 consecutive digits
    pattern = r"\b\d{4,8}\b"
    matches = re.findall(pattern, text)
    if matches:
        # Assume first match is the desired verification code
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
                print(f"Found new verification code and copied to clipboard: {code}")
                last_copied_code = code
        else:
            print("No latest message found or message content is empty.")
        
        # Check every 10 seconds
        time.sleep(5)

if __name__ == "__main__":
    main()