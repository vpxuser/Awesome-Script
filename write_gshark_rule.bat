@echo off
setlocal enabledelayedexpansion

REM 设置URL
set "URL=http://127.0.0.1:8008/api/filter/createFilter"

REM 设置x-token
set "TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVVUlEIjoiOTY2OGNmNTctMTUyOC00ODY2LThhMmItZWU5ZjZiOTdhNDFiIiwiSUQiOjEsIlVzZXJuYW1lIjoiZ3NoYXJrIiwiTmlja05hbWUiOiLotoXnuqfnrqHnkIblkZgiLCJBdXRob3JpdHlJZCI6Ijg4OCIsIkJ1ZmZlclRpbWUiOjg2NDAwLCJleHAiOjE3Mjk1ODk0NTQsImlzcyI6InFtUGx1cyIsIm5iZiI6MTcyODQ1NjY0NX0.OFAIFxaCgUSBlm3h7i13puOYqnR4ykCK3J1Yq3nLkJM"

REM 读取字典文件
set "DICTIONARY_FILE=gshark_rule_2.txt"
for /f "delims=" %%i in (%DICTIONARY_FILE%) do (
    set "CONTENT=%%i"
    set "BODY={\"filter_type\": \"whitelist\", \"filter_class\": \"sec_keyword\", \"content\": \"!CONTENT!\"}"

    REM 发送POST请求
    curl -X POST "%URL%" ^
    -H "Content-Type: application/json" ^
    -H "x-token: %TOKEN%" ^
    -d "!BODY!"

    REM 显示当前使用的值
    echo , Sending with content: !CONTENT!
)

endlocal
