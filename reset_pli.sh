#!/bin/bash

##  Rough script to roll back installation for testing purposes...
## Use with caution !
#sudo su

pm2 stop all && pm2 delete all

sudo systemctl status postgresql && sudo systemctl stop postgresql

sudo rm -rf /usr/local/go
sudo rm -rf /$PLI_DEPLOY_PATH
sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && rsudo m -rf /etc/postgresql-common/


sudo apt --purge remove postgresql* -y && sudo apt purge postgresql* -y 
sudo apt --purge remove postgresql -y postgresql-doc -y postgresql-common -y
sudo apt autoremove -y

sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && sudo m -rf /etc/postgresql-common/

sudo userdel -r postgres && sudo groupdel postgres

cd ~/; sudo sh -c "rm -rf .cache/ && rm -rf .nvm && rm -rf .npm && rm -rf .plugin && rm -rf .pm2 && rm -rf work && rm -rf go && rm -rf .yarn*"
sleep 0.5s
sudo su -c "cd /root; rm -rf .cache/ && rm -rf .nvm && rm -rf .npm && rm -rf .plugin && rm -rf .pm2 && rm -rf work && rm -rf go && rm -rf .yarn*"