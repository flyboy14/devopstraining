#!/bin/bash

# Install section

sudo yum install -y -q gcc gcc-c++ git wget vim make zlib-devel libtool autoconf httpd-tools

cd /tmp
git clone https://github.com/vozlt/nginx-module-vts 

wget https://sourceforge.net/projects/pcre/files/pcre/8.43/pcre-8.43.tar.gz
tar xzf pcre-8.43.tar.gz

wget http://artfiles.org/openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz
tar xzf openssl-1.0.2u.tar.gz

wget -q http://nginx.org/download/nginx-1.15.0.tar.gz
tar xzf nginx-1.15.0.tar.gz

cd nginx-1.15.0
./configure --user=vagrant --group=vagrant --prefix=/home/vagrant/nginx --sbin-path=/home/vagrant/nginx/sbin/nginx --conf-path=/home/vagrant/nginx/nginx.conf --error-log-path=/home/vagrant/nginx/logs/error.log --http-log-path=/home/vagrant/nginx/logs/access.log --pid-path=/home/vagrant/nginx/logs/nginx.pid --with-http_ssl_module --with-http_realip_module --without-http_gzip_module --with-pcre=/tmp/pcre-8.43 --with-openssl=/tmp/openssl-1.0.2u --add-module=/tmp/nginx-module-vts
make
make install

rm /tmp/*tar.gz

sudo cp /vagrant/nginx.service /etc/systemd/system/

# Configure section

mkdir -p ~/nginx/conf && cd $_
htpasswd -bc .htpasswd admin nginx

tar -xvzf /vagrant/html.tar.gz -C ~/nginx/
cp /vagrant/{nginx.conf,backend.conf} ~/nginx/ 

# Start nginx service

sudo systemctl start nginx