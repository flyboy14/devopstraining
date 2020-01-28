#!/bin/bash

cd /tmp/mongodb-src-r3.6.5
#yum install python2-pyyaml python2-typing
yum install python2-pip
pip2 install -r buildscripts/requirements.txt
yum install -y centos-release-scl
yum install -y devtoolset-7-gcc*
scl enable devtoolset-7 zsh
