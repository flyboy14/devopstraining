#!/bin/bash

sudo yum install -y vim net-tools bind-utils epel-release unzip tomcat tomcat-webapps tomcat-admin-webapps
sudo rpm -i /vagrant/jdk-8u241-linux-x64.rpm
unzip /vagrant/project.zip -d ~/

