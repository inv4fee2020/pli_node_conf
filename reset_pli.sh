#!/bin/bash

##  Rough script to roll back installation for testing purposes...
## Use with caution !
#sudo su
sudo pm2 stop all && sudo pm2 delete all

sudo systemctl status postgresql && sudo systemctl stop postgresql

sudo rm -rf /usr/local/go
sudo rm -rf /pli_node/plugin-deployment
sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && rsudo m -rf /etc/postgresql-common/


sudo apt --purge remove postgresql* -y && sudo apt purge postgresql* -y 
sudo apt --purge remove -y postgresql postgresql-doc postgresql-common -y
sudo apt autoremove

sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && rsudo m -rf /etc/postgresql-common/

sudo userdel -r postgres && sudo groupdel postgres

sudo su -c "cd /root; rm -rf .cache/ && rm -rf .nvm && rm -rf .npm && rm -rf .plugin && sudo rm -rf .pm2 && rm -rf work/"