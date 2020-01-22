#!/bin/bash

sudo bash -c "awk -F: '{print \$0}' /etc/passwd > /root/passwd_awk.copy"

sudo bash -c "awk -F: 'BEGIN {OFS = FS} {
	if (\$5 == "games") 
		\$7="/bin/bash"; 
		print \$0
	}' /root/passwd_awk.copy > passwd_awk.tmp"

sudo bash -c "awk '{print \$0}' passwd_awk.tmp > /root/passwd_awk.copy"

sudo rm passwd_awk.tmp
