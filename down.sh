#!/bin/bash

url="https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/mediacreationtool.exe"

while true
do
    wget -q -O /dev/null "$url"
done
