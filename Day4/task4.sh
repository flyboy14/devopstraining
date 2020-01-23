#!/bin/bash

DIR=$PWD
# Installing openjdk
sudo yum -y install java wget

# Installing oracle
cd /opt/
sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/13.0.2+8/d4173c853231432d94f001e99d882ca7/jdk-13.0.2_linux-x64_bin.tar.gz"
sudo tar xzf jdk-13.0.2_linux-x64_bin.tar.gz
cd jdk-13.0.2

# Setting alternatives
sudo alternatives --install /usr/bin/java java /opt/jdk-13.0.2/bin/java 2
sudo alternatives --config java <<< 1

# Installing htop
sudo yum install htop

# Installing docker-ce v 18.06.1
sudo yum -y install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce-18.06.1.ce-3.el7

# Enable and start docker.service

sudo systemctl enable docker
sudo systemctl start docker

# Add a cronjob

cd $DIR
touch mycron
crontab -l > mycron
echo "5,30 12-15 * * 1 rm /tmp/*.zip" >> mycron
crontab mycron
rm mycron

# Install mongodb

cd /tmp
sudo wget "https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.2/x86_64/RPMS/mongodb-org-server-4.2.2-1.el7.x86_64.rpm"
sudo rpm -i mongodb-org-server-4.2.2-1.el7.x86_64.rpm

cd $DIR
sudo cp $DIR/mongod.service /etc/systemd/user/

# Start mongodb service

sudo systemctl start mongod
