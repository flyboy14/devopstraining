#!/bin/bash

echo $(ip a | grep enp| grep inet | awk '{print $2}') $(hostname) > info
scp info vm2:/home/centos/
ssh vm2 bash -c 'echo $(ip a | grep enp| grep inet | awk "{print \$2}") $(hostname) >> /home/centos/info && scp -P 24 /home/centos/info vm3:/home/centos/'
ssh vm3 'echo $(ip a | grep enp| grep inet | awk "{print \$2}") $(hostname) >> /home/centos/info && mv /home/centos/info /root/info'
