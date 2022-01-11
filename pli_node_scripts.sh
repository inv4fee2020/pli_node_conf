#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PLI_BASE_DIR="pli_node"
    PLI_DEPLOY_DIR="plugin-deployment"
    PLI_DEPLOY_PATH="/$PLI_BASE_DIR/$PLI_DEPLOY/"

    TLS_CERT_PATH="/$PLI_BASE_DIR/$PLI_DEPLOY_DIR/Plugin/tls"
    PLI_HTTP_PORT="6688"
    PLI_HTTPS_PORT="6689"

    ## .env.password OR password.txt == keystore (STRONG PASSWORD !!)
    ## .env.apicred OR apicredentials.txt == Local Jobs Web Server credentials 
    ## Default Postgresql DB NAME == plugin_mainnet_db

    FILE_API=".env.apicred"
    FILE_KEYSTORE=".env.password"
    API_EMAIL="user123@gmail.com"
    API_PASS="passW0rd123"
    # NOTE: error creating api initializer: must enter a password with 8 - 50 characters

    PASS_KEYSTORE="Som3$tr*nGp4$$w0Rd"

    ## Maintain teh single quotes as these are needed inorder to pass the var correctly as the 
    ## system expects it..
    DB_PWD_FIND="'postgres'"
    DB_PWD_REPLACE="testdbpwd1234"

    BASH_FILE1="1_prerequisite.bash"
    BASH_FILE2="2_nodeStartPM2.sh"
    BASH_FILE3="3_InitiatorStartPM2.sh"


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
    echo -e "${GREEN}## CONFIRM SCRIPTS EXPORT VALUES HAVE BEEN UPDATED...${NC}"
    echo 
    # Ask the user acc for login details (comment out to disable)
    
        while true; do
            read -r -p "please confirm that you have updated this script with your values ? (y/n) " _input
            case $_input in
                [Yy][Ee][Ss]|[Yy]* ) 
                    FUNC_NODE_DEPLOY
                    break
                    ;;
                [Nn][Oo]|[Nn]* ) 
                    FUNC_EXIT
                    ;;
                * ) echo "Please answer (y)es or (n)o.";;
            esac
        done
}



FUNC_NODE_DEPLOY(){
    
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}"
    echo -e "${GREEN}     Script Deployment menthod"
    echo -e "${GREEN}"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################${NC}"
    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: Clone repo to local install folder...${NC}"
    echo 
    
    if [ ! -d "/$PLI_BASE_DIR" ]; then
        sudo mkdir "/$PLI_BASE_DIR"
        USER_ID=$(getent passwd $EUID | cut -d: -f1)
        sudo chown $USER_ID:$USER_ID -R
    fi
    cd /pli_node
    sudo git clone https://github.com/GoPlugin/plugin-deployment.git && cd plugin-deployment
    sudo rm -f {apicredentials.txt,password.txt}
    sleep 2s
    
    sudo touch {$FILE_KEYSTORE,$FILE_API}
    sudo chmod 666 {$FILE_KEYSTORE,$FILE_API}

    sudo echo $API_EMAIL > $FILE_API
    sudo echo $API_PASS >> $FILE_API
    sudo echo $PASS_KEYSTORE > $FILE_KEYSTORE

    sudo chmod 600 {$FILE_KEYSTORE,$FILE_API}

    # Remove the file if necessary; sudo rm -f {.env.apicred,.env.password}



    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: UPDATE bash file $BASH_FILE1 with user values...${NC}"
    echo 

    sudo sed -i.bak "s/$DB_PWD_FIND/'$DB_PWD_REPLACE'/g" $BASH_FILE1
    sudo cat $BASH_FILE1 | grep PASSWORD
    sleep 1s


    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: PRE-CHECKS for bash file $BASH_FILE1...${NC}"
    echo 

    sudo apt remove --autoremove golang -y
    sudo rm -rf /usr/local/go


    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: EXECUTE bash file $BASH_FILE1...${NC}"
    echo 

    sudo bash /$PLI_BASE_DIR/$PLI_DEPLOY_DIR/$BASH_FILE1

    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user CREDENTIALS values...${NC}"
    echo 

    sudo sed -i.bak "s/password.txt/$FILE_KEYSTORE/g" $BASH_FILE2
    sudo sed -i.bak "s/apicredentials.txt/$FILE_API/g" $BASH_FILE2
    sudo sed -i.bak "s/:postgres/:$DB_PWD_REPLACE/g" $BASH_FILE2
    sudo sed -i.bak '/SECURE_COOKIES=false/d' $BASH_FILE2
    sudo cat $BASH_FILE2 | grep node
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user TLS values...${NC}"
    echo 

    sudo sed -i.bak "s/PLUGIN_TLS_PORT=0/PLUGIN_TLS_PORT=$PLI_HTTPS_PORT/g" $BASH_FILE2
    sudo sed -i.bak "/^export PLUGIN_TLS_PORT=.*/a export TLS_CERT_PATH=$TLS_CERT_PATH/server.crt\nexport TLS_KEY_PATH=$TLS_CERT_PATH/server.key" $BASH_FILE2
    sudo cat $BASH_FILE2 | grep TLS
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}## Install: Create TLS CA / Certificate & files / folders...${NC}"
    echo 

    sudo sh -c "mkdir $TLS_CERT_PATH && cd $TLS_CERT_PATH; openssl req -x509 -out server.crt -keyout server.key -newkey rsa:4096 \
-sha256 -days 3650 -nodes -extensions EXT -config \
<(echo "[dn]"; echo CN=localhost; echo "[req]"; echo distinguished_name=dn; echo "[EXT]"; echo subjectAltName=DNS:localhost; echo keyUsage=digitalSignature; echo \
extendedKeyUsage=serverAuth) -subj "/CN=localhost"
exit"


    echo 
    echo 
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with INITIATORS values...${NC}"
    echo 
    sudo sed -i.bak "/^ export DATABASE_TIMEOUT=.*/a export FEATURE_EXTERNAL_INITIATORS=true" $BASH_FILE2
    sudo cat $BASH_FILE2 | grep INITIATORS
    sleep 1s


    echo -e "${GREEN}## Install: Check Golang version & bash profile path...${NC}"
    echo 
    source ~/.profile
    GO_VER=$(go version)
    go version; GO_EC=$?
    case $GO_EC in
        0) echo -e "${GREEN}## Command exited with NO error...${NC}"
            echo $GO_VER
            echo
            echo -e "${GREEN}## Install proceeding as normal...${NC}"
            ;;
        1) echo -e "${RED}## Command exited with ERROR - updating bash profile...${NC}"
            echo
            source ~/.profile;
            sudo sh -c 'echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile'
            echo "cat "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile"
            echo
            echo -e "${RED}## Check GO Version manually...${NC}"
            sleep 2s
            #FUNC_EXIT_ERROR
            #exit 1
            ;;
        *) echo -e "${RED}## Command exited with OTHER ERROR...${NC}"
            echo -e "${RED}## 'go version' returned : $GO_EC ${NC}"
            echo
            FUNC_EXIT_ERROR
            #exit 1
            ;;
    esac

    #echo -e "${GREEN}## Install proceeding as normal...${NC}"



    echo -e "${GREEN}## Install: Start PM2 $BASH_FILE2 & set auto start on reboot...${NC}"
    echo 
    sudo pm2 start $BASH_FILE2
    sleep 1s
    sudo pm2 list 
    
    sleep 2s
    sudo pm2 list
    sudo pm2 startup systemd


    }

FUNC_EXIT_ERROR(){
	exit 1
	}


FUNC_EXIT(){
	exit 0
	}
  
FUNC_VALUE_CHECK;

