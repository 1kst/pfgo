#!/bin/bash

# Download the file
wget -P /tmp https://ghproxy.com/https://github.com/1kst/pfgo/releases/download/1.1.2/pfgo.zip

# Unzip the file
unzip /tmp/pfgo.zip -d /tmp

# Copy PortForwardGo.service to /etc/systemd/system
cp /tmp/PortForwardGo.service /etc/systemd/system/
chmod 755 /etc/systemd/system/PortForwardGo.service

# Create PortForwardGo directory in /opt and copy files
mkdir /opt/PortForwardGo
cp /tmp/backend.json /opt/PortForwardGo/
cp /tmp/run.log /opt/PortForwardGo/
cp /tmp/firewall.log /opt/PortForwardGo/
cp /tmp/PortForwardGo /opt/PortForwardGo/
chmod 777 /opt/PortForwardGo/PortForwardGo
chmod 755 /opt/PortForwardGo/backend.json
chmod 755 /opt/PortForwardGo/run.log
chmod 755 /opt/PortForwardGo/firewall.log

# Enable and start the service
systemctl enable PortForwardGo.service
systemctl start PortForwardGo.service

# Clean up /tmp directory
rm /tmp/pfgo.zip
rm /tmp/PortForwardGo.service
rm /tmp/backend.json
rm /tmp/run.log
rm /tmp/firewall.log
rm /tmp/PortForwardGo

# Output installation completed
echo "安装完毕"
