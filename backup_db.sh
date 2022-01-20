#!/bin/bash

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1

source ~/"plinode_$(hostname -f)".vars

FUNC_DB_VARS(){
## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Get current user id and store as var
    USER_ID=$(getent passwd $EUID | cut -d: -f1)


    PLI_DB_VARS_FILE="plinode_$(hostname -f)"_sql.vars
    if [ ! -e ~/$PLI_DB_VARS_FILE ]; then
        clear
        echo
        echo
        echo -e "${RED} #### ERROR: No VARIABLES file found. ####${NC}"
        echo
        echo -e "${RED} ..creating local vars file '$HOME/$PLI_DB_VARS_FILE' ${NC}"
        cp sample_sql.vars ~/$PLI_DB_VARS_FILE
        chmod 600 ~/$PLI_DB_VARS_FILE
        echo
        echo -e "${GREEN} please update the vars file with your specific values.. ${NC}"
        echo -e "${GREEN} copy command to edit: ${NC}"
        echo
        echo -e "${GREEN}nano ~/$PLI_VARS_FILE ${NC}"
        echo
        echo
        #sleep 2s
        exit 1
    fi
    source ~/$PLI_DB_VARS_FILE

}

FUNC_DB_VARS;
sleep 1s

sudo su postgres -c "export PGPASSFILE="/$DB_BACKUP_PATH/.pgpass"; pg_dump -c -w -U postgres plugin_mainnet_db | gzip > /$DB_BACKUP_OBJ"
sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER /$DB_BACKUP_OBJ
sleep 0.5s

gpg --yes --batch --passphrase=$PASS_KEYSTORE -o /$ENC_PATH/$ENC_FNAME -c /$DB_BACKUP_OBJ
sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER /$ENC_PATH/$ENC_FNAME
#rm -f /$DB_BACKUP_OBJ
