#!/bin/bash

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1

# Get local hostname and load the vars file
PLI_VARS_FILE="plinode_$(hostname -f).vars"
source ~/$PLI_VARS_FILE

##  Rough script to roll back installation for testing purposes...
## Use with caution !
#sudo su

# Stop & Delete all active PM2 processes
pm2 stop all && pm2 delete all

# Stop the POSTGRES service
sudo systemctl stop postgresql

# Delete folders for; Go install, plugin-deployment install, POSTGRES.
sudo rm -rf /usr/local/go
sudo rm -rf /$PLI_DEPLOY_PATH
sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && rsudo m -rf /etc/postgresql-common/

# Remove the POSTGRES packages & clean up linked packages
sudo apt --purge remove postgresql* -y && sudo apt purge postgresql* -y 
sudo apt --purge remove postgresql -y postgresql-doc -y postgresql-common -y
sudo apt autoremove -y

# Clean up any remaining folders 
sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && sudo rm -rf /etc/postgresql-common/

# Remove the POSTGRES install system account & group
sudo userdel -r postgres && sudo groupdel postgres

# Remove all plugin, nodejs linked folders for current user & root
cd ~/; sudo sh -c "rm -rf .cache/ && rm -rf .nvm && rm -rf .npm && rm -rf .plugin && rm -rf .pm2 && rm -rf work && rm -rf go && rm -rf .yarn*"
#sleep 0.5s
#sudo su -c "cd /root; rm -rf .cache/ && rm -rf .nvm && rm -rf .npm && rm -rf .plugin && rm -rf .pm2 && rm -rf work && rm -rf go && rm -rf .yarn*"