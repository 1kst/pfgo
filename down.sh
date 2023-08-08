#!/bin/bash

urls=(
    "https://download-cdn.jetbrains.com/idea/ideaIU-2023.2.exe"
    "https://download-cdn.jetbrains.com/webstorm/WebStorm-2023.2.exe"
    "https://dldir1.qq.com/weixin/mac/WeChatMac.dmg"
    "https://autopatchcn.yuanshen.com/client_app/download/launcher/20230625145853_3mVP4q9cR5z7F88A/mihoyo/yuanshen_setup_20230619213504.exe"
)

output="/dev/null"

while true; do
    for url in "${urls[@]}"; do
        echo "Downloading file: $url"
        curl --limit-rate 200M -o "$output" "$url"
    done
done
