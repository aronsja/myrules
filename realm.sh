#!/bin/bash

# 下载realm
wget -O realm.tar.gz https://mirror.ghproxy.com/https://github.com/zhboner/realm/releases/download/v2.5.2/realm-x86_64-unknown-linux-gnu.tar.gz

# 解压
tar -xvf realm.tar.gz

# 赋予执行权限
chmod +x realm

# 创建配置文件
cat > /root/config.toml <<EOF
[[endpoints]]
listen = "[::]:5000"
remote = "8.8.8.8:443"

[[endpoints]]
listen = "[::]:6000"
remote = "[2400:3200::1]:443"
EOF

# 创建systemd服务文件
cat > /etc/systemd/system/realm.service <<EOF
[Unit]
Description=realm
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
DynamicUser=true
WorkingDirectory=/root
ExecStart=/root/realm -c /root/config.toml

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd，启用并启动Realm服务
systemctl daemon-reload
systemctl enable realm
systemctl restart realm
