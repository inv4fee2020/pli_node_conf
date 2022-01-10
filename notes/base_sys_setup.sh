#!/bin/bash
GREEN='\033[0;32m'
echo -e "${GREEN}#########################################################################"
echo
echo -e "${GREEN}## Setup: System updates..."
echo 
sudo apt update -y && sudo apt upgrade -y

echo -e "${GREEN}#########################################################################"
echo
echo -e "${GREEN}## Setup: Install necessary apps..."
echo 
sudo apt install net-tools git curl locate ufw -y 
sudo updatedb

echo -e "${GREEN}#########################################################################"
echo
echo -e "${GREEN}## Setup: Add new local admin account with sudo access..."
echo 
#   Generate the encrypted password to be passed as follows;
#   root@plitest:/# mkpasswd -m sha256crypt testpassword
#   $5$HFpQR/kzgOONS$Uf6BwLbssmhByLLJFje/WV/vMT1TeGwH8CnLnoQV4XD
#   root@plitest:/#

sleep 1s
echo -e "${GREEN}#########################################################################"
echo
echo -e "${GREEN}## Provide user details..."
echo 
# Ask the user acc for login details (comment out to disable)
read -p 'Enter Username: ' uservar
read -sp 'Enter Password: ' passvar

# OR add as defined vars (uncomment to enable)
#export uservar="testuser123"
#export passvar="letmein123"

encpassvar=$(mkpasswd -m sha256crypt $passvar)

sleep 2s
echo -e "${GREEN}#########################################################################"
echo
echo -e "${GREEN}## Setup: Creating the new acc user & group & adds to sudoers..."
echo 
sudo groupadd $uservar
sudo useradd -p "$encpassvar" "$uservar" -m -s /bin/bash -g "$uservar" -G sudo

echo -e "${GREEN}## Verify user account..."
echo 
sudo cat /etc/passwd | grep $uservar
echo -e "${GREEN}## Verify user group..."
echo 
sudo cat /etc/group | grep $uservar

sleep 1s

echo -e "${GREEN}#########################################################################"
echo
echo -e "## Setup: Change SSH port..."
echo 
# !! IMPORTANT: DO NOT close existing ssh session...
# !! Instead open a second connection to the new port
#
read -p 'Enter New SSH Port to use: ' vNEW_SSH_PORT
sudo sed -i -e 's/\#Port 22/\Port $vNEW_SSH_PORT/g' /etc/ssh/sshd_config

echo -e "${GREEN}#########################################################################" 
echo 
echo -e "${GREEN}## Setup: Configure Firewall..."
echo 
## default ssh & non-standard ssh port
sudo ufw allow 22/tcp && sudo ufw allow $vNEW_SSH_PORT/tcp

## sudo ufw allow 22/tcp && sudo ufw allow 6222/tcp    # default ssh & non-standard ssh port
## node local job server http/https ports
sudo ufw allow 6688/tcp && sudo ufw allow 6689/tcp

echo -e "${GREEN}#########################################################################" 
echo 
echo -e "${GREEN}## Setup: Enable Firewall..."
echo 
sudo systemctl start ufw && sudo systemctl status ufw
sleep 2s
sudo ufw enable
sudo ufw status verbose


echo -e "${GREEN}#########################################################################"
echo 
echo -e "${GREEN}## Setup: Change UFW logging to ufw.log only"
echo 
# source: https://handyman.dulare.com/ufw-block-messages-in-syslog-how-to-get-rid-of-them/
sudo sed -i -e 's/\#& stop/\& stop/g' /etc/rsyslog.d/20-ufw.conf
sudo cat /etc/rsyslog.d/20-ufw.conf | grep '& stop'

echo -e "${GREEN}#### Base System Setup Finished ####"
