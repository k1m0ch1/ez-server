#!/bin/bash

echo "== run this bash script as root"

apt-get update

apt-get install git build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev automake pkgconf htop curl unzip

cd /tmp

mkdir nginx

wget https://nginx.org/download/nginx-1.13.8.tar.gz -P nginx/

cd /tmp/nginx

tar -zxvf nginx-1.13.8.tar.gz && rm -f nginx-1.13.8.tar.gz

groupadd -r nginx
useradd -r -g nginx -s /sbin/nologin -M nginx

cd /tmp/nginx/nginx-1.13.8

./configure --user=nginx --group=nginx --sbin-path=/usr/sbin --modules-path=/usr/lib/nginx --with-http_ssl_module --with-http_gzip_static_module --with-file-aio --with-http_v2_module --with-http_realip_module --without-http_autoindex_module --without-http_browser_module --without-http_geo_module --without-http_userid_module --without-http_memcached_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_split_clients_module --without-http_uwsgi_module --without-http_scgi_module --without-http_upstream_ip_hash_module --with-http_sub_module --with-http_gunzip_module --with-http_secure_link_module --with-threads --with-stream --with-stream_ssl_module --prefix=/etc/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --with-cc-opt="-fPIC -I /usr/include/apr-1"

make -j4 install

cd /var/log/nginx

touch access.log
touch error.log

cd /etc/nginx/html/

mkdir /etc/nginx/conf.d

cp /root/ez-server/conf/nginx/nginx.conf /etc/nginx/nginx.conf
cp /root/ez-server/conf/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

mv /etc/nginx/html/index.html /etc/nginx/html/backupindex

cp /root/ez-server/conf/nginx/html/index.html /etc/nginx/html/index.html

echo "<?php phpinfo(); ?>" > info.php

apt-get install -y python-software-properties; add-apt-repository -y ppa:ondrej/php; apt-get update -y; apt-cache pkgnames | grep php7.1

apt-get install -y php7.1 php7.1-fpm php7.1-cli php7.1-common php7.1-mbstring php7.1-gd php7.1-intl php7.1-xml php7.1-xmlrpc php7.1-mysql php7.1-mcrypt php7.1-zip php7.1-curl

cd /etc/php/7.1/fpm/pool.d/

rm www.conf
cp /root/ez-server/conf/php/7.1/fpm/pool.d/default.conf /etc/php/7.1/fpm/pool.d/default.conf

cd /tmp/

curl -sS https://getcomposer.org/installer -o composer-setup.php

php composer-setup.php --install-dir=/usr/local/bin --filename=composer

nginx
nginx -s reload
/etc/init.d/php7.1-fpm restart

apt-get install mysql-server
mysql_secure_installation
systemctl status mysql.service

cd /etc/nginx/html

wget https://files.phpmyadmin.net/phpMyAdmin/4.7.7/phpMyAdmin-4.7.7-all-languages.zip

unzip phpMyAdmin-4.7.7-all-languages.zip

mv phpMyAdmin-4.7.7-all-languages pm4-pUb