1. Cài đặt các điều kiện tiên quyết
1.1. Cập nhật danh sách gói:
```
apt update
```
1.2. Cài đặt các gói cần thiết:
```
apt install git gcc g++ make python3-dev python3-pip libxml2-dev libxslt1-dev zlib1g-dev gettext curl redis-server
```
1.3. Cài đặt Node.js:
```
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E  -
apt install nodejs
```
1.4. Cài đặt các công cụ CSS:
```
npm install -g sass postcss-cli postcss autoprefixer
```
2. Tạo cơ sở dữ liệu
2.1. Cập nhật và cài đặt MariaDB:
```
apt update
apt install mariadb-server libmysqlclient-dev
```
2.2. Thiết lập cơ sở dữ liệu:
```
sudo mariadb
MariaDB [(none)]> CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
MariaDB [(none)]> GRANT ALL PRIVILEGES ON dmoj.* TO 'dmoj'@'localhost' IDENTIFIED BY 'thdt1234';
MariaDB [(none)]> exit
mariadb-tzinfo-to-sql /usr/share/zoneinfo | sudo mariadb -u root mysql
```
3. Cài đặt trang web
3.1. Tạo và kích hoạt môi trường ảo:
```
python3 -m venv dmojsite
. dmojsite/bin/activate
```
3.2. Tải mã nguồn trang web:
```
 git clone https://github.com/DMOJ/site.git
 cd site
 git submodule init
 git submodule update
```
3.2. Cài đặt các phụ thuộc Python:
```
pip3 install -r requirements.txt
pip3 install mysqlclient
```
4. Cấu hình dmoj/local_settings.py với thông tin cơ sở dữ liệu MariaDB.
4.1. Kiểm tra cấu hình:

```
python3 manage.py check
```
4.2. Biên dịch tài nguyên
Biên dịch các tệp CSS:
```
./make_style.sh
```
4.3. Thu thập các tệp tĩnh:
```
python3 manage.py collectstatic
```
4.4. Tạo các tệp quốc tế hóa:
```
python3 manage.py compilemessages
python3 manage.py compilejsi18n
```
4.5. Thiết lập bảng cơ sở dữ liệu
Tạo schema cho cơ sở dữ liệu:
```
python3 manage.py migrate
```
4.6. Tải dữ liệu ban đầu:
```
python3 manage.py loaddata navbar
python3 manage.py loaddata language_small
python3 manage.py loaddata demo
```
4.7. Tạo tài khoản quản trị viên:
```
python3 manage.py createsuperuser
```
4.8. Thiết lập Celery
Khởi động Redis server:
```
$ service redis-server start
```
Cấu hình local_settings.py để sử dụng Redis với Celery.
Chạy thử Celery:
```
celery -A dmoj_celery worker
```
Chạy máy chủ
Chạy thử máy chủ:
```
python3 manage.py runserver 0.0.0.0:8000
```
Chạy thử Celery:
```
celery -A dmoj_celery worker
```
Thiết lập uWSGI
Cài đặt uWSGI:
```
pip3 install uwsgi
```
Chạy thử uWSGI:
```
uwsgi --ini uwsgi.ini
```
Thiết lập supervisord
Cài đặt và cấu hình supervisord:
```
apt install supervisor
supervisorctl update
supervisorctl status
```
Thiết lập nginx
Cài đặt nginx:
```
apt install nginx
```
Cấu hình nginx và kiểm tra cấu hình:
```
nginx -t
service nginx reload
```
Cấu hình máy chủ sự kiện
Tạo config.js: (dmojsite) $ cat > websocket/config.js
```
cat > websocket/config.js
module.exports = {
    get_host: '127.0.0.1',
    get_port: 15100,
    post_host: '127.0.0.1',
    post_port: 15101,
    http_host: '127.0.0.1',
    http_port: 15102,
    long_poll_timeout: 29000,
};
```
Cài đặt các phụ thuộc (dmojsite) $: 
```
npm install qu ws simplesets
pip3 install websocket-client
```
Cập nhật và khởi động lại supervisor và nginx:
```
supervisorctl update
supervisorctl restart bridged
supervisorctl restart site
service nginx restart
```
Hy vọng hướng dẫn này sẽ giúp bạn cài đặt và thiết lập trang web của mình một cách dễ dàng. Nếu bạn có bất kỳ câu hỏi nào, hãy cho tôi biết!
