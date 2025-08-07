#!/bin/bash

# Docker容器启动脚本
set -e

echo "启动OpenCart容器..."

# 安装PHP扩展
echo "安装PHP扩展..."
apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libgd-dev \
    libwebp-dev

docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
docker-php-ext-install pdo_mysql mysqli zip gd mbstring xml curl opcache

# 等待数据库就绪
echo "等待数据库连接..."
until php -r "
    \$host = getenv('DB_HOST');
    \$port = 3306;
    \$user = getenv('DB_USER');
    \$pass = getenv('DB_PASSWORD');
    \$db = getenv('DB_NAME');
    
    try {
        \$pdo = new PDO(\"mysql:host=\$host;port=\$port;dbname=\$db\", \$user, \$pass);
        echo \"数据库连接成功\n\";
        exit(0);
    } catch (PDOException \$e) {
        echo \"等待数据库连接...\n\";
        exit(1);
    }
"; do
    sleep 2
done

# 检查OpenCart是否已安装
if [ ! -f /var/www/html/config.php ]; then
    echo "首次启动，开始安装OpenCart..."
    /usr/local/bin/install-opencart.sh
fi

# 设置文件权限
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 777 /var/www/html/storage
chmod -R 777 /var/www/html/system/storage

echo "OpenCart启动完成！"

# 启动PHP-FPM
exec "$@"
