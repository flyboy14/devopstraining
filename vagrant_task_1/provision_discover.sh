#!/bin/bash

# download discovery services

sudo yum install -y unzip wget

echo "GO AVAHI"

sudo yum install -y avahi
sudo systemctl start avahi-daemon
sudo systemctl enable avahi-daemon

echo "GO SERF"

cd /tmp
wget https://releases.hashicorp.com/serf/0.8.2/serf_0.8.2_linux_amd64.zip
unzip serf_0.8.2_linux_amd64.zip
sudo mv -f serf /usr/sbin/
rm serf_0.8.2_linux_amd64.zip

# just in case

pkill serf

# prepare handler script

cp /vagrant/handler.sh ~/
chmod +x ~/handler.sh

# add smart join function to ~/.bashrc

if [[ ! $(grep serf_join ~/.bashrc) ]]; then
	echo -e "serf_join() {\nserf leave\nserf agent -node=$(hostname) -bind=$(ip a | grep inet | grep 192 | awk '{print$2}' | awk -F'/' '{print $1}') > ~/serf.log&\nsleep 3s\nserf join 192.168.56.2\n}" >> ~/.bashrc
	source ~/.bashrc
fi

# do not join cluster on balancer vm and add a handler to it

if [[ $(hostname) == "kazak-web" ]]; then 
	serf agent -node=$(hostname) -bind=$(ip a | grep inet | grep 192 | awk '{print$2}' | awk -F'/' '{print $1}') -event-handler=~/handler.sh -log-level=debug > ~/serf.log&
else
	serf_join
fi

# serf logs are stored in ~/serf.log