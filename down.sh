#!/bin/bash

url="https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/mediacreationtool.exe"

while true
do
    echo "Downloading file..."
    wget --progress=bar:force -q "$url" 2>&1 | tee /dev/tty
    echo "Download complete."
done
