#!/bin/bash

sudo yum install -y -q vim net-tools telnet
MACHINEIP=$(hostname -I | sed "s/ /\n/g" | grep 192.168.56)

### Configure apache

# Cleanup apache main config

sudo sed -i "/LoadModule/d" /etc/httpd/conf/httpd.conf
sudo sed -i "/VirtualHost/d" /etc/httpd/conf/httpd.conf
sudo sed -i "/ErrorDocument/d" /etc/httpd/conf/httpd.conf
sudo sed -i "/Redirect \"\/\"/d" /etc/httpd/conf/httpd.conf

# Include proper modules

if [[ ! $(sudo grep conf.modules.d /etc/httpd/conf/httpd.conf) ]]; then
	sudo bash -c 'echo -e "\nInclude conf.modules.d/*.conf" >> /etc/httpd/conf/httpd.conf'
fi

# Edit vhost.conf

sudo sed -i "s/mntlab/\*/g" /etc/httpd/conf.d/vhost.conf
sudo sed -i "s/UnMount/Mount/g" /etc/httpd/conf.d/vhost.conf

# Edit worker.properties

sudo sed -i "s/worker-jk@ppname/tomcat\.worker/g" /etc/httpd/conf.d/workers.properties
sudo sed -i "s/192.168.56.100/$MACHINEIP/g" /etc/httpd/conf.d/workers.properties

### Configure tomcat

# Loglevel 6 on tomcat startup, seriously?

sudo sed -i "/init 6/d" /etc/rc.d/init.d/tomcat

# Get logging back on tomcat

sudo sed -i "s@ > /dev/null@@g" /etc/rc.d/init.d/tomcat

# Fix server ip in server.xml

sudo sed -i "s/address=\"192.168.56.10\"/address=\"$MACHINEIP\"/g" /opt/apache/tomcat//current/conf/server.xml

# Choose a proper version of java

sudo alternatives --config java <<< '1'

# Edit lacking permissions for tomcat

sudo chmod +x /opt/apache/tomcat/current/bin/catalina.sh
sudo chown -R tomcat:tomcat /opt/apache/tomcat/current/logs

# Dealing with JAVA_HOME and CATALINA_HOME environment variables

sudo sed -i 's@JAVA_HOME=/tmp@JAVA_HOME=/opt/oracle/java/x64//jdk1.7.0_80@' /etc/environment
sudo -u tomcat sed -i 's@JAVA_HOME=/tmp@JAVA_HOME=/opt/oracle/java/x64//jdk1.7.0_80@' /home/tomcat/.bashrc
sudo sed -i "s@CATALINA_HOME=/tmp@CATALINA_HOME=/opt/apache/tomcat/current@" /etc/environment
sudo -u tomcat sed -i "s@CATALINA_HOME=/tmp@CATALINA_HOME=/opt/apache/tomcat/current@" /home/tomcat/.bashrc

### Flush crontab

sudo crontab -r

### Force unsetting immersive attribute

sudo chattr -i /etc/sysconfig/iptables

### Flush and rewrite iptables in a proper way

sudo iptables -F
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 8009 -j ACCEPT
sudo bash -c "iptables-save > /etc/sysconfig/iptables"

### Turn off and disable service, spawning nc

sudo systemctl stop bindserver
sudo systemctl disable bindserver

### Just in case

sudo pkill tomcat
sudo pkill httpd

### Restart servers

sudo systemctl daemon-reload
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start tomcat
sudo systemctl enable tomcat