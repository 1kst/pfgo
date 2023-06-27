nsta#!/bin/sh
clear
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

service_name="PortForwardGo"
proxy=""
listen=""

echo -e "${Font_SkyBlue}PortForwardGo installation script${Font_Suffix}"

while [ $# -gt 0 ]; do
    case $1 in
    --api)
        api=$2
        shift
        ;;
    --secret)
        secret=$2
        shift
        ;;
    --license)
        license=$2
        shift
        ;;
    --service)
        service_name=$2
        shift
        ;;
    --proxy)
        proxy=$2
        shift
        ;;
    --listen)
        listen=$2
        shift
        ;;
    --china)
        proxy="internal"
        listen="auto"
        ;;
    *)
        echo -e "${Font_Red} Unknown param: $1 ${Font_Suffix}"
        exit
        ;;
    esac
    shift
done

if [ -z "${api}" ]; then
    echo -e "${Font_Red}param 'api' not found${Font_Suffix}"
    exit 1
fi

if [ -z "${secret}" ]; then
    echo -e "${Font_Red}param 'secret' not found${Font_Suffix}"
    exit 1
fi

if [ -z "${license}" ]; then
    echo -e "${Font_Red}param 'license' not found${Font_Suffix}"
    exit 1
fi

if [ -z "${service_name}" ]; then
    echo -e "${Font_Red}param 'service' not found${Font_Suffix}"
    exit 1
fi

echo -e "${Font_Yellow} ** Checking system info...${Font_Suffix}"
case $(uname -m) in
x86)
    arch="386"
    ;;
i386)
    arch="386"
    ;;
x86_64)
    cpu_flags=$(cat /proc/cpuinfo | grep flags | head -n 1 | awk -F ':' '{print $2}')
    if [[ ${cpu_flags} == *avx512* ]]; then
        arch="amd64v4"
    elif [[ ${cpu_flags} == *avx2* ]]; then
        arch="amd64v3"
    elif [[ ${cpu_flags} == *sse3* ]]; then
        arch="amd64v2"
    else
        arch="amd64v1"
    fi
    ;;
armv7*)
    arch="armv7"
    ;;
aarch64)
    arch="arm64"
    ;;
s390x)
    arch="s390x"
    ;;
*)
    echo -e "${Font_Red}Unsupport architecture${Font_Suffix}"
    exit 1
    ;;
esac

if [[ ! -e "/usr/bin/systemctl" ]] && [[ ! -e "/bin/systemctl" ]]; then
    echo -e "${Font_Red}Not found systemd${Font_Suffix}"
    exit 1
fi

if [[ "${listen}" == "auto" ]]; then
    listen=""

    default_out_ip=$(curl -4sL --connect-timeout 1 myip.ipip.net | awk '{print $2}' | awk -F ： '{print $2}')
    default_in_ip="${default_out_ip}"

    bind_ips=$(ip address show | grep inet | grep -v inet6 | grep -v host | grep -v docker | grep -v tun | grep -v tap | awk '{print $2}' | awk -F "/" '{print $1}')
    for bind_ip in ${bind_ips[@]}; do
        out_ip=$(curl -4sL --connect-timeout 1 --interface ${bind_ip} myip.ipip.net | awk '{print $2}' | awk -F ： '{print $2}')
        if [[ -z "${out_ip}" ]]; then
            continue
        fi

        echo -e "${Font_SkyBlue}网卡绑定IP ${bind_ip} 外网IP ${out_ip}${Font_Suffix}"

        if [[ "${out_ip}" != "${default_out_ip}" ]]; then
            default_in_ip="${out_ip}"
            listen="${bind_ip}"
        fi
    done

    echo ""

    if [[ -z "${listen}" ]]; then
        echo -e "${Font_Green}未获取到入口IP 可能是单IP机器${Font_Suffix}"
        echo -e "${Font_Green}外网IP ${default_out_ip}${Font_Suffix}"
    else
        echo -e "${Font_Green}入口绑定IP ${listen} 外网IP ${default_in_ip}${Font_Suffix}"
        echo -e "${Font_Green}出口外网IP ${default_out_ip}${Font_Suffix}"
    fi
fi

while [ -f "/etc/systemd/system/${service_name}.service" ]; do
    read -p "Service ${service_name} is exists, please input a new service name: " service_name
done

dir="/opt/${service_name}"
while [ -d "${dir}" ]; do
    read -p "${dir} is exists, please input a new dir: " dir
done

echo -e "${Font_Yellow} ** Checking release info...${Font_Suffix}"
vers=$(curl -sL https://gitlab.com/api/v4/projects/ProjectPF%2FPortForwardGo/releases | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | awk -F "," '{print $1}' | sed 's/\"//g;s/,//g;s/ //g' | awk -F "v" '{print $2}')
if [ -z "${vers}" ]; then
    echo -e "${Font_Red}Unable to get releases info${Font_Suffix}"
    exit 1
fi
echo -e " Detected lastet version: " ${vers}

echo -e "${Font_Yellow} ** Download release info...${Font_Suffix}"

curl -L -o /tmp/PortForwardGo.tar.gz "https://gitlab.com/ProjectPF/PortForwardGo/-/releases/v"${vers}"/downloads/PortForwardGo_"${vers}"_linux_"${arch}".tar.gz"
if [ ! -f "/tmp/PortForwardGo.tar.gz" ]; then
    echo -e "${Font_Red}Download failed${Font_Suffix}"
    exit 1
fi

tar -xvzf /tmp/PortForwardGo.tar.gz -C /tmp/
if [ ! -f "/tmp/PortForwardGo" ]; then
    echo -e "${Font_Red}Decompression failed${Font_Suffix}"
    exit 1
fi

if [ ! -f "/tmp/systemd/PortForwardGo.service" ]; then
    echo -e "${Font_Red}Decompression failed${Font_Suffix}"
    exit 1
fi

if [ ! -f "/tmp/examples/backend.json" ]; then
    echo -e "${Font_Red}Decompression failed${Font_Suffix}"
    exit 1
fi

mkdir -p ${dir}
chmod 777 /tmp/PortForwardGo
mv /tmp/PortForwardGo ${dir}

sed -i "s#{api}#${api}#g" /tmp/examples/backend.json
sed -i "s#{secret}#${secret}#g" /tmp/examples/backend.json
sed -i "s#{license}#${license}#g" /tmp/examples/backend.json
sed -i "s#{proxy}#${proxy}#g" /tmp/examples/backend.json
sed -i "s#{listen}#${listen}#g" /tmp/examples/backend.json
mv /tmp/examples/backend.json ${dir}

mv /tmp/systemd/PortForwardGo.service /etc/systemd/system/${service_name}.service
sed -i "s#{dir}#${dir}#g" /etc/systemd/system/${service_name}.service

rm -rf /tmp/*

echo -e "${Font_Yellow} ** Optimize system config...${Font_Suffix}"

if [[ -z "${listen}" ]]; then
    echo "net.ipv4.ip_local_port_range = 60000 65535" >/etc/sysctl.d/97-system-port-range.conf
    echo -e "${Font_Green}已修改系统对外连接占用端口为 60000-65535, 配置文件 /etc/sysctl.d/97-system-port-range.conf${Font_Suffix}"
else
    echo "net.ipv4.ip_local_port_range = 1024 65535" >/etc/sysctl.d/97-system-port-range.conf
    echo -e "${Font_Green}已修改系统对外连接占用端口为 1024-65535, 配置文件 /etc/sysctl.d/97-system-port-range.conf${Font_Suffix}"
fi

echo "vm.swappiness = 10
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
fs.pipe-max-size = 1048576
fs.pipe-user-pages-hard = 0
fs.pipe-user-pages-soft = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0

# socket status
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 3000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2

# tcp window
net.core.wmem_default = 262144
net.core.wmem_max = 67108864
net.core.somaxconn = 3276800
net.core.optmem_max = 81920
net.core.rmem_default = 262144
net.core.rmem_max = 67108864
net.core.netdev_max_backlog = 400000
net.core.netdev_budget = 600
net.ipv4.tcp_max_orphans = 3276800

# forward
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1

# ipv4
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.ipv4.tcp_mem = 786432 2097152 3145728 
net.ipv4.tcp_rmem = 4096 524288 67108864
net.ipv4.tcp_wmem = 4096 524288 67108864
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# netfiliter iptables
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 15
net.netfilter.nf_conntrack_tcp_timeout_established = 350
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_buckets = 25000000" >/etc/sysctl.d/98-optimize.conf
echo -e "${Font_Green}已开启BBR和系统调优, 配置文件 /etc/sysctl.d/98-optimize.conf${Font_Suffix}"

echo "* soft nofile 1048576
* hard nofile 1048576
* soft nproc 1048576
* hard nproc 1048576
* soft core 1048576
* hard core 1048576
* hard memlock unlimited
* soft memlock unlimited" >/etc/security/limits.conf
echo -e "${Font_Green}已解除系统ulimit限制, 配置文件 /etc/security/limits.conf${Font_Suffix}"

echo -e "${Font_Green}应用新的系统配置...${Font_Suffix}"
sysctl -p >/dev/null 2>&1
sysctl --system >/dev/null 2>&1
echo -e "${Font_Green}优化完成, 部分优化可能需要重启系统才能生效${Font_Suffix}"

echo -e "${Font_Yellow} ** Starting program...${Font_Suffix}"
systemctl daemon-reload
systemctl enable --now ${service_name}

echo -e "${Font_Green} [Success] Completed installation${Font_Suffix}"
