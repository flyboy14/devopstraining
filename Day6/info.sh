#!/bin/bash

echo $(ip a | grep enp| grep inet | awk '{print $2}') $(hostname) > info
scp info vm2:/home/centos/
rm info
ssh vm2 'echo $(sudo ip a | grep enp| grep inet | awk "{print \$2}") $(hostname) >> info && scp -P 24 info vm3:/home/centos/info && rm info'
ssh vm3 'echo -e $(ip a | grep enp| grep inet | awk "{print \$2}") $(hostname) >> /home/centos/info && echo -e PORT 68 IS FOR: $(sudo netstat -tulpan | grep 68 | xargs | awk -F"/" "{print \$2}") >> /home/centos/info && echo -e NAMESERVERS:"" >> /home/centos/info && echo $(dig epam.com any | grep NS | grep epam | sed "s/\s\s*/ /g" | awk "{print \$5}") > /home/centos/123'  
ssh vm3 'cat /home/centos/123 | sed "s/ /\n/g" >> /home/centos/info && mv /home/centos/info /root/info && rm /home/centos/123 /home/centos/info'
