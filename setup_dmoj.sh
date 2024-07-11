#!/bin/bash

# Cập nhật hệ thống và cài đặt các gói cần thiết
sudo apt update -y
sudo apt install -y git gcc g++ make python3-dev python3-pip python3-venv libxml2-dev libxslt1-dev zlib1g-dev gettext curl redis-server pkg-config virtualenv memcached build-essential libseccomp-dev

# Cài đặt Node.js và các công cụ liên quan
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g sass postcss-cli postcss autoprefixer

# Cài đặt MariaDB và cấu hình
sudo apt install -y mariadb-server libmysqlclient-dev
sudo service mysql start
sudo mysql -e "CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
sudo mysql -e "GRANT ALL PRIVILEGES ON dmoj.* TO 'dmoj'@'localhost' IDENTIFIED BY 'thdt1234';"
mariadb-tzinfo-to-sql /usr/share/zoneinfo | sudo mariadb -u root mysql

# Tạo và kích hoạt môi trường ảo
virtualenv venv
. venv/bin/activate

# Sao chép mã nguồn từ GitHub và cài đặt các thư viện Python
git clone --recursive https://github.com/VNOI-Admin/OJ.git
cd site
pip3 install mysqlclient==2.1.1
pip3 install lxml[html_clean]
pip3 install websocket-client
pip3 install -r requirements.txt

# Cài đặt npm và tạo các thư mục
npm install
mkdir problems media static

# Sao chép cài đặt mẫu và cấu hình
cd dmoj
wget https://raw.githubusercontent.com/thuocbg/DeployJudge/main/local_settings.py
cd ..

# Tạo và chuẩn bị dữ liệu
./make_style.sh
python3 manage.py collectstatic
python3 manage.py compilemessages
python3 manage.py compilejsi18n
python3 manage.py migrate
python3 manage.py loaddata navbar
python3 manage.py loaddata language_small
python3 manage.py loaddata demo

# Thêm cài đặt cho judge và cài đặt DMOJ
cd problems
wget https://raw.githubusercontent.com/thuocbg/DeployJudge/main/judge01.yml
cd ..
python3 manage.py addjudge judge01 "abcdefghijklmnopqrstuvwxyz"
python3 -m pip install dmoj

# Kết thúc và thông báo
echo "Cài đặt và cấu hình hệ thống DMOJ hoàn tất!"
