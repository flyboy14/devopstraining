#!/bin/bash

gcloud compute instances create nginx-gcloud --zone us-central1-c \
--labels servertype=nginxserver,osfamily=redhat,wayofinstallation=gcloud \
--boot-disk-type pd-ssd --boot-disk-size 35GB --custom-memory 4608MB --custom-cpu 1 \
--deletion-protection --image-family centos-7 --image-project centos-cloud \
--project vm-creating-codelab --metadata-from-file startup-script=provision.sh \
--tags http-server,https-server