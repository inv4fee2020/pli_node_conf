#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #VAR_USERNAME=""
    #VAR_PASSWORD=""

    PLI_HTTP_PORT="6688"
    PLI_HTTPS_PORT="6689"
    PLI_SSH_DEF_PORT="22"
    PLI_SSH_NEW_PORT="6222"
    SSH_CONFIG_PATH="/etc/ssh/sshd_config"

FUNC_VALUE_CHECK(){
    
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}"
    echo -e "${GREEN}     Script Deployment menthod"
    echo -e "${GREEN}"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################${NC}"



    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CONFIRM SCRIPTS VARIABLE DEFINITIONS HAVE BEEN UPDATED...${NC}"
    echo 
    # Ask the user acc for login details (comment out to disable)
    
        while true; do
            read -r -p "please confirm that you have updated this script with your values ? (y/n) " _input
            case $_input in
                [Yy][Ee][Ss]|[Yy]* ) 
                    FUNC_BASE_SETUP
                    break
                    ;;
                [Nn][Oo]|[Nn]* ) 
                    FUNC_EXIT
                    ;;
                * ) echo "Please answer (y)es or (n)o.";;
            esac
        done
}    


FUNC_BASE_SETUP(){
    
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}"
    echo -e "${GREEN}     Script Deployment menthod"
    echo -e "${GREEN}"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################${NC}"


    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: System updates...${NC}"
    echo 
    sudo apt update -y && sudo apt upgrade -y

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: Install necessary apps...${NC}"
    echo 
    sudo apt install net-tools git curl locate ufw whois -y 
    #sudo updatedb

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: Add new local admin account with sudo access...${NC}"
    echo 
    #   Generate the encrypted password to be passed as follows;
    #   root@plitest:/# mkpasswd -m sha256crypt testpassword
    #   $5$HFpQR/kzgOONS$Uf6BwLbssmhByLLJFje/WV/vMT1TeGwH8CnLnoQV4XD
    #   root@plitest:/#

    sleep 1s
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Provide user details...${NC}"
    echo 
    # Ask the user acc for login details (comment out to disable - See Definitions section to hard code)
    read -p 'Enter Username: ' VAR_USERNAME
    read -sp 'Enter Password: ' VAR_PASSWORD

    encVAR_PASSWORD=$(mkpasswd -m sha256crypt $VAR_PASSWORD)

    sleep 2s
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: Creating the new acc user & group & adds to sudoers...${NC}"
    echo 
    sudo groupadd $VAR_USERNAME
    sudo useradd -p "$encVAR_PASSWORD" "$VAR_USERNAME" -m -s /bin/bash -g "$VAR_USERNAME" -G sudo

    echo -e "${GREEN}## Verify user account...${NC}"
    echo 
    sudo cat /etc/passwd | grep $VAR_USERNAME
    echo -e "${GREEN}## Verify user group...${NC}"
    echo 
    sudo cat /etc/group | grep $VAR_USERNAME

    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: Creating SSH keys for new acc user ${NC}"
    echo 
    #su $VAR_USERNAME
    cd /home/$VAR_USERNAME
    sudo mkdir -p .ssh 
    sudo touch .ssh/authorized_keys && sudo chmod 777 .ssh/authorized_keys

    # create private & public keys -- no user interaction -- comment added
    # to aid in identifying key usage/purpose. To add as password to private
    # key, simply remote the '-P ""' at the end of the command.
    # su $VAR_USERNAME
    
    sudo ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa_$VAR_USERNAME -C "pli_node $VAR_USERNAME" -q -P ""
    sudo cat .ssh/id_rsa_$VAR_USERNAME.pub >> .ssh/authorized_keys
    sudo chown $VAR_USERNAME:$VAR_USERNAME -R .ssh && sudo chmod 700 .ssh
    sudo chmod 600 .ssh/authorized_keys

    echo 
    echo -e "${RED}## IMPORTANT: Be sure to copy the private key to your local machine${NC}"
    echo -e "${RED}## IMPORTANT: where you will admin the node from & delete the private${NC}"
    echo -e "${RED}## IMPORTANT: key file from the PLI node${NC}"
    echo 

    # The ssh keys should ideally be generated on your local linux/mac workstation and then the 
    # public key file uploaded to the PLI node. The following code has been tested on this basis;
    # change the below values to suit your requirements - the publiy key is for the account you are
    # logging in with - in this case testuser123
    #
    # NOTE: This method depends on the ability to logon with Password Authentication enabled
    #
    ###  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_testuser123 -C "pli_node testuser123" -q -P ""
    ###  cat id_rsa_testuser123.pub | ssh testuser123@198.51.100.0 "mkdir -p ~/.ssh && chmod \
    ###  700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    ###

    sleep 3s

    echo 
    echo 
    echo -e "${GREEN}#########################################################################" 
    echo 
    echo -e "${GREEN}## Setup: Configure Firewall...${NC}"
    echo 
    ## default ssh & non-standard ssh port
    sudo ufw allow $PLI_SSH_DEF_PORT/tcp

    ## node local job server http/https ports
    sudo ufw allow $PLI_HTTP_PORT/tcp && sudo ufw allow $PLI_HTTPS_PORT/tcp


    echo 
    echo 
    echo -e "${GREEN}#########################################################################" 
    echo 
    echo -e "${GREEN}## Setup: Enable Firewall...${NC}"
    echo 
    sudo systemctl start ufw && sudo systemctl status ufw
    sleep 2s
    sudo ufw enable
    sudo ufw status verbose



    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo 
    echo -e "${GREEN}## Setup: Change UFW logging to ufw.log only${NC}"
    echo 
    # source: https://handyman.dulare.com/ufw-block-messages-in-syslog-how-to-get-rid-of-them/
    sudo sed -i -e 's/\#& stop/\& stop/g' /etc/rsyslog.d/20-ufw.conf
    sudo cat /etc/rsyslog.d/20-ufw.conf | grep '& stop'



    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: Change SSH port & Secure Authentication methods...${NC}"
    echo 
    echo -e "${RED}# !! IMPORTANT: DO NOT close your existing ssh session..."
    echo -e "${RED}# !! Open a second connection to the new port with you existing ADMIN "
    echo -e "${RED}# !! or ROOT account - PASSWORD AUTH will be disabled from this point. ${NC}"
    
    sleep 3
    #read -p 'Enter New SSH Port to use: ' vNEW_SSH_PORT
    sudo sed -i.bak 's/#Port '"$PLI_SSH_DEF_PORT"'/Port '"$PLI_SSH_NEW_PORT"'/g' $SSH_CONFIG_PATH
    sudo sed -i.bak -e 's/\#PasswordAuthentication yes/PasswordAuthentication no/g' $SSH_CONFIG_PATH
    sudo sed -i.bak -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' $SSH_CONFIG_PATH
    sudo sed -i.bak -e 's/UsePAM yes/UsePAM no/g' $SSH_CONFIG_PATH
    
    

    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: Add new SSH port to firewall...${NC}"
    echo
    sudo ufw allow $PLI_SSH_NEW_PORT/tcp
    
    echo
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Setup: Restart SSH service for port change to take effect...${NC}"
    echo 
    sudo systemctl restart sshd && sudo systemctl status sshd
    sudo netstat -tpln | grep $PLI_SSH_NEW_PORT
    
    echo
    echo -e "${GREEN}#### Base System Setup Finished ####${NC}"
}


FUNC_EXIT(){
	exit 0
	}
  
FUNC_VALUE_CHECK;
