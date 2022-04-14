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


FUNC_DB_VARS(){
## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    PLI_DB_VARS_FILE="plinode_$(hostname -f)"_bkup.vars
    if [ ! -e ~/$PLI_DB_VARS_FILE ]; then
        #clear
        echo
        echo
        echo -e "${GREEN} #### NOTICE: No backup VARIABLES file found.. ####${NC}"
        echo
        echo -e "${GREEN} ..creating local backup vars file '$HOME/$PLI_DB_VARS_FILE' ${NC}"
        cp -n sample_bkup.vars ~/$PLI_DB_VARS_FILE
        chmod 600 ~/$PLI_DB_VARS_FILE
        echo
        #echo -e "${GREEN} please update the vars file with your specific values.. ${NC}"
        #echo -e "${GREEN} copy command to edit: ${NC}"
        #echo
        #echo -e "${GREEN}       nano ~/"$PLI_DB_VARS_FILE" ${NC}"
        #echo
        #echo
        #sleep 2s
        #exit 1
    fi
    source ~/$PLI_DB_VARS_FILE
}



FUNC_CHECK_DIRS(){

# checks that the DB_BACKUP_ROOT var is not NULL & not '/root' or is not NULL & not $HOME so as not to create these folder & change perms
#if ([ ! -z "$DB_BACKUP_ROOT" ] && ([ ! "$DB_BACKUP_ROOT" =~ ^/root ] || [ "$DB_BACKUP_ROOT" != "$HOME" ] || [ ! "$DB_BACKUP_ROOT" =~ ^/home ])); then
#
#    SET_ROOT_DIR=true       # logic to resolve the leading Root '/' path issue - true activates the leading '/' & false removes
#
#    #echo "DEBUG :: ROOT_DIR - IF STEP"
#    echo "checking vars - variable 'DB_BACKUP_ROOT' value is: $DB_BACKUP_ROOT"
#    echo "checking vars - variable 'DB_BACKUP_ROOT' is not NULL"
#    echo "checking vars - check directory exists & create if NOT..."
#    #if [ "$SET_ROOT_DIR" == "true" ]; then
#    #    echo "DEBUG :: ROOT_DIR true check - IF STEP"
#    #    echo " root dir flag is true"
#        if [ ! -d "/$DB_BACKUP_ROOT" ]; then
#            sudo mkdir "/$DB_BACKUP_ROOT"
#            sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "/$DB_BACKUP_ROOT"
#        fi
#    #else
#    #    echo "DEBUG :: ROOT_DIR true check - IF ELSESTEP"
#    #    echo " root dir flag is true"
#    #    if [ ! -d "$DB_BACKUP_ROOT" ]; then
#    #        sudo mkdir "$DB_BACKUP_ROOT"
#    #        sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "$DB_BACKUP_ROOT"
#    #    fi
#    #fi    
#else
    # if NULL then defaults to using / & updates the 'DB_BACKUP_PATH' variable
    #if [ -z "$DB_BACKUP_ROOT" ] ; then
    #    
    #    #echo "DEBUG :: ROOT DIR - IF ELSE STEP"
    #    DB_BACKUP_ROOT="/"
    #    SET_ROOT_DIR=false      # logic to resolve the leading Root '/' path issue
    #    echo
    #    echo "checking vars - Detected NULL value & set variable to: "$HOME""
    #    echo "checking vars - updating the value of 'DB_BACKUP_PATH' variable.."
    #    DB_BACKUP_PATH="/$DB_BACKUP_DIR"
    #
    #    # adds the variable value to the VARS file
    #    #echo 
    #    #echo "checking vars - updating file "$PLI_DB_VARS_FILE" variable 'DB_BACKUP_ROOT' value to: \$HOME"
    #    #sed -i.bak 's/DB_BACKUP_ROOT=\"\"/DB_BACKUP_ROOT=\"\$HOME\"/g' ~/$PLI_DB_VARS_FILE
    #fi
    #echo
    #echo "checking vars - var is set to "$DB_BACKUP_ROOT""
    #echo "checking vars - ....nothing else to do.. continuing to next variable";



# Checks if NOT NULL for the 'DB_BACKUP_DIR'variable
if [ ! -z "$DB_BACKUP_DIR" ] ; then
    #SET_ROOT_DIR=true
    #echo
    #echo "checking vars - var is not NULL"
    #echo "checking vars - var 'DB_BACKUP_DIR' value is: $DB_BACKUP_DIR"
    echo "checking DIR vars - apply default directory value..."

    DB_BACKUP_DIR="plinode_backups"

    # Checks if directory exists & creates if not + sets perms
    # following logic attempts to resolve the leading Root '/' path issue

    #if [ "$SET_ROOT_DIR" == "true" ]; then
    #    #echo "DEBUG :: BACKUP DIR - IF STEP"
    #    #echo " root dir flag is true"
    #    if [ ! -d "/$DB_BACKUP_DIR" ]; then
    #        echo -e "${RED} SETTING FOLDER PERMS  ${NC}"
    #        sudo mkdir "$DB_BACKUP_DIR"
    #        sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "/$DB_BACKUP_DIR"
    #        sudo chmod g+rw "/$DB_BACKUP_DIR";
    #    fi
    #else
    #    #echo "DEBUG :: BACKUP DIR - IF ELSE STEP"
    #    #echo " root dir flag is false"
        if [ ! -d "/$DB_BACKUP_DIR" ]; then
            echo -e "${GREEN} SETTING FOLDER PERMS  ${NC}"
            echo "checking DIR vars - check directory exists & setting perms..."
            sudo mkdir "/$DB_BACKUP_DIR"
            sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "/$DB_BACKUP_DIR"
            sudo chmod g+rw "/$DB_BACKUP_DIR";
        fi
    #fi
else
    # If NULL then defaults to using 'plinode_backups' for 'DB_BACKUP_DIR' variable


    #echo
    echo "checking vars - Detected NULL - setting 'default'value.."
    DB_BACKUP_DIR="plinode_backups"
    #echo "checking vars - var 'DB_BACKUP_DIR' value is now: $DB_BACKUP_DIR"

    # adds the variable value to the VARS file
    #echo
    echo "checking vars - updating file "$PLI_DB_VARS_FILE" variable 'DB_BACKUP_DIR' to: "$DB_BACKUP_DIR""
    sed -i.bak 's/DB_BACKUP_DIR=\"\"/DB_BACKUP_DIR=\"'$DB_BACKUP_DIR'\"/g' ~/$PLI_DB_VARS_FILE
fi
    # Checks if directory exists & creates if not + sets perms
    
    #echo
    #if [ "$SET_ROOT_DIR" == "true" ]; then
    #echo "checking vars - creating directory: "/$DB_BACKUP_DIR""
    #    sudo mkdir "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
    #    #echo "sudo chown $USER_ID:$DB_BACKUP_GUSER -R "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR""
    #    sudo chown $USER_ID:$DB_BACKUP_GUSER -R "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
    #    #echo "sudo chmod g+w -R "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR""
    #    sudo chmod g+rw "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
    #    #sudo chmod o-rx -R "/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
    #    # Updates the 'DB_BACKUP_PATH' & 'DB_BACKUP_OBJ' variable
    #    DB_BACKUP_PATH="/$DB_BACKUP_ROOT/$DB_BACKUP_DIR"
    #    echo "checking vars - assigning 'DB_BACKUP_PATH' variable: "$DB_BACKUP_PATH""
    #else
    #e#cho "checking vars - creating directory: "$DB_BACKUP_DIR""
    #sudo mkdir "/$DB_BACKUP_DIR"
    #echo
    #echo "checking vars - assigning permissions for directory: "/$DB_BACKUP_DIR""

        if [ ! -d "/$DB_BACKUP_DIR" ]; then
            echo -e "${GREEN} SETTING FOLDER PERMS  ${NC}"
            echo "checking DIR vars - check directory exists & setting perms..."
            sudo mkdir "/$DB_BACKUP_DIR"
            sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "/$DB_BACKUP_DIR"
            sudo chmod g+rw "/$DB_BACKUP_DIR";
        fi
        
    # Updates the 'DB_BACKUP_PATH' & 'DB_BACKUP_OBJ' variable
    DB_BACKUP_PATH="/$DB_BACKUP_DIR"
    sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "/$DB_BACKUP_DIR"
    sudo chmod g+rw "/$DB_BACKUP_DIR"
    #echo "checking vars - assigning 'DB_BACKUP_PATH' variable: "$DB_BACKUP_PATH""
    #fi

    ###  Based on the above changes in values originally read form var file
    ###  we then update the other vars to reflect these changes so the whole
    ###  script execution reflects these updates

    DB_BACKUP_OBJ="$DB_BACKUP_PATH/$DB_BACKUP_FNAME"
    CONF_BACKUP_OBJ="$DB_BACKUP_PATH/$NODE_BACKUP_FNAME"
    #echo "checking vars - assigning 'DB_BACKUP_OBJ' variable: "$DB_BACKUP_OBJ""
    #echo "checking vars - assigning 'CONF_BACKUP_OBJ' variable: "$CONF_BACKUP_OBJ""
    
    #echo
    #echo "checking vars - exiting directory check & continuing..."
    #sleep 2s

#echo
echo "checking vars - your configured node backup PATH is: $DB_BACKUP_PATH"
sleep 2s

}




FUNC_DB_PRE_CHECKS(){
    # check that necessary user / groups are in place 
    
    #check DB_BACKUP_FUSER values
    if [ -z "$DB_BACKUP_FUSER" ]; then
        export DB_BACKUP_FUSER="$USER_ID"
        #echo
        #echo "pre-check vars - Detected NULL for 'DB_BACKUP_FUSER' - we set the variable to: "$USER_ID""
    
        # adds the variable value to the VARS file
        #echo
        echo ".pre-check vars - updating file "$PLI_DB_VARS_FILE" variable 'DB_BACKUP_FUSER' to: $USER_ID"
        sed -i.bak 's/DB_BACKUP_FUSER=\"\"/DB_BACKUP_FUSER=\"'$USER_ID'\"/g' ~/$PLI_DB_VARS_FILE
    fi
    
    # check shared group '$DB_BACKUP_GUSER' exists & set permissions
    #if [ -z "$DB_BACKUP_GUSER" ] && [ ! $(getent group nodebackup) ]; then
        #echo
        echo "pre-check vars - variable 'DB_BACKUP_GUSER is: NULL && 'default' does not exist"
        echo "pre-check vars - creating group 'nodebackup'"
        sudo groupadd nodebackup
    
        # adds the variable value to the VARS file
        #echo
        echo "pre-check vars - updating file "$PLI_DB_VARS_FILE" variable DB_BACKUP_GUSER to: nodebackup"
        sed -i.bak 's/DB_BACKUP_GUSER=\"\"/DB_BACKUP_GUSER=\"nodebackup\"/g' ~/$PLI_DB_VARS_FILE
        #export DB_BACKUP_GUSER="nodebackup"
        DB_BACKUP_GUSER="nodebackup"
    
    #elif [ ! -z "$DB_BACKUP_GUSER" ] && [ ! $(getent group $DB_BACKUP_GUSER) ]; then
    #    echo
    #    echo "pre-check vars - variable 'DB_BACKUP_GUSER is: NOT NULL && does not exist"
    #    echo
    #    echo "pre-check vars - creating group "$DB_BACKUP_GUSER""
    #    sudo groupadd $DB_BACKUP_GUSER
    #    echo "pre-check vars - updating file "$PLI_DB_VARS_FILE" variable DB_BACKUP_GUSER to: nodebackup"
    #    sed -i.bak 's/DB_BACKUP_GUSER=\"\"/DB_BACKUP_GUSER=\"$DB_BACKUP_GUSER\"/g' ~/$PLI_DB_VARS_FILE
    #fi
    
    
    
    # add users to the group
    
    #echo
    echo "pre-check vars - checking if gdrive user exits"
    if [ ! -z "$GD_FUSER" ]; then
        #echo
        echo "pre-check vars - setting group members for backups - with gdrive"
        DB_GUSER_MEMBER=(postgres $USER_ID $GD_FUSER)
        #echo "${DB_GUSER_MEMBER[@]}"
    #elif [ -z "$GD_FUSER" ] && [ ! $(getent passwd gdbackup) ]; then
    else
        GD_ENABLED=false
        #echo
        echo "pre-check vars - setting group members for backups - without gdrive"
        DB_GUSER_MEMBER=(postgres $USER_ID)
        #echo "${DB_GUSER_MEMBER[@]}"
    fi
    
    #echo
    #echo
    echo "pre-check vars - assiging user-group permissions.."
    for _user in "${DB_GUSER_MEMBER[@]}"
    do
        hash $_user &> /dev/null
        echo "...adding user "$_user" to group "$DB_BACKUP_GUSER""
        sudo usermod -aG "$DB_BACKUP_GUSER" "$_user"
    done 
    
    sleep 2s
}







FUNC_CONF_BACKUP_LOCAL(){

    FUNC_DB_VARS
    FUNC_DB_PRE_CHECKS  # order is specific as pre checks for user/groups which are assigned to dirs 
    FUNC_CHECK_DIRS

    #echo
    echo "local backup - running tar backup process for configuration files"
    tar -cvpzf $CONF_BACKUP_OBJ ~/plinode* > /dev/null 2>&1
    #~/pli_init* ~/plugin-deployment/.env*
    #error_exit;

    #sleep 2s
    FUNC_CONF_BACKUP_ENC

    if [ "$_OPTION" == "-full" ]; then
        FUNC_DB_BACKUP_LOCAL
    fi


}




FUNC_DB_BACKUP_LOCAL(){


    if [ "$_OPTION" == "-db" ]; then
        FUNC_DB_VARS
        FUNC_DB_PRE_CHECKS
        FUNC_CHECK_DIRS
    fi

    #echo "$SET_ROOT_DIR"
    # checks if the '.pgpass' credentials file exists - if not creates in home folder & copies to dest folder
    # & sets perms
    #echo "$DB_BACKUP_PATH"
    #sleep 2s
    echo "local backup - checking pgpass file exists - create if necessary"
    if [ ! -e ~/.pgpass ]; then
    #clear
cat <<EOF > ~/.pgpass
Localhost:5432:$DB_NAME:postgres:$DB_PWD_NEW
EOF
    fi

    #echo
    echo "local backup - setting pgpass file perms"
    #if [ "$SET_ROOT_DIR" == "true" ]; then
    #    cp -p ~/.pgpass /$DB_BACKUP_PATH/.pgpass
    #    sudo chmod 600 /$DB_BACKUP_PATH/.pgpass
    #    sudo chown postgres:postgres /$DB_BACKUP_PATH/.pgpass
    #else
        cp -p ~/.pgpass $DB_BACKUP_PATH/.pgpass
        sudo chown postgres:postgres $DB_BACKUP_PATH/.pgpass
        sudo chmod 600 $DB_BACKUP_PATH/.pgpass
    #fi
    
    #sleep 1s
    #echo
    echo "local backup - running pgdump backup process"
    # switch to 'postgres' user and run command to create inital sql dump file
    sudo su postgres -c "export PGPASSFILE="$DB_BACKUP_PATH/.pgpass"; pg_dump -c -w -U postgres $DB_NAME | gzip > $DB_BACKUP_OBJ"
    #error_exit;
    
    #echo
    echo "local backup - successfully created unencrypted compressed gz file:  "$DB_BACKUP_OBJ""
    sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER $DB_BACKUP_OBJ
    
    # Calls the file encryption 
    FUNC_DB_BACKUP_ENC;
    
    
    # check menu selection & that remote backup software configured
    # GD_ENABLED set in FUNC_DB_PRE_CHECKS
    #echo "$GD_ENABLED"
    if [ "$_OPTION" == "-full" ] && [ "$GD_ENABLED" == "true" ]; then
        FUNC_DB_BACKUP_REMOTE
    fi

}




FUNC_DB_BACKUP_ENC(){

    # runs GnuPG or gpg to encrypt the sql dump file - uses main keystore password as secret
    # outputs file to new folder ready for upload

    if [ -e $DB_BACKUP_OBJ ]; then
        sudo gpg --yes --batch --passphrase=$PASS_KEYSTORE -o $ENC_PATH/$ENC_FNAME -c $DB_BACKUP_OBJ
        error_exit;
        #echo
        echo "local backup - successfully created encrypted gpg file:  "$ENC_FNAME""
        sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER $ENC_PATH/$ENC_FNAME
        #echo
        echo "local backup - securely erased unencrypted compressed gz file:  "$DB_BACKUP_OBJ""
        shred -uz -n 1 $DB_BACKUP_OBJ
    fi
}




FUNC_CONF_BACKUP_ENC(){

    if [ -e $CONF_BACKUP_OBJ ]; then
        sudo gpg --yes --batch --passphrase=$PASS_KEYSTORE -o $ENC_PATH/$ENC_CONFNAME -c $CONF_BACKUP_OBJ
        error_exit;
        #echo
        echo "local backup - successfully created file:  "$ENC_CONFNAME""
        sudo chown $DB_BACKUP_FUSER:$DB_BACKUP_GUSER $ENC_PATH/$ENC_CONFNAME
        #echo
        echo "local backup - securely erase unencrypted file:  "$CONF_BACKUP_OBJ""
        shred -uz -n 1 $CONF_BACKUP_OBJ
    fi
}


FUNC_DB_BACKUP_REMOTE(){

    if [ "$_OPTION" == "-remote" ]; then
        FUNC_DB_VARS
    fi

    # add check that gupload is installed!
    # switches to gupload user to run cmd to upload encrypted file to your google drive - skips existing files

    # add check for user account & installation

    sudo su gdbackup -c "cd ~/; .google-drive-upload/bin/gupload -q -d /$DB_BACKUP_PATH/*.gpg -C $(hostname -f) --hide"
    error_exit;
}


error_exit(){
    if [ $? != 0 ]; then
        #echo
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
        *)
                #clear
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
                echo 
                echo 
esac
