#!/bin/bash

# Install needed packages

yum install -y vim net-tools bind-utils epel-release unzip java-1.8.0-openjdk-devel tomcat tomcat-webapps tomcat-admin-webapps 

# Provide debug options

if [[ ! $(grep CATALINA_OPTS /etc/tomcat/tomcat.conf) ]]; then
	echo CATALINA_OPTS=\"-Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n\" >> /etc/tomcat/tomcat.conf
fi

# Provide config for manager-gui access 

cat << EOF > /etc/tomcat/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>

<tomcat-users>

  <role rolename="tomcat"/>
  <user username="tomcat" password="tomcat" roles="tomcat"/>
  <role rolename="manager-gui"/>
  <user username="deploy" password="deploy" roles="manager-gui"/>

</tomcat-users>
EOF

# Deploy TestApp.war

cp /vagrant/TestApp.war /usr/share/tomcat/webapps/

systemctl restart tomcat

sleep 4s

# Provide needed libs

cp /vagrant/lib/* /usr/share/tomcat/webapps/TestApp/WEB-INF/lib/

# Provide web.xml with custom 505 error and multipart-config

if [[ ! $(grep multipart /usr/share/tomcat/webapps/TestApp/WEB-INF/web.xml) ]]; then
	sed -i '/<servlet-name>GenericServlet<\/servlet-name>/a<multipart-config><\/multipart-config>' /usr/share/tomcat/webapps/TestApp/WEB-INF/web.xml
	sed -i '/<\/web-app>/i<error-page><error-code>500<\/error-code><location>\/error505.html<\/location><\/error-page>' /usr/share/tomcat/webapps/TestApp/WEB-INF/web.xml
fi

echo '<h1>Siarhei Kazak custom 505 error message</h1>' > /usr/share/tomcat/webapps/TestApp/error500.html

# Restart tomcat service

systemctl restart tomcat
