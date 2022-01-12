#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PLI_BASE_DIR="pli_node"
    PLI_DEPLOY_DIR="plugin-deployment"
    PLI_DEPLOY_PATH="/$PLI_BASE_DIR/$PLI_DEPLOY/"
    
    PLI_INITOR_DIR="external-Initiator"
    PLI_L_INIT_NAME="xdc"
    PLI_E_INIT_NAME="xinfin-mainnet"

    BASH_FILE3="3_InitiatorStartPM2.sh"
    PLI_HTTP_PORT="6688"
    PLI_HTTPS_PORT="6689"


FUNC_INITIATOR(){


    echo -e "${GREEN}############# - UNTESTED BETA - UNTESTED BETA - UNTESTED BETA ############################################################"
    echo
    echo -e "${GREEN}## INSTALL LOCAL INITIATOR...${NC}"
    echo 

    # Added to resolve error running 'plugin help'
    source ~/.profile
    
    cd $PLI_DEPLOY_PATH
    git clone https://github.com/GoPlugin/external-Initiator && cd $PLI_INITOR_DIR
    git checkout main
    go install



    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CREATE LOCAL INITIATOR...${NC}"
    echo 
    export FEATURE_EXTERNAL_INITIATORS=true
    plugin admin login
    plugin initiators create $PLI_L_INIT_NAME http://localhost:8080/jobs >> init_creds

sed -n '/xdc/,//p' init_credentials
sed -i 's/╬//g' init_credentials
sed -i 's/═//g' init_credentials
sed -i 's/║//g' init_credentials
sed -n '/xdc/,//p' init_credentials >> init.strip
sed -i 's/,/\n/g' init.strip
sed -i 's/^.xdc//g' init.strip
sed -i 's/^http.*//g' init.strip
sed '/^$/d' init.strip
sed '/^\s*$/d' init.strip

while read -r first second && read -r third fourth; do 
  echo "$first $second $third $fourth"
done < init.strip

read -r -d '' first second third fourth <init.strip
echo "$first $second $third $fourth"


    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CREATE INITIATOR PM2 SERVICE FILE: $BASH_FILE3 & file perms ${NC}"
    echo
    cat <<EOF >> $BASH_FILE3
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

    cat $BASH_FILE3
    chmod u+x $BASH_FILE3


    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## START INITIATOR PM2 SERVICE $BASH_FILE3 ${NC}"
    echo    
    pm2 start $BASH_FILE3

}


FUNC_EXIT(){
	exit 0
	}
  
FUNC_INITIATOR;
