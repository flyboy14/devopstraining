#!/bin/bash

# Script handles leave/join events and rewrites apache lb configuration due to new serf status
# Created by Siarhei Kazak

VAR=${SERF_EVENT}

join_echo () {

 	echo "Someone joined!"

}

leave_echo () {
	
	echo "Someone left!"

}

handler () {

	cp /vagrant/httpd-vhosts.conf ./vhosts.conf
	echo '' > workers.properties

	WORKERLIST="tomcat-cluster"
	NODESLIST=""
	declare -i NUM
	NUM=1
	MEMBERIPS=$(serf members | grep alive | grep tomcat | awk '{print $2}' | awk -F":" '{print $1}' | sort | xargs)
	MEMBERHNS=$(serf members | grep alive | grep tomcat | awk '{print $1}' | sort | xargs)

# rewrite apache configuration

	echo -e "worker.list=liststringforSED\n" >> workers.properties

 	for i in $MEMBERIPS; do
 		HN=$(echo $MEMBERHNS | awk "{print \$$NUM}" | awk -F'-' '{print $2}')

# workaround for extra "," if there's only one tomcat instance in cluster

	    if [[ $NUM == 1 ]];then			
			NODESLIST="$HN"
	    else
 	    	NODESLIST="$NODESLIST,$HN"
	    fi

# rewrite workers.properties

	    echo "worker.$HN.type=ajp13" >> workers.properties
 	    echo "worker.$HN.host=$HN.lab" >> workers.properties
 	    echo "worker.$HN.port=8009" >> workers.properties
 	    echo -e "worker.$HN.lbfactor=1\n" >> workers.properties

# rewrite httpd-vhosts.conf

	    echo '<VirtualHost *:80>' >> vhosts.conf
	    echo "  ServerName" $(echo $MEMBERIPS | awk "{print \$$NUM}") >> vhosts.conf
		echo "  ServerAlias $HN.lab" >> vhosts.conf
		echo "  JkMount / $HN" >> vhosts.conf
		echo "  JkMount /* $HN" >> vhosts.conf
		echo -e '</VirtualHost>\n' >> vhosts.conf

# rewrite /etc/hosts

		MACHINEIP=$(echo $MEMBERIPS | awk "{print \$$NUM}")
		if [[ ! $(sudo grep $MACHINEIP /etc/hosts) ]]; then
			sudo bash -c "echo \"$MACHINEIP $HN.lab\" >> /etc/hosts"
		fi

	    NUM=$(($NUM+1))
	done

# add workers.properties cluster section

	WORKERLIST="$NODESLIST,$WORKERLIST"
	sed -i "s/liststringforSED/$WORKERLIST/g" workers.properties
	echo "worker.tomcat-cluster.sticky_session=false" >> workers.properties
	echo "worker.tomcat-cluster.type=lb" >> workers.properties
	echo "worker.tomcat-cluster.balanced_workers=$NODESLIST" >> workers.properties

	sudo cp workers.properties /etc/httpd/conf/

# add httpd-vhosts.conf cluster VirtualHost section

	echo "<VirtualHost *:80>" >> vhosts.conf
	echo "  ServerName $(hostname -I |sed 's/ /\n/g' | grep 192.168.56)" >> vhosts.conf
	echo "  ServerAlias cluster.lab" >> vhosts.conf
	echo "  JkMount / tomcat-cluster" >> vhosts.conf
	echo "  JkMount /* tomcat-cluster" >> vhosts.conf
	echo "</VirtualHost>" >> vhosts.conf

	sudo mv vhosts.conf /etc/httpd/conf.d/httpd-vhosts.conf

# reload apache configuration

    if [[ ! $(pgrep httpd) ]]; then
    	sudo systemctl start httpd
    fi
	sudo systemctl reload httpd && echo "Refreshed balancer nodes."

}

echo "New event: $VAR."

case $VAR in 

	member-join)
	 join_echo
	 handler
	 ;;
	member-leave)
	 leave_echo
	 handler
	 ;;
	*)
	 exit 0
	 ;;
esac



