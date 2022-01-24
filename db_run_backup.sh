#!/bin/bash

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1


# Get current user id and store as var
USER_ID=$(getent passwd $EUID | cut -d: -f1)

source ~/"plinode_$(hostname -f)".vars


FUNC_DB_VARS(){
## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    PLI_DB_VARS_FILE="plinode_$(hostname -f)"_sql.vars
    if [ ! -e ~/$PLI_DB_VARS_FILE ]; then
        clear
        echo
        echo
        echo -e "${RED} #### ERROR: No VARIABLES file found. ####${NC}"
        echo
        echo -e "${RED} ..creating local vars file '$HOME/$PLI_DB_VARS_FILE' ${NC}"
        cp -n sample_sql.vars ~/$PLI_DB_VARS_FILE
        chmod 600 ~/$PLI_DB_VARS_FILE
        echo
        echo -e "${GREEN} please update the vars file with your specific values.. ${NC}"
        echo -e "${GREEN} copy command to edit: ${NC}"
        echo
        echo -e "${GREEN}       nano ~/$PLI_VARS_FILE ${NC}"
        echo
        echo
        #sleep 2s
        exit 1
    fi
    source ~/$PLI_DB_VARS_FILE
}



FUNC_CHECK_DIRS(){

if ([ ! -z "$DB_BACKUP_ROOT" ] && [ "$DB_BACKUP_ROOT" != "root" ]) || ([ ! -z "$DB_BACKUP_ROOT" ] && [ "$DB_BACKUP_ROOT" != "$HOME" ]); then
    echo "the variable DB_BACKUP_ROOT value is: $DB_BACKUP_ROOT"
    echo "var is not NULL"
    echo "lets make the directory"
    if [ ! -d "/$DB_BACKUP_ROOT" ]; then
        sudo mkdir "/$DB_BACKUP_ROOT"
        sudo chown $USER_ID\:$USER_ID -R "/$DB_BACKUP_ROOT";
    fi
else
    if [ -z "$DB_BACKUP_ROOT" ]; then
        DB_BACKUP_ROOT="$HOME"
        echo "..Detected NULL we set the variable to: "$HOME""
        echo "..updating the 'DB_BACKUP_PATH' variable.."
        DB_BACKUP_PATH="$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
        echo "..updating file "$PLI_DB_VARS_FILE" variable DB_BACKUP_ROOT to: \$HOME"
        sed -i.bak 's/DB_BACKUP_ROOT=\"\"/DB_BACKUP_ROOT=\"\$HOME\"/g' ~/$PLI_DB_VARS_FILE
    fi
    echo "var is set to "$DB_BACKUP_ROOT""
    echo ".... nothing else to do.. continuing to next variable";
fi

if [ ! -z "$DB_BACKUP_DIR" ] ; then
    echo "the variable DB_BACKUP_DIR value is: $DB_BACKUP_DIR"
    echo "var is not NULL"
    echo "lets make the directory"
    if [ ! -d "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR" ]; then
        sudo mkdir "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
        sudo chown $USER_ID\:$USER_ID -R "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR";
    fi
else
    echo "the variable DB_BACKUP_DIR value is: $DB_BACKUP_DIR"
    echo "Detected NULL - we set the value"
    DB_BACKUP_DIR="node_backups"
    echo "..updating file "$PLI_DB_VARS_FILE" variable DB_BACKUP_DIR to: "$DB_BACKUP_DIR""
    sed -i.bak 's/DB_BACKUP_DIR=\"\"/DB_BACKUP_DIR=\"'$DB_BACKUP_DIR'\"/g' ~/$PLI_DB_VARS_FILE

    sudo mkdir "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
    sudo chown $USER_ID\:$USER_ID -R "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"

    cat ~/$PLI_DB_VARS_FILE | grep $DB_BACKUP_DIR
    sleep 3s
    echo "exiting directory check & continuing...";
fi

DB_BACKUP_PATH="/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
echo "your configured node backup PATH is: $DB_BACKUP_PATH"
sleep 2s

}


FUNC_DB_BACKUP_LOCAL(){
sudo usermod -aG postgres $(getent passwd $EUID | cut -d: -f1)

echo "backup path used is: $DB_BACKUP_PATH"
sleep 2s

if [ ! -e /$DB_BACKUP_PATH/.pgpass ]; then
    #clear
cat <<EOF >> ~/.pgpass
Localhost:5432:$DB_NAME:postgres:$DB_PWD_NEW
EOF
    chmod 600 ~/.pgpass
    cp -n ~/.pgpass /$DB_BACKUP_PATH/.pgpass
    sudo chown postgres:postgres /$DB_BACKUP_PATH/.pgpass
fi

echo "vars in use here;"
echo "$PGPASSFILE"
echo "$DB_BACKUP_PATH"
echo "$DB_NAME"
echo "$DB_BACKUP_OBJ"
echo "$DB_BACKUP_FUSER:"
echo "$DB_BACKUP_GUSER"
echo ""

sudo su postgres -c "export PGPASSFILE="/$DB_BACKUP_PATH/.pgpass"; pg_dump -c -w -U postgres $DB_NAME | gzip > /$DB_BACKUP_OBJ"
sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER /$DB_BACKUP_OBJ
sleep 2s

sudo gpg --yes --batch --passphrase=$PASS_KEYSTORE -o /$ENC_PATH/$ENC_FNAME -c /$DB_BACKUP_OBJ
sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER /$ENC_PATH/$ENC_FNAME
#rm -f /$DB_BACKUP_OBJ
}



FUNC_DB_BACKUP_REMOTE(){
# add check that gupload is installed!
sudo su gdbackup -c "cd ~/; .google-drive-upload/bin/gupload -q -d /$DB_BACKUP_PATH/*.gpg -C $(hostname -f) --hide"
}

#FUNC_CLEAN_UP_REMOTE(){
# remove files store in the backups folder    
#}




FUNC_DB_VARS;
#FUNC_DB_BACKUP_LOCAL;
#FUNC_DB_BACKUP_REMOTE;


clear
case "$1" in
        local)
                
                FUNC_CHECK_DIRS
                FUNC_DB_BACKUP_LOCAL
                ;;
        remote)
                FUNC_DB_BACKUP_REMOTE
                ;;
        *)
                
                echo 
                echo 
                echo "Usage: $0 { local | remote }"
                echo 
                echo "please provide one of the above values to run the scripts"
                echo "    example: " $0 local""
                echo 
                echo 
esac
