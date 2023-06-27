#!/bin/bash

# Download the file
wget -P /tmp https://github.com/1kst/pfgo/releases/download/1.1.2/pofogo.zip

# Unzip the file without password
unzip /tmp/pofogo.zip -d /tmp

# Check if unzip was successful
if [ $? -eq 0 ]; then
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

  # Output installation completed
  echo "安装完毕"
else
  # Output error message
  echo "解压失败"
fi
