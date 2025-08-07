#!/bin/bash

# OpenCart安装脚本
set -e

echo "开始安装OpenCart..."

# 检查OpenCart压缩包是否存在
if [ ! -f /tmp/opencart.zip ]; then
    echo "错误: OpenCart压缩包不存在"
    exit 1
fi

# 清空web目录
echo "清空web目录..."
rm -rf /var/www/html/*

# 解压OpenCart
echo "解压OpenCart..."
unzip -q /tmp/opencart.zip -d /tmp/

# 查找解压后的目录
OPENCART_DIR=$(find /tmp -name "upload" -type d | head -n 1)
if [ -z "$OPENCART_DIR" ]; then
    echo "错误: 无法找到OpenCart文件"
    exit 1
fi

# 复制文件到web目录
echo "复制文件到web目录..."
cp -r $OPENCART_DIR/* /var/www/html/

# 创建storage目录结构
echo "创建storage目录..."
mkdir -p /var/www/html/storage/{cache,logs,modification,session,upload}

# 设置权限
echo "设置文件权限..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 777 /var/www/html/storage
chmod -R 777 /var/www/html/system/storage

# 创建基本的配置文件模板（OpenCart 4.x需要）
echo "创建配置文件模板..."
cat > /var/www/html/config.php << 'EOF'
<?php
// OpenCart 4.x 基本配置文件
// 此文件将在安装向导中自动更新
EOF

cat > /var/www/html/admin/config.php << 'EOF'
<?php
// OpenCart 4.x 管理后台基本配置文件
// 此文件将在安装向导中自动更新
EOF

# 设置配置文件权限，确保安装向导可以写入
echo "设置配置文件权限..."
chown www-data:www-data /var/www/html/config.php /var/www/html/admin/config.php
chmod 666 /var/www/html/config.php /var/www/html/admin/config.php

echo "OpenCart文件安装完成！"
echo "请访问 http://localhost 进行安装配置"
