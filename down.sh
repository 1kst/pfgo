#!/bin/bash

urls=(
    "https://download-cdn.jetbrains.com/idea/ideaIU-2023.2.exe"
    "https://download-cdn.jetbrains.com/webstorm/WebStorm-2023.2.exe"
    "https://dldir1.qq.com/weixin/mac/WeChatMac.dmg"
)

output="/dev/null"

while true; do
    for url in "${urls[@]}"; do
        echo "Downloading file: $url"
        trickle -s -u 20 -d 20 curl -o "$output" "$url"
    done
done
