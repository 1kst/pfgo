安装完后打开/opt/PortForwardGo

自己修改配置为你自己的信息


常用命令：

查看状态：systemctl status PortForwardGo

启动：systemctl start PortForwardGo

重启：systemctl restart PortForwardGo

停止：systemctl stop PortForwardGo

日志：tail -f /opt/PortForwardGo/run.log

卸载：systemctl disable --now PortForwardGo; rm -f /etc/systemd/system/PortForwardGo.service; rm -rf /opt/PortForwardGo

卸载单端：systemctl disable --now SecureTunnel
rm -f /etc/systemd/system/SecureTunnel.service
rm -rf /opt/SecureTunnel






