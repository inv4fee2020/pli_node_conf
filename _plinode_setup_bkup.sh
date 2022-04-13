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
        clear
        echo
        echo
        echo -e "${RED} #### ERROR: No VARIABLES file found. ####${NC}"
        echo
        echo -e "${RED} ..creating local vars file '$HOME/$PLI_DB_VARS_FILE' ${NC}"
        cp -n sample_bkup.vars ~/$PLI_DB_VARS_FILE
        chmod 600 ~/$PLI_DB_VARS_FILE
    fi
    source ~/$PLI_DB_VARS_FILE
}


# create folders


FUNC_CHECK_DIRS(){


    DB_BACKUP_DIR="plinode_backups"

    # Checks if NOT NULL for the 'DB_BACKUP_DIR'variable
    #if [ ! -z "$DB_BACKUP_DIR" ] ; then
    #SET_ROOT_DIR=true
    #echo
    #echo "checking vars - var is not NULL"
    #echo "checking vars - var 'DB_BACKUP_DIR' value is: $DB_BACKUP_DIR"
    #echo "checking vars - check directory exists & create if NOT..."


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
        #echo "DEBUG :: BACKUP DIR - IF ELSE STEP"
        #echo " root dir flag is false"
        if [ ! -d "/$DB_BACKUP_DIR" ]; then
            echo -e "${RED} SETTING FOLDER PERMS  ${NC}"
            sudo mkdir "/$DB_BACKUP_DIR"
            #sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "/$DB_BACKUP_DIR"
            #sudo chmod g+rw "/$DB_BACKUP_DIR";
        fi
    #fi
    #else
    # If NULL then defaults to using 'plinode_backups' for 'DB_BACKUP_DIR' variable
    #echo
    #echo "checking vars - Detected NULL - setting 'default' value.."
    #export DB_BACKUP_DIR="plinode_backups"
    #echo "checking vars - var 'DB_BACKUP_DIR' value is now: $DB_BACKUP_DIR"

    # adds the variable value to the VARS file
    #echo
    echo "checking vars - updating file "$PLI_DB_VARS_FILE" variable 'DB_BACKUP_DIR' to: "$DB_BACKUP_DIR""
    sed -i.bak 's/DB_BACKUP_DIR=\"\"/DB_BACKUP_DIR=\"'$DB_BACKUP_DIR'\"/g' ~/$PLI_DB_VARS_FILE
    #fi
    # Checks if directory exists & creates if not + sets perms
    
    #echo "checking vars - creating directory: "$DB_BACKUP_DIR""
    #sudo mkdir "/$DB_BACKUP_DIR"
    #echo
    echo "checking vars - assigning permissions for directory: "/$DB_BACKUP_DIR""
    sudo chown $USER_ID\:$DB_BACKUP_GUSER -R "/$DB_BACKUP_DIR"
    sudo chmod g+rw "/$DB_BACKUP_DIR"
        
    # Updates the 'DB_BACKUP_PATH' & 'DB_BACKUP_OBJ' variable
    echo "checking vars - assigning 'DB_BACKUP_PATH' variable: "$DB_BACKUP_PATH""
    DB_BACKUP_PATH="/$DB_BACKUP_DIR"
    

}




FUNC_DB_PRE_CHECKS(){
# check that necessary user / groups are in place 

#check DB_BACKUP_FUSER values
if [ -z "$DB_BACKUP_FUSER" ]; then
    export DB_BACKUP_FUSER="$USER_ID"
    echo
    echo "pre-check vars - Detected NULL for 'DB_BACKUP_FUSER' - we set the variable to: "$USER_ID""

    # adds the variable value to the VARS file
    echo
    echo ".pre-check vars - updating file "$PLI_DB_VARS_FILE" variable 'DB_BACKUP_FUSER' to: $USER_ID"
    sed -i.bak 's/DB_BACKUP_FUSER=\"\"/DB_BACKUP_FUSER=\"'$USER_ID'\"/g' ~/$PLI_DB_VARS_FILE
fi

# check shared group '$DB_BACKUP_GUSER' exists & set permissions
if [ -z "$DB_BACKUP_GUSER" ] && [ ! $(getent group nodebackup) ]; then
    echo
    echo "pre-check vars - variable 'DB_BACKUP_GUSER is: NULL && 'default' does not exist"
    echo "pre-check vars - creating group 'nodebackup'"
    sudo groupadd nodebackup

    # adds the variable value to the VARS file
    echo
    echo "pre-check vars - updating file "$PLI_DB_VARS_FILE" variable DB_BACKUP_GUSER to: nodebackup"
    sed -i.bak 's/DB_BACKUP_GUSER=\"\"/DB_BACKUP_GUSER=\"nodebackup\"/g' ~/$PLI_DB_VARS_FILE
    DB_BACKUP_GUSER="nodebackup"

elif [ ! -z "$DB_BACKUP_GUSER" ] && [ ! $(getent group $DB_BACKUP_GUSER) ]; then
    echo
    echo "pre-check vars - variable 'DB_BACKUP_GUSER is: NOT NULL && does not exist"
    echo
    echo "pre-check vars - creating group "$DB_BACKUP_GUSER""
    sudo groupadd $DB_BACKUP_GUSER
    echo "pre-check vars - updating file "$PLI_DB_VARS_FILE" variable DB_BACKUP_GUSER to: nodebackup"
    sed -i.bak 's/DB_BACKUP_GUSER=\"\"/DB_BACKUP_GUSER=\"$DB_BACKUP_GUSER\"/g' ~/$PLI_DB_VARS_FILE
fi



# add users to the group

echo
echo "pre-check vars - checking if gdrive user exits"
if [ ! -z "$GD_FUSER" ]; then
    echo
    echo "pre-check vars - setting group members for backups - with gdrive"
    DB_GUSER_MEMBER=(postgres $USER_ID $GD_FUSER)
else
    GD_ENABLED=false
    echo
    echo "pre-check vars - setting group members for backups - without gdrive"
    DB_GUSER_MEMBER=(postgres $USER_ID)
    echo "${DB_GUSER_MEMBER[@]}"
fi

echo
echo
echo "pre-check vars - assiging user-group permissions.."
for _user in "${DB_GUSER_MEMBER[@]}"
do
    hash $_user &> /dev/null
    echo "...adding user "$_user" to group "$DB_BACKUP_GUSER""
    sudo usermod -aG "$DB_BACKUP_GUSER" "$_user"
done 

sleep 1s
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



FUNC_DB_VARS
FUNC_DB_PRE_CHECKS
FUNC_CHECK_DIRS







#case "$1" in
#        -full)
#                _OPTION="-full"
#                FUNC_SETUP_FULL
#                ;;
#        -local)
#                _OPTION="-local"
#                FUNC_SETUP_LOCAL
#                ;;
#        -remote)
#                _OPTION="-remote"
#                FUNC_SETUP_REMOTE
#                ;;
#        *)
#                clear
#                echo 
#                echo 
#                echo -e "${GREEN}Usage: $0 {function}${NC}"
#                echo 
#                echo -e "${GREEN}where {function} is one of the following;${NC}"
#                echo 
#                echo -e "${GREEN}      -full      ==  Configures system for both local & remote backup of config & DB files${NC}"
#                echo -e "${GREEN}      -local     ==  Configures system for local backup of config & DB files${NC}"
#                echo -e "${GREEN}      -remote    ==  Configures the system for backup to google drive of config & DB files${NC}"
#                echo
#                echo 
#                echo 
#esac
