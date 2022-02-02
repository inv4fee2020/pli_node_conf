#!/bin/bash

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1

# Set Colour Vars
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get current user id and store as var
USER_ID=$(getent passwd $EUID | cut -d: -f1)
GROUP_ID=$(getent group $EUID | cut -d: -f1)

source ~/"plinode_$(hostname -f)".vars
source ~/"plinode_$(hostname -f)"_bkup.vars







FUNC_CONF_BACKUP_LOCAL(){

echo
echo "local backup - running tar backup process for configuration files"
tar -cvpzf $CONF_BACKUP_OBJ ~/plinode* ~/pli_init* ~/plugin-deployment/.env*
#error_exit;

#sleep 2s
FUNC_DB_BACKUP_ENC

if [ "$_OPTION" == "-full" ]; then
    FUNC_DB_BACKUP_LOCAL
fi


}




FUNC_DB_BACKUP_LOCAL(){

echo "local backup - checking pgpass file exists - create if necessary"
if [ ! -e /$DB_BACKUP_PATH/.pgpass ]; then
    #clear
cat <<EOF > ~/.pgpass
Localhost:5432:$DB_NAME:postgres:$DB_PWD_NEW
EOF
fi

echo
echo "local backup - setting pgpass file perms"
if [ "$SET_ROOT_DIR" == "true" ]; then
    cp -p ~/.pgpass /$DB_BACKUP_PATH/.pgpass
    sudo chown postgres:postgres /$DB_BACKUP_PATH/.pgpass
    sudo chmod 600 /$DB_BACKUP_PATH/.pgpass
else
    cp -p ~/.pgpass $DB_BACKUP_PATH/.pgpass
    sudo chown postgres:postgres $DB_BACKUP_PATH/.pgpass
    sudo chmod 600 $DB_BACKUP_PATH/.pgpass
fi

#sleep 1s
echo
echo "local backup - running pgdump backup process"
# switch to 'postgres' user and run command to create inital sql dump file
sudo su postgres -c "export PGPASSFILE="$DB_BACKUP_PATH/.pgpass"; pg_dump -c -w -U postgres $DB_NAME | gzip > /$DB_BACKUP_OBJ"
#error_exit;

echo
echo "local backup - successfully created file:  "$DB_BACKUP_OBJ""
sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER $DB_BACKUP_OBJ

# Calls the file encryption 
FUNC_DB_BACKUP_ENC;


# check menu selection & that remote backup software configured
# GD_ENABLED set in FUNC_DB_PRE_CHECKS
#echo "$GD_ENABLED"
#if [ "$_OPTION" == "-full" ] && [ "$GD_ENABLED" == "true" ]; then
#    FUNC_DB_BACKUP_REMOTE
#fi

}




FUNC_DB_BACKUP_ENC(){

# runs GnuPG or gpg to encrypt the sql dump file - uses main keystore password as secret
# outputs file to new folder ready for upload

if [ -e $DB_BACKUP_OBJ ]; then
sudo gpg --yes --batch --passphrase=$PASS_KEYSTORE -o /$ENC_PATH/$ENC_FNAME -c /$DB_BACKUP_OBJ
error_exit;
echo
echo "local backup - successfully created file:  "$ENC_FNAME""
sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER /$ENC_PATH/$ENC_FNAME
echo
echo "local backup - securely erase unencrypted file:  "$DB_BACKUP_OBJ""
shred -uz -n 1 /$DB_BACKUP_OBJ
fi

if [ -e $CONF_BACKUP_OBJ ]; then
sudo gpg --yes --batch --passphrase=$PASS_KEYSTORE -o /$ENC_PATH/$ENC_CONFNAME -c $CONF_BACKUP_OBJ
error_exit;
echo
echo "local backup - successfully created file:  "$ENC_CONFNAME""
sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER /$ENC_PATH/$ENC_CONFNAME
echo
echo "local backup - securely erase unencrypted file:  "$CONF_BACKUP_OBJ""
shred -uz -n 1 /$CONF_BACKUP_OBJ
fi

#sleep 2s
}





FUNC_DB_BACKUP_REMOTE(){


# add check that gupload is installed!
# switches to gupload user to run cmd to upload encrypted file to your google drive - skips existing files

# add check for user account & installation

sudo su gdbackup -c "cd ~/; .google-drive-upload/bin/gupload -q -d /$DB_BACKUP_PATH/*.gpg -C $(hostname -f) --hide"
error_exit;
}


error_exit()
{
    if [ $? != 0 ]; then
        echo
        echo "ERROR - Exiting early"
        exit 1
    else
        return
    fi
}



case "$1" in
        -full)
                _OPTION="-full"
                FUNC_CONF_BACKUP_LOCAL
                ;;
        -conf)
                _OPTION="-conf"
                FUNC_CONF_BACKUP_LOCAL
                ;;
        -db)
                _OPTION="-db"
                FUNC_DB_BACKUP_LOCAL
                ;;
        -remote)
                _OPTION="-remote"
                FUNC_DB_BACKUP_REMOTE
                ;;
#        -p)
#                FUNC_DB_PRE_CHECKS
#                ;;
#        -f)
#                FUNC_CHECK_DIRS
#                ;;
        *)
                clear
                echo 
                echo 
                echo -e "${GREEN}Usage: $0 {function}${NC}"
                echo 
                echo -e "${GREEN}where {function} is one of the following;${NC}"
                echo 
                echo -e "${GREEN}      -full      ==  performs a local backup of both config & DB files only${NC}"
                echo -e "${GREEN}      -conf      ==  performs a local backup of config files only${NC}"
                echo -e "${GREEN}      -db        ==  performs a local backup of DB files only${NC}"
                echo 
                echo -e "${GREEN}      -remote    ==  copies local backup files to your google drive (if configured)${NC}"
                echo
                #echo  -e "${GREEN}      -p         ==  carries out pre-checks on user / group variables defined in file: $PLI_DB_VARS_FILE ${NC}"
                #echo  -e "${GREEN}      -f         ==  carries out pre-checks on directory / path variables defined in file: $PLI_DB_VARS_FILE ${NC}"
                echo 
                echo 
esac
