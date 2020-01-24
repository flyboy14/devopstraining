#!/bin/bash

#sudo useradd -o -u 0 -g 0 -N -M super_user

sudo useradd -g wheel super_user

sudo cat /etc/sudoers > sudoers.save
sudo bash -c "cat sudoers.save | grep NOPASS | sed \"s/# %wheel/%wheel/\" >> /etc/sudoers"

for i in {1..20}
do
	sudo -u super_user sudo groupadd -g "$(( 7000+10*$i+$i+$i/10 ))" user$i
	sudo -u super_user sudo useradd -p -U -u "$(( 9000+10*$i+$i+$i/10 ))" -g "$(( 7000+10*$i+$i+$i/10 ))" -s /bin/sh -m user$i -c "Sample user with password and homedir"

	sudo usermod -aG user$i user$i
	sudo passwd user$i
done

sudo groupadd even
sudo groupadd odd


for i in {1..20}
do
	if [[ "$(( $i%2 ))" == 1 ]];then
		sudo -u super_user sudo usermod -aG odd user$i
		let "i++"
	else
        	sudo -u super_user sudo usermod -aG even user$i

	fi
done

echo "" > /tmp/user.info
for i in {1..20}
do
	echo "$(cat /etc/passwd | grep user$i | head -n 1 | awk -F ":" "{print \$1,\$6 }") $(last | grep super_ | sed "s/  */@/g" |awk -F "@" '{print $6}')" >> /tmp/user.info
done 


sudo bash -c "echo -e \"#!/bin/bash\n\nwhoami\" > /home/user1/whoami.sh"
sudo chmod +x /home/user1/whoami.sh

sudo usermod -aG wheel user2
sudo -u user2 sudo cp /home/user1/whoami.sh /home/user3/whoami.sh

sudo setfacl -R -m user:user2:rx ~user3

sudo -u user2 bash /home/user3/whoami.sh 

sudo setenforce Permissive
echo "Selinux is now $(getenforce)!" 