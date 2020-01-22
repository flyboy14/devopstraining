#!/bin/bash

sudo bash -c "sed 's_:_:_' /etc/passwd > /root/passwd_sed.copy"

sudo bash -c "sed -i 's_games:x:12:100:games:/usr/games:..*_games:x:12:100:games:/usr/games:/bin/bash_' /root/passwd_sed.copy"

