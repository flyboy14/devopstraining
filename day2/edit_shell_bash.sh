#!/bin/bash

sudo cp -f /etc/passwd /root/passwd_bash.copy
sudo bash -c "cat /root/passwd_bash.copy | while read word;do
	if [[ \$word == \"games\"* ]];then
		echo \"games:x:12:100:games:/usr/games:/bin/bash\" >> passwd.copy.temp
	else
		echo \"\$word\" >> passwd.copy.temp
	fi
done"
sudo mv -f passwd.copy.temp /root/passwd_bash.copy
