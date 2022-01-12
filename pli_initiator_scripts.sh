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

    PLI_INIT_RAWFILE="pli_init.raw"
    PLI_INIT_DATFILE="pli_init.dat"
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
    git clone https://github.com/GoPlugin/external-Initiator
    cd $PLI_INITOR_DIR
    git checkout main
    go install



    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CREATE LOCAL INITIATOR...${NC}"
    echo 
    export FEATURE_EXTERNAL_INITIATORS=true
    plugin admin login
    plugin initiators create $PLI_L_INIT_NAME http://localhost:8080/jobs > pli_init.raw

plugin initiators create xdc http://localhost:8080/jobs
plugin initiators destroy xdc http://localhost:8080/jobs
plugin initiators create xdc http://localhost:8080/jobs > pli_init.raw


sed -i 's/ ║ /,/g;s/╬//g;s/═//g;s/║//g' pli_init.raw
sed -n '/xdc/,//p' pli_init.raw > pli_init.dat
sed -i 's/,/\n/g;s/^.xdc//g' pli_init.dat
sed -i 's/^http.*//g' pli_init.dat
sed -i.bak '/^$/d;/^\s*$/d;s/[ \t]\+$//' pli_init.dat
cat pli_init.dat


read -r -d '' EXT_ACCESSKEY EXT_SECRET EXT_OUTGOINGTOKEN EXT_OUTGOINGSECRET <pli_init.dat
echo
echo "$EXT_ACCESSKEY"
echo "$EXT_SECRET"
echo "$EXT_OUTGOINGTOKEN"
echo "$EXT_OUTGOINGSECRET"


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







sed -i 's/ ║ /,/g' pli_init.raw
sed -i 's/╬//g;s/═//g;s/║//g' pli_init.raw
sed -i 's/╬//g' pli_init.raw
sed -i 's/═//g' pli_init.raw
sed -i 's/║//g' pli_init.raw
sed -n '/xdc/,//p' pli_init.raw > pli_init.dat
sed -i 's/,/\n/g;s/^.xdc//g;s/^http.*//g' pli_init.dat
sed -i 's/,/\n/g' pli_init.dat
sed -i 's/^.xdc//g' pli_init.dat
sed -i.bak 's/^http.*//g' pli_init.dat
sed -i.bak '/^$/d;/^\s*$/d;s/[ \t]\+$//' pli_init.dat
sed -i '/^$/d' pli_init.dat
sed -i '/^\s*$/d' pli_init.dat
sed -i 's/[ \t]\+$//' pli_init.dat


read -r -d '' EXT_ACCESSKEY EXT_SECRET EXT_OUTGOINGTOKEN EXT_OUTGOINGSECRET <init.strip
echo
echo "$EXT_ACCESSKEY"
echo "$EXT_SECRET"
echo "$EXT_OUTGOINGTOKEN"
echo "$EXT_OUTGOINGSECRET"


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
