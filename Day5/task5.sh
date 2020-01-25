#!/bin/bash

#sudo useradd -o -u 0 -g 0 -N -M super_user

sudo useradd -g wheel super_user

sudo cat /etc/sudoers > sudoers.save
sudo bash -c "cat sudoers.save | grep NOPASS | sed \"s/# %wheel/%wheel/\" >> /etc/sudoers"
echo "Added super_user user"

for i in {1..20}
do
	sudo -u super_user sudo groupadd -g "$(( 7000+10*$i+$i+$i/10 ))" user$i
	sudo -u super_user sudo useradd -p -U -u "$(( 9000+10*$i+$i+$i/10 ))" -g user$i -s /bin/sh -m user$i -c "Sample user with password and homedir"

	echo 2222 | sudo passwd --stdin "user$i" > /dev/null
done
echo "Created 20 users and changed their passwords to 2222"

sudo groupadd even
sudo groupadd odd
echo "Added groups even and odd"

for i in {1..20}
do
	if [[ "$(( $i%2 ))" == 1 ]];then
		sudo -u super_user sudo usermod -aG odd user$i
		let "i++"
	else
        	sudo -u super_user sudo usermod -aG even user$i

	fi
done
echo "Added needed users to odd and even groups"

echo "" > /tmp/user.info
for i in {1..20}
do
	echo "$(cat /etc/passwd | grep user$i | head -n1 | awk -F ":" "{print \$1,\$6 }") $(last | grep "user$i " |head -n1| xargs |awk '{print $4,$5,$6,$7,$8,$9,$10}')" >> /tmp/user.info
done 
echo "Copied 20 user's info to /tmp/user.info"

sudo bash -c "echo -e \"#!/bin/bash\n\nwhoami\" > /home/user1/whoami.sh"
sudo chmod +x /home/user1/whoami.sh
echo "Created /home/user1/whoami.sh"

# Grant permissions to sudo
sudo usermod -aG wheel user2

sudo -u user2 sudo cp /home/user1/whoami.sh /home/user3/
echo "Copied /home/user1/whoami.sh to /home/user3/"

# Grant permissions to user3 home folder
sudo setfacl -R -m user:user2:rx ~user3

echo "executing /home/user3 as user2:"
sudo -u user2 bash /home/user3/whoami.sh 

sudo setenforce Permissive
echo "Selinux is now $(getenforce)!" 
