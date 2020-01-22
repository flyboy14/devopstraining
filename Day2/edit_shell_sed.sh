#!/bin/bash

sudo bash -c "sed 's_:_:_' /etc/passwd > /root/passwd_sed.copy"
echo "Copying /etc/passwd to /root/passwd_sed.copy"

sudo sed -i 's_games:x:12:100:games:/usr/games:..*_games:x:12:100:games:/usr/games:/bin/bash_' /etc/passwd
echo "Changing shell for user games"

