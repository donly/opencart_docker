# OpenCart Docker 部署方案

## 项目结构
```
opencart/
├── docker-compose.yml          # Docker Compose配置
├── install-opencart.sh         # OpenCart安装脚本
├── docker-entrypoint.sh        # 容器启动脚本
├── nginx/
│   └── nginx.conf             # Nginx配置
├── opencart.zip               # OpenCart压缩包
└── README.md                  # 说明文档
```

## 技术栈
- **Web服务器**: Nginx 1.25 (官方镜像)
- **PHP**: PHP 8.1-FPM (官方镜像)
- **数据库**: MariaDB 10.11 (官方镜像)

## 部署步骤

### 1. 准备环境
确保您的系统已安装Docker和Docker Compose：
```bash
# 检查Docker版本
docker --version
docker-compose --version
```

### 2. 启动服务
```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 3. 访问OpenCart
- **前台**: http://localhost
- **管理后台**: http://localhost/admin

### 4. 数据库配置
在OpenCart安装向导中使用以下数据库信息：
- **数据库主机**: mariadb
- **数据库名**: opencart
- **用户名**: opencart_user
- **密码**: opencart_password
- **端口**: 3306

## 服务说明

### MariaDB (数据库)
- 端口: 3306
- 数据卷: mariadb_data
- 环境变量:
  - MYSQL_ROOT_PASSWORD: opencart_root_password
  - MYSQL_DATABASE: opencart
  - MYSQL_USER: opencart_user
  - MYSQL_PASSWORD: opencart_password

### PHP-FPM (应用)
- 基于官方php:8.1-fpm镜像
- 自动安装所需PHP扩展
- 自动解压和配置OpenCart

### Nginx (Web服务器)
- 端口: 80, 443
- 配置了OpenCart的URL重写规则
- 启用了Gzip压缩和安全头

## 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f [服务名]

# 进入容器
docker-compose exec [服务名] bash

# 备份数据库
docker-compose exec mariadb mysqldump -u root -p opencart > backup.sql

# 恢复数据库
docker-compose exec -T mariadb mysql -u root -p opencart < backup.sql
```

## 数据持久化
- 数据库数据: `mariadb_data` 卷
- OpenCart文件: `opencart_data` 卷

## 安全建议
1. 修改默认密码
2. 配置SSL证书
3. 定期备份数据
4. 更新OpenCart到最新版本

## 故障排除

### 1. 容器启动失败
```bash
# 查看详细日志
docker-compose logs [服务名]

# 重新构建
docker-compose down
docker-compose up -d --build
```

### 2. 数据库连接失败
```bash
# 检查数据库状态
docker-compose exec mariadb mysql -u root -p

# 检查网络连接
docker-compose exec opencart ping mariadb
```

### 3. 文件权限问题
```bash
# 修复权限
docker-compose exec opencart chown -R www-data:www-data /var/www/html
docker-compose exec opencart chmod -R 755 /var/www/html
docker-compose exec opencart chmod -R 777 /var/www/html/storage
```

## 性能优化
1. 配置OPcache
2. 使用CDN加速静态文件
3. 数据库优化
4. 后续可考虑添加Redis缓存

## 更新OpenCart
1. 备份当前数据
2. 替换opencart.zip文件
3. 重新启动服务
4. 运行OpenCart更新脚本
