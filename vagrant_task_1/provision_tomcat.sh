#!/bin/bash

# Get instance number from hostname

NUM=$(hostname | sed "s/kazak-tomcat//g")

echo "Hello Im tomcat$NUM"

sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps epel-release

# Add jvmRoute string, deploy users and clusterjsp for a single tomcat server instance

cd /vagrant
cp /vagrant/tomcat_server.xml server.xml
sed -i "s/routestringforSED/tomcat$NUM/g" server.xml
sudo mv -f server.xml /usr/share/tomcat/conf/
sudo cp -f tomcat-users.xml /usr/share/tomcat/conf/tomcat-users.xml
sudo cp clusterjsp.war /usr/share/tomcat/webapps/

sudo systemctl restart tomcat
