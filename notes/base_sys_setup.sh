#!/bin/bash

echo -e "## Setup: System updates..."
sudo apt update -y && sudo apt upgrade -y

echo -e "## Setup: Install necessary apps..."
sudo apt install net-tools git curl locate ufw -y 
sudo updatedb


echo -e "## Setup: Add new local admin account with sudo access..."
#   Generate the encrypted password to be passed as follows;
#   root@plitest:/# mkpasswd -m sha256crypt testpassword
#   $5$HFpQR/kzgOONS$Uf6BwLbssmhByLLJFje/WV/vMT1TeGwH8CnLnoQV4XD
#   root@plitest:/#

sleep 1s

echo -e "## Provide user details..."
# Ask the user acc for login details
read -p 'Enter Username: ' uservar
read -sp 'Enter Password: ' passvar
encpassvar=$(mkpasswd -m sha256crypt $passvar)

sleep 2s

echo -e "## Setup: Creating the new acc user & group & adds to sudoers..."
sudo groupadd $uservar
sudo useradd -p "$encpassvar" "$uservar" -m -s /bin/bash -g "$uservar" -G sudo

echo -e "## Verify user account..."
sudo cat /etc/passwd | grep $uservar
echo -e "## Verify user group..."
sudo cat /etc/group | grep $uservar

sleep 1s

echo -e "## Setup: Change SSH port..."
# !! IMPORTANT: DO NOT close existing ssh session...
# !! Instead open a second connection to the new port
#
read -p 'Enter New SSH Port to use: ' vNEW_SSH_PORT
sudo sed -i -e 's/\#Port 22/\Port $vNEW_SSH_PORT/g' /etc/ssh/sshd_config
# sudo sed -i -e 's/\#Port 22/\Port 6222/g' /etc/ssh/sshd_config

#echo -e "## Check that the sshd is listening on new non-standard port
#sudo netstat -tpln | grep $vNEW_SSH_PORT

#sleep 3s


echo -e "## Setup: Configure Firewall..."
## default ssh & non-standard ssh port
sudo ufw allow 22/tcp && sudo ufw allow $vNEW_SSH_PORT/tcp

## sudo ufw allow 22/tcp && sudo ufw allow 6222/tcp    # default ssh & non-standard ssh port
## node local job server http/https ports
sudo ufw allow 6688/tcp && sudo ufw allow 6689/tcp


echo -e "## Setup: Enable Firewall..."
sudo systemctl start ufw && sudo systemctl status ufw
sleep 2s
sudo ufw enable
sudo ufw status verbose


echo -e "## Setup: Change UFW logging to ufw.log only"
# source: https://handyman.dulare.com/ufw-block-messages-in-syslog-how-to-get-rid-of-them/
sudo sed -i -e 's/\#& stop/\& stop/g' /etc/rsyslog.d/20-ufw.conf
sudo cat /etc/rsyslog.d/20-ufw.conf | grep '& stop'

echo -e "#### Base System Setup Finished ####"
