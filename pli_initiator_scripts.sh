#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PLI_BASE_DIR="pli_node"
    PLI_DEPLOY_DIR="plugin-deployment"
    PLI_DEPLOY_PATH="/$PLI_BASE_DIR/$PLI_DEPLOY_DIR/"
    
    PLI_INITOR_DIR="external-Initiator"
    PLI_L_INIT_NAME="xdc"
    PLI_E_INIT_NAME="xinfin-mainnet"

    PLI_INIT_RAWFILE="pli_init.raw"
    PLI_INIT_DATFILE="pli_init.dat"
    BASH_FILE3="3_InitiatorStartPM2.sh"


    DB_PWD_REPLACE="testdbpwd1234"

    PLI_HTTP_PORT="6688"
    PLI_HTTPS_PORT="6689"


FUNC_INITIATOR(){


    
    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CLONE & INSTALL LOCAL INITIATOR...${NC}"
    echo 

    # Added to resolve error running 'plugin help'
    source ~/.profile
    
    cd $PLI_DEPLOY_PATH
    git clone https://github.com/GoPlugin/external-Initiator
    cd $PLI_INITOR_DIR
    git checkout main
    go install



    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CREATE LOCAL INITIATOR...${NC}"
    echo 
    export FEATURE_EXTERNAL_INITIATORS=true
    plugin admin login
    plugin initiators create $PLI_L_INIT_NAME http://localhost:8080/jobs > $PLI_INIT_RAWFILE

    # plugin initiators create xdc http://localhost:8080/jobs
    # plugin initiators destroy xdc http://localhost:8080/jobs
    # plugin initiators create xdc http://localhost:8080/jobs > $PLI_INIT_RAWFILE


    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CAPTURE INITIATOR CREDENTIALS & FILE MANIPULATION...${NC}"
    echo 
    sed -i 's/ ║ /,/g;s/╬//g;s/═//g;s/║//g' $PLI_INIT_RAWFILE
    sed -n '/'"$PLI_L_INIT_NAME"'/,//p' $PLI_INIT_RAWFILE > $PLI_INIT_DATFILE
    sed -i 's/,/\n/g;s/^.'"$PLI_L_INIT_NAME"'//g' $PLI_INIT_DATFILE
    sed -i 's/^http.*//g' $PLI_INIT_DATFILE
    sed -i.bak '/^$/d;/^\s*$/d;s/[ \t]\+$//' $PLI_INIT_DATFILE
    cat $PLI_INIT_DATFILE
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## READ INITIATOR CREDENTIALS AS VARIABLES...${NC}"
    echo 
    read -r -d '' EXT_ACCESSKEY EXT_SECRET EXT_OUTGOINGTOKEN EXT_OUTGOINGSECRET <$PLI_INIT_DATFILE
    echo
    #echo "$EXT_ACCESSKEY"
    #echo "$EXT_SECRET"
    #echo "$EXT_OUTGOINGTOKEN"
    #echo "$EXT_OUTGOINGSECRET"
    sleep 1s


    echo
    echo
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CREATE INITIATOR PM2 SERVICE FILE: $BASH_FILE3 & file perms ${NC}"
    echo
    cd $PLI_DEPLOY_PATH
    cat <<EOF > $BASH_FILE3
#!/bin/bash
export EI_DATABASEURL=postgresql://postgres:${DB_PWD_REPLACE}@127.0.0.1:5432/plugin_mainnet_db?sslmode=disable
export EI_CHAINLINKURL=http://localhost:6688
export EI_IC_ACCESSKEY=${EXT_ACCESSKEY}
export EI_IC_SECRET=${EXT_SECRET}
export EI_CI_ACCESSKEY=${EXT_OUTGOINGTOKEN}
export EI_CI_SECRET=${EXT_OUTGOINGSECRET}
echo *** Starting EXTERNAL INITIATOR ***
external-initiator "{\"name\":\"$PLI_E_INIT_NAME\",\"type\":\"xinfin\",\"url\":\"https://pluginrpc.blocksscan.io\"}" --chainlinkurl "http://localhost:6688/"
EOF
    sleep 1s
    cat $BASH_FILE3
    chmod u+x $BASH_FILE3


    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## START INITIATOR PM2 SERVICE $BASH_FILE3 ${NC}"
    echo    
    pm2 start $BASH_FILE3
    sleep 2s
    pm2 status

}


FUNC_EXIT(){
	exit 0
	}
  
FUNC_INITIATOR;
