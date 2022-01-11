#!/bin/bash

##  Rough script to roll back installation for testing purposes...
## Use with caution !
sudo su
sudo pm2 stop all && sudo pm2 delete all

sudo systemctl status postgresql && sudo systemctl stop postgresql

rm -rf /usr/local/go
rm -rf /pli_node/plugin-deployment/Plugin/
rm -rf /usr/lib/postgresql/ && rm -rf /var/lib/postgresql/ && rm -rf /var/log/postgresql/ && rm -rf /etc/postgresql/ && rm -rf /etc/postgresql-common/


apt --purge remove postgresql* -y && apt purge postgresql* -y 
apt --purge remove postgresql postgresql-doc postgresql-common -y
apt autoremove

rm -rf /usr/lib/postgresql && rm -rf /var/lib/postgresql && rm -rf /var/log/postgresql && rm -rf /etc/postgresql && rm -rf /etc/postgresql-common

userdel -r postgres && groupdel postgres

cd /root
rm -rf .cache/ && rm -rf .nvm && rm -rf .npm && rm -rf .plugin && rm -rf .pm2 && rm -rf work/