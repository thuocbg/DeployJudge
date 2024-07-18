#!/bin/bash

# Cập nhật và cài đặt các gói cần thiết
sudo apt-get update && sudo apt-get install -y vim python3-pip curl git
pip3 install docker-compose

# Cài đặt Docker
sudo curl -sSL get.docker.com | sh

# Clone repo
git clone --recursive https://github.com/VNOI-Admin/vnoj-docker.git
cd vnoj-docker/dmoj

# Khởi tạo thiết lập
./scripts/initialize

# Cấu hình biến môi trường
cp environment/mysql-admin.env.example environment/mysql-admin.env
cp environment/mysql.env.example environment/mysql.env
cp environment/site.env.example environment/site.env

# Thiết lập nội dung cho file site.env
cat <<EOT > environment/site.env
HOST=77.37.47.84
SITE_FULL_URL=http://77.37.47.84/
MEDIA_URL=http://77.37.47.84/

DEBUG=0
SECRET_KEY=abcdef12345678

# Event server
EVENT_DAEMON_POST=ws://wsevent:15101/

# Redis and Celery
REDIS_CACHING_URL=redis://redis:6379/0
CELERY_BROKER_URL=redis://redis:6379/1
CELERY_RESULT_BACKEND=redis://redis:6379/1

# Bridge
BRIDGED_HOST=bridged
EOT

# Thiết lập nội dung cho file mysql.env
cat <<EOT > environment/mysql.env
MYSQL_HOST=db
MYSQL_DATABASE=dmoj
MYSQL_USER=dmoj
MYSQL_PASSWORD=thdt1234
EOT

# Thiết lập nội dung cho file mysql-admin.env
cat <<EOT > environment/mysql-admin.env
MYSQL_ROOT_PASSWORD=thdt1234
EOT

# Tạo thư mục cấu hình nginx nếu chưa tồn tại
mkdir -p nginx/conf.d

# Thiết lập nội dung cho file nginx.conf
cat <<EOT > nginx/conf.d/nginx.conf
server {
    listen       80;
    listen       [::]:80;
    server_name  oj.vnoi.info;
    client_max_body_size 48M;

    add_header X-UA-Compatible "IE=Edge,chrome=1";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    charset utf-8;
    try_files \$uri @icons;
    error_page 502 504 /502.html;

    location ~ ^/502\.html\$|^/logo\.png\$|^/robots\.txt\$ {
        root /assets/;
    }

    location @icons {
        root /assets/resources/icons/;
        log_not_found off;
        error_page 403 = @uwsgi;
        error_page 404 = @uwsgi;
    }

    location @uwsgi {
        uwsgi_read_timeout 600;
        uwsgi_pass site:8000;
        include uwsgi_params;
        uwsgi_param SERVER_SOFTWARE nginx/\$nginx_version;
    }

    location /static {
        gzip_static on;
        expires max;
        root /assets/;
    }

    location /martor {
        root /media/;
    }

    location /pdf {
        root /media/;
    }

    location /submission_file {
        root /media/;
    }

    location /userdatacache {
        internal;
        root /;
    }

    location /contestdatacache {
        internal;
        root /;
    }

    location /event/ {
        proxy_pass http://wsevent:15100/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }

    location /channels/ {
        proxy_read_timeout 120;
        proxy_pass http://wsevent:15102/;
    }
}
EOT

# Xây dựng các hình ảnh Docker
docker-compose build

# Khởi động các dịch vụ cần thiết cho thiết lập ban đầu
docker-compose up -d site db redis celery

# Thực hiện di chuyển cơ sở dữ liệu ban đầu
./scripts/migrate

# Tạo các tệp tĩnh
./scripts/copy_static

# Tải dữ liệu mẫu ban đầu
./scripts/manage.py loaddata navbar
./scripts/manage.py loaddata language_small
./scripts/manage.py loaddata demo

# Tạo tài khoản superuser
./scripts/manage.py createsuperuser

# Cài đặt Judge Server
# Tải và cài đặt judge0
git clone https://github.com/judge0/judge0.git
cd judge0
./init.sh
cd ..

# Khởi động Judge Server
docker-compose up -d judge

# Cài đặt hỗ trợ chấm file .sb3
git clone https://github.com/judge0/judge0-vscode.git
cd judge0-vscode
./init.sh
cd ..

# Khởi động tất cả các dịch vụ
docker-compose up -d

echo "Hoàn tất cài đặt. Sử dụng 'docker-compose down' để dừng tất cả các dịch vụ."
