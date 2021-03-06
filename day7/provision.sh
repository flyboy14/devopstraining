#!/bin/bash

echo "1-8. Executing silently..."
groupadd -g 505 private
useradd -p -U -u 505 -g private -m Siarhei_Kazak
ssh-keygen -q -t rsa -f /root/.ssh/id_rsa -N '' <<< ''
mkdir -p /home/Siarhei_Kazak/.ssh
cat ~/.ssh/id_rsa.pub > /home/Siarhei_Kazak/.ssh/authorized_keys
chown -R Siarhei_Kazak:private /home/Siarhei_Kazak/.ssh

groupadd -g 600 staff 
useradd -u 600 -g staff mongo
mkdir -p /apps/mongo /apps/mongodb /logs/mongo
chown -R mongo:staff /apps/mongo /apps/mongodb /logs/mongo
chmod -R 750 /apps/mongo /apps/mongodb
chmod -R 640 /logs/mongo

yum install -y -q wget curl net-tools > /dev/null

echo "9. Downloading mongo tarball via wget..."
sudo -u mongo wget -P /tmp https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.6.5.tgz
echo -e "ok\n"
echo "10. Downloading mongo sources via curl..."
sudo -u mongo curl -o /tmp/mongodb-src-r3.6.5.tar.gz https://fastdl.mongodb.org/src/mongodb-src-r3.6.5.tar.gz
echo -e "ok\n"

echo "11-20. Executing silently..."
sudo -u mongo tar -xzf /tmp/mongodb-linux-x86_64-3.6.5.tgz -C /tmp/
sudo -u mongo tar -xzf /tmp/mongodb-src-r3.6.5.tar.gz -C /tmp/

sudo -u mongo cp -a /tmp/mongodb-linux-x86_64-3.6.5/* /apps/mongo/

su - mongo -c 'export PATH=/apps/mongo/bin:$PATH'
su - mongo -c 'echo -e "PATH=/apps/mongo/bin:\$PATH\nexport PATH" >> ~/.bash_profile'
su - mongo -c 'echo PATH=/apps/mongo/bin:\$PATH >> ~/.bashrc'

echo '@mongo soft nproc 32000' >> /etc/security/limits.conf
echo '@mongo hard nproc 32000' >> /etc/security/limits.conf

echo 'Siarhei_Kazak ALL=(mongo) NOPASSWD: /apps/mongo/bin/mongod' >> /etc/sudoers

if [[ ! $(getenforce) == "Permissive" ]];then 
	sed -i 's@enforcing@disabled@' /etc/selinux/config
fi

chown -R mongo:staff /logs 
chmod -R 740 /logs

sudo -u Siarhei_Kazak sudo -H -u mongo /apps/mongo/bin/mongod --dbpath /apps/mongodb > /logs/mongo/mongod_manual.log&
echo "21. Manually starting mongod..." && sleep 5s
echo -e "- PID is $(pgrep mongod)"
echo -e "- tail of logfile is:"
echo -e "----------------------------------\t"
echo "$(tail /logs/mongo/mongod_manual.log)"
echo -e "----------------------------------\t"
echo -e "- netstat -tulpan shows: $(netstat -tulpan | grep 27017 | xargs)"
pkill mongod
echo "22. Mongod killed"

echo "23-24. Executing silently..."

cp -f /tmp/mongodb-src-r3.6.5/rpm/mongod.conf /apps/mongo/

sed -i "s_/var/log/mongodb_/logs/mongo_g" /apps/mongo/mongod.conf 
sed -i "s_/var/lib/mongo_/apps/mongodb_g" /apps/mongo/mongod.conf

echo -e "[Unit]
After=network.target\n
[Service]
User=mongo
Group=staff
Environment=\"OPTIONS=-f /apps/mongo/mongod.conf\"
ExecStart=/apps/mongo/bin/mongod \$OPTIONS
ExecStartPre=/usr/bin/mkdir -p /var/run/mongodb
ExecStartPre=/usr/bin/chown mongo:staff /var/run/mongodb
PermissionsStartOnly=true
PIDFile=/var/run/mongodb/mongod.pid
Type=simple\n
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/mongod.service

sed -i "s_fork: true_fork: false_g" /apps/mongo/mongod.conf

#systemctl daemon-reload
systemctl start mongod
systemctl -q enable mongod

echo "Done!"
