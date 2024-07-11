1. Cài đặt Site
Cài đặt yêu cầu để cài site

```
apt update
apt install git gcc g++ make python3-dev python3-pip libxml2-dev libxslt1-dev zlib1g-dev gettext curl redis-server
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install nodejs
npm install -g sass postcss-cli postcss autoprefixer
```
2. Cài đặt mariadb-server
```
apt update
apt install mariadb-server libmysqlclient-dev
```
3. Tạo CSDL dmoj
```
sudo mariadb
MariaDB [(none)]> CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
MariaDB [(none)]> GRANT ALL PRIVILEGES ON dmoj.* TO 'dmoj'@'localhost' IDENTIFIED BY 'thdt1234';
MariaDB [(none)]> exit
$ mariadb-tzinfo-to-sql /usr/share/zoneinfo | sudo mariadb -u root mysql  # Add time zone data to the database. A few pages require this.
```
4. Cài đặt môi trường cho Site
```
python3 -m venv dmojsite
. dmojsite/bin/activate
```
5. Tải Site về dmoj
```
git clone https://github.com/DMOJ/site.git
cd site
git checkout v4.0.0  # only if planning to install a judge from PyPI, otherwise skip this step
git submodule init
git submodule update
```
6. Cài đặt môi trường môi trường máy Python
```
pip3 install -r requirements.txt
pip3 install mysqlclient
```
You will now need to configure dmoj/local_settings.py. You should make a copy of this sample settings file and read through it, making changes as necessary. Most importantly, you will want to update MariaDB credentials.

Leave debug mode on for now; we'll disable it later after we've verified that the site works.

Generally, it's recommended that you add your settings in dmoj/local_settings.py rather than modifying dmoj/settings.py directly. settings.py will automatically read local_settings.py and load it, so write your configuration there.
7. Now, you should verify that everything is going according to plan.
```
python3 manage.py check
```
8. Compiling assets
The DMOJ uses sass and autoprefixer to generate the site stylesheets. The DMOJ comes with a make_style.sh script that may be run to compile and optimize the stylesheets.
```
./make_style.sh
```
Now, collect static files into STATIC_ROOT as specified in dmoj/local_settings.py
```
python3 manage.py collectstatic
```
