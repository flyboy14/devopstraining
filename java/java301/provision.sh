#!/bin/bash

# Install needed packages

yum install -y vim net-tools bind-utils epel-release unzip 
sudo rpm -i /vagrant/jdk-8u241-linux-x64.rpm
groupadd tomcat
mkdir /opt/tomcat
useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
cd /opt
wget http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.51/bin/apache-tomcat-8.5.51.tar.gz
sudo tar -zxvf apache-tomcat-8.5.51.tar.gz -C /opt/tomcat --strip-components=1

cd /opt/tomcat
chgrp -R tomcat conf
chmod g+rwx conf
chmod g+r conf/*
chown -R tomcat logs/ temp/ webapps/ work/

chgrp -R tomcat bin
chgrp -R tomcat lib
chmod g+rwx bin
chmod g+r bin/*

cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/java/jdk1.8.0_241-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms256m -Xmx512m'
Environment='JAVA_OPTS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.rmi.port=12346 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=192.168.56.29 -Djava.awt.headless=true'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
EOF

# Provide config for manager-gui access 

cat << EOF > /opt/tomcat/conf/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>

<tomcat-users>

  <role rolename="tomcat"/>
  <user username="tomcat" password="tomcat" roles="tomcat"/>
  <role rolename="manager-gui"/>
  <user username="deploy" password="deploy" roles="manager-gui"/>

</tomcat-users>
EOF

# Deploy TestApp.war

cp /vagrant/TestApp.war /opt/tomcat/webapps/

systemctl daemon-reload
systemctl restart tomcat

sleep 4s

# Provide web.xml with custom 505 error and multipart-config

if [[ ! $(grep multipart /opt/tomcat/conf/context.xml) ]]; then
	sed -i 's/<Context>/<Context allowCasualMultipartParsing="true">/g' /opt/tomcat/conf/context.xml	
fi

# Restart tomcat service

systemctl restart tomcat
