#!/bin/bash

ssh vm2 "sudo sed -i \"s/#Port 22/Port 23/g\" /etc/ssh/sshd_config &&\
sudo iptables -I INPUT -p tcp --dport 23 -j ACCEPT &&\
sudo setenforce 0 &&\
sudo systemctl restart sshd"
ssh vm3 "sudo yum install -y net-tools bind-utils &&\
sudo sed -i \"s/#Port 22/Port 24/g\" /etc/ssh/sshd_config &&\
sudo bash -c \"echo PermitRootLogin yes >> /etc/ssh/sshd_config\" &&\
sudo iptables -I INPUT -p tcp --dport 24 -j ACCEPT &&\
sudo setenforce 0 &&\
sudo systemctl restart sshd"

ssh -p 24 vm3 "sudo iptables -I INPUT -s vm1 -p tcp --dport 24 -j REJECT&& sudo cp -a /home/centos/.ssh /root/ && sudo chown -R root /root/.ssh"

echo -e "Host vm2\n\tHostName vm2\n\tUser centos\n\tPort 23\n" > /home/centos/.ssh/config
chmod 600 /home/centos/.ssh/config
echo -e "Host vm3\n\tHostName vm3\n\tUser root\n\tPort 24\n\tProxyCommand ssh -W %h:%p vm2\n" >> /home/centos/.ssh/config

