#!/bin/bash

echo "gathering information on vm1"
echo $(ip a | grep enp | grep inet | awk '{print $2}') is an address for $(hostname) > info
scp -q info vm2:/home/centos/ 
rm info

echo "gathering information on vm2"
ssh vm2 'echo $(sudo ip a | grep enp| grep inet | awk "{print \$2}") is an address for $(hostname) >> info &&\
scp -P 24 info vm3:/home/centos/info &&\
rm info

echo "gathering information on vm3"
ssh vm3 'echo -e $(ip a | grep enp| grep inet | awk "{print \$2}") \
is an address for $(hostname) >> /home/centos/info &&\
echo -e PORT 68 IS FOR: \
$(sudo netstat -tulpan | grep 68 | xargs | awk -F"/" "{print \$2}") >> /home/centos/info &&\
echo -e NAMESERVERS:"" >> /home/centos/info &&\
echo $(dig epam.com any | grep NS | grep epam | sed "s/\s\s*/ /g" | awk "{print \$5}" >> /home/centos/info &&\
mv /home/centos/info /root/)' 2>/dev/null 
echo "copied gathered information to vm3:/root/info"

echo "creating a file on vm1"
echo "THIS IS A FILE" > file

echo "copying file to vm3:/root/file"
scp -q file vm3:/root/ 2>/dev/null
rm file

echo "done!"
