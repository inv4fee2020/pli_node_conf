#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color





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

    BASE_PLI_DIR="/pli_node"
    
    if [ ! -d "$BASE_PLI_DIR" ]; then
        sudo mkdir $BASE_PLI_DIR
    fi
    cd /pli_node
    sudo git clone https://github.com/GoPlugin/plugin-deployment.git && cd plugin-deployment
    sudo rm -f {apicredentials.txt,password.txt}
    sleep 2s




    ## .env.password OR password.txt == keystore (STRONG PASSWORD !!)
    ## .env.apicred OR apicredentials.txt == Local Jobs Web Server credentials 
    ## Default Postgresql DB NAME == plugin_mainnet_db

    FILE_API=".env.apicred"
    FILE_KEYSTORE=".env.password"

    API_EMAIL="user123@gmail.com"
    API_PASS="pass123"
    PASS_KEYSTORE="Som3$tr*nGp4$$w0Rd"

    ## Maintain teh single quotes as these are needed inorder to pass the var correctly as the 
    ## system expects it..
    DB_PWD_FIND="'postgres'"
    DB_PWD_REPLACE="testdbpwd1234"

    BASH_FILE1="1_prerequisite.bash"
    BASH_FILE2="2_nodeStartPM2.sh"
    BASH_FILE3="3_InitiatorStartPM2.sh"
    #echo -e "run functions.. exit"

    

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
    sudo cat $BASH_FILE1 | grep postgres
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

    sudo bash /pli_node/plugin-deployment/$BASH_FILE1


    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user CREDENTIALS values...${NC}"
    echo 

    sudo sed -i.bak "s/password.txt/$FILE_KEYSTORE/g" $BASH_FILE2
    sudo sed -i.bak "s/apicredentials.txt/$FILE_API/g" $BASH_FILE2
    sudo sed -i.bak "s/:postgres/:$DB_PWD_REPLACE/g" $BASH_FILE2
    sudo cat 2_nodeStartPM2.sh | grep node
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user TLS values...${NC}"
    echo 
    sudo sed -i.bak "s/PLUGIN_TLS_PORT=0/PLUGIN_TLS_PORT=6689/g" $BASH_FILE2
    sudo sed -i.bak "/^export PLUGIN_TLS_PORT=.*/a export TLS_CERT_PATH=/pli_node/plugin-deployment/Plugin/tls/server.crt\nexport TLS_KEY_PATH=/pli_node/plugin-deployment/Plugin/tls/server.key" $BASH_FILE2
    sudo cat $BASH_FILE2 | grep TLS
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}## Install: Create TLS CA / Certificate & files / folders...${NC}"
    echo 
    sudo su
    sudo mkdir /pli_node/plugin-deployment/Plugin/tls && cd /pli_node/plugin-deployment/Plugin/tls
    openssl req -x509 -out  server.crt  -keyout server.key \
    -newkey rsa:2048 -nodes -sha256 -days 1826 \
    -subj '/CN=localhost' -extensions EXT -config <(printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth\n" )
    exit

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
        1) echo -e "${GREEN}## Command exited with NO error...${NC}"
            echo $GO_VER
            echo
            echo -e "${GREEN}## Install proceeding as normal...${NC}"
            ;;
        0) echo -e "${RED}## Command exited with ERROR - updating bash profile...${NC}"
            echo
            source ~/.profile;
            FUNC_EXIT_ERROR
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

