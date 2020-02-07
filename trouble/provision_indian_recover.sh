#!/bin/bash

MACHINEIP=$(hostname -I | sed "s/ /\n/g" | grep 192.168.56)

sudo yum install -y -q vim net-tools telnet
sudo sed -i "/LoadModule/d" /etc/httpd/conf/httpd.conf
sudo sed -i "/VirtualHost/d" /etc/httpd/conf/httpd.conf
sudo sed -i "/ErrorDocument/d" /etc/httpd/conf/httpd.conf
sudo sed -i "/Redirect \"\/\"/d" /etc/httpd/conf/httpd.conf

sudo crontab -r
sudo iptables -F
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -m state --state NEW -p tcp --dport 8009 -j ACCEPT

sudo iptables-save
sudo sed -i "/init 6/d" /etc/rc.d/init.d/tomcat
sudo sed -i "s/address=\"192.168.56.10\"/address=\"$MACHINEIP\"/g" /opt/apache/tomcat//current/conf/server.xml
sudo sed -i "s/mntlab/\*/g" /etc/httpd/conf.d/vhost.conf
sudo sed -i "s/worker-jk@ppname/tomcat\.worker/g" /etc/httpd/conf.d/workers.properties
sudo sed -i "s/192.168.56.100/$MACHINEIP/g" /etc/httpd/conf.d/workers.properties
sudo sed -i "s/UnMount/Mount/g" /etc/httpd/conf.d/vhost.conf
sudo alternatives --config java <<< '1'
sudo chmod +x /opt/apache/tomcat/current/bin/catalina.sh
sudo chown -R tomcat:tomcat /opt/apache/tomcat/current/logs

sudo sed -i 's@JAVA_HOME=/tmp@JAVA_HOME=/opt/oracle/java/x64//jdk1.7.0_80@' /etc/environment
sudo -u tomcat sed -i 's@JAVA_HOME=/tmp@JAVA_HOME=/opt/oracle/java/x64//jdk1.7.0_80@' /home/tomcat/.bashrc
sudo sed -i "s@CATALINA_HOME=/tmp@CATALINA_HOME=/opt/apache/tomcat/current@" /etc/environment
sudo -u tomcat sed -i "s@CATALINA_HOME=/tmp@CATALINA_HOME=/opt/apache/tomcat/current@" /home/tomcat/.bashrc

if [[ ! $(sudo grep conf.modules.d /etc/httpd/conf/httpd.conf) ]]; then
	sudo bash -c 'echo -e "\nInclude conf.modules.d/*.conf" >> /etc/httpd/conf/httpd.conf'
fi

sudo systemctl daemon-reload
sudo systemctl stop bindserver
sudo systemctl disable bindserver
sudo systemctl start httpd
sudo systemctl start tomcat
