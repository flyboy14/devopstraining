#!/bin/bash

sudo bash -c "awk -F: '{print \$0}' /etc/passwd > /root/passwd_awk.copy"
echo "Copying /etc/passwd to /root/passwd_awk.copy"

sudo awk -F: 'BEGIN {OFS = FS} {
if ($5 == "games") 
	$7="/bin/bash"; 
print $0}' /etc/passwd > tmppasswd
sudo bash -c "awk '{print \$0}' tmppasswd > /etc/passwd"
echo "Changing shell for user games"
rm tmppasswd

