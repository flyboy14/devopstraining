#!/bin/bash

sudo cp /etc/passwd /root/passwd_bash.copy
echo "Copying /etc/passwd to /root/passwd_bash.save"
sudo chsh -s /bin/bash games

