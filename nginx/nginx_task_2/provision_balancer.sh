#!/bin/bash

# Install section

sudo yum install -y -q gcc gcc-c++ git wget vim make zlib-devel libtool autoconf httpd-tools epel-release iptables

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

sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination :8080
sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 443 -j DNAT --to-destination :8443
sudo iptables -F

mkdir -p ~/nginx/keys
chmod +x /vagrant/sslgen.sh
/vagrant/sslgen.sh
cp bal* ~/nginx/keys/

cp -f /vagrant/nginx_balancer.conf ~/nginx/nginx.conf 
mkdir -p ~/nginx/conf/{upstreams,vhosts}
cp -f /vagrant/lb.conf ~/nginx/conf/vhosts/
cp -f /vagrant/web.conf ~/nginx/conf/upstreams/

# Start nginx service

sudo systemctl start nginx