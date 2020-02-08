#!/bin/bash

SAMPLEIP="192.168.56."

sudo yum -y install epel-release httpd httpd-devel autoconf libtool sed wget net-tools vim

# Build jk.so module

cd /opt 
sudo wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz 
sudo tar xvzf tomcat-connectors-1.2.46-src.tar.gz

cd tomcat-connectors-1.2.46-src/native 
sudo ./configure --with-apxs="$(which apxs)"
sudo make
sudo cp apache-2.0/mod_jk.so /etc/httpd/modules/
sudo bash -c 'echo "LoadModule jk_module modules/mod_jk.so" >> /etc/httpd/conf/httpd.conf'


# Fill in worker.properties and vhosts config file for httpd 

cd /vagrant
cp httpd-vhosts.conf vhosts.conf

echo '' > workers.properties
WORKERLIST="tomcat-cluster"
NODESLIST=""
declare -i NUM
NUM=$1


echo -e "worker.list=liststringforSED\n" >> workers.properties
while [[ $NUM -gt 0 ]];
do

# workaround for extra "," if there's only one tomcat instance in cluster

	if [[ $NUM == $1 ]];then			
		NODESLIST="tomcat$NUM"
	else
 	  	NODESLIST="tomcat$NUM,$NODESLIST"
	fi

# rewrite workers.properties

    echo "worker.tomcat$NUM.type=ajp13" >> workers.properties
    echo "worker.tomcat$NUM.host=tomcat$NUM.lab" >> workers.properties
    echo "worker.tomcat$NUM.port=8009" >> workers.properties
    echo -e "worker.tomcat$NUM.lbfactor=1\n" >> workers.properties

# rewrite httpd-vhosts.conf

    echo '<VirtualHost *:80>' >> vhosts.conf
    echo "  ServerName $SAMPLEIP$((2+$NUM))" >> vhosts.conf
	echo "  ServerAlias tomcat$NUM.lab" >> vhosts.conf
	echo "  JkMount / tomcat$NUM" >> vhosts.conf
	echo "  JkMount /* tomcat$NUM" >> vhosts.conf
	echo -e '</VirtualHost>\n' >> vhosts.conf

# rewrite /etc/hosts

	MACHINEIP="$SAMPLEIP$((2+$NUM))"
	if [[ ! $(sudo grep $MACHINEIP /etc/hosts) ]]; then
		sudo bash -c "echo \"$MACHINEIP tomcat$NUM.lab\" >> /etc/hosts"
	fi

    NUM=$(($NUM-1))
done

# add workers.properties cluster section

WORKERLIST="$NODESLIST,$WORKERLIST"
sed -i "s/liststringforSED/$WORKERLIST/g" workers.properties
echo "worker.tomcat-cluster.sticky_session=false" >> workers.properties
echo "worker.tomcat-cluster.type=lb" >> workers.properties
echo "worker.tomcat-cluster.balanced_workers=$NODESLIST" >> workers.properties

sudo mv workers.properties /etc/httpd/conf/

# add httpd-vhosts.conf cluster VirtualHost section

echo "<VirtualHost *:80>" >> vhosts.conf
echo "  ServerName $(hostname -I |sed 's/ /\n/g' | grep 192.168.56)" >> vhosts.conf
echo "  ServerAlias cluster.lab" >> vhosts.conf
echo "  JkMount / tomcat-cluster" >> vhosts.conf
echo "  JkMount /* tomcat-cluster" >> vhosts.conf
echo -e "</VirtualHost>\n" >> vhosts.conf

sudo mv -f vhosts.conf /etc/httpd/conf.d/httpd-vhosts.conf

sudo systemctl restart httpd
