#!/bin/bash


source ~/"plinode_$(hostname -f)".vars
source ~/"plinode_$(hostname -f)"_bkup.vars

node_backup_arr=()
BACKUP_FILE=$'\n' read -r -d '' -a node_backup_arr < <( find ~/node_backups/ -type f -name *.gpg | head -n 8 | sort )
node_backup_arr+=(quit)
echo ${node_backup_arr[@]}
node_backup_arr_len=${#node_backup_arr[@]}
echo $node_backup_arr_len

sleep 3
#for (( i = 0 ; i < $node_backup_arr_len ; i++))
#do
#  echo "File [$i]: ${node_backup_arr[$i]}"
#done


FUNC_RESTORE_DECRYPT(){
    #BACKUP_FILE="$IFS"
    RESTORE_FILE=""
    echo "Starting value of 'Restore File' var: $RESTORE_FILE"
    RESTORE_FILE=$(echo $BACKUP_FILE | sed 's/\.[^.]*$//')
    echo "Return new value of 'Restore File' var: $RESTORE_FILE"
    #echo $RESTORE_FILE
    gpg --batch --passphrase=$PASS_KEYSTORE -o $RESTORE_FILE --decrypt $BACKUP_FILE 

    if [[ "$BACKUP_FILE" =~ "$DB_NAME" ]]; then
        echo "matched 'contains' db name..."
        FUNC_RESTORE_DB
    else
        echo "else returned so must be file restore..."
        FUNC_RESTORE_CONF
    fi

    echo "if complete. existing..."
    FUNC_EXIT;

}

FUNC_RESTORE_DB(){
    echo "   DB RESTORE...."
    sudo su postgres -c "export PGPASSFILE="$DB_BACKUP_PATH/.pgpass"; gunzip -d $RESTORE_FILE | psql -U postgres -d $DB_NAME  > /dev/null 2>&1"
    
    # this fails as sudo home path is taken... required node_backups folder in / to reduce complexity
    sudo su postgres -c "export PGPASSFILE="~/node_backups/.pgpass"; gunzip -c ~/node_backups/racknerd-ac9ce7_plugin_mainnet_db_2022_04_03_23_06.sql.gz | psql -U postgres -d plugin_mainnet_db  > /dev/null 2>&1"


    shred -uz -n 1 /$RESTORE_FILE
    FUNC_EXIT;
}


FUNC_RESTORE_CONF(){
    echo "   CONFIG FILES RESTORE...."

    echo $RESTORE_FILE
    tar -xvpzf $RESTORE_FILE
    #shred -uz -n 1 /$RESTORE_FILE
    FUNC_EXIT;
}



FUNC_EXIT(){
	exit 0
	}


FUNC_EXIT_ERROR(){
	exit 1
	}
  

echo
echo "          Showing last 8 backup files. "
echo "          Select the number for the file you wish to restore "
echo

select _file in "${node_backup_arr[@]}"
do
    case $_file in
        ${node_backup_arr[0]}) echo "Restoring file: ${node_backup_arr[0]}" ; BACKUP_FILE="${node_backup_arr[0]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[1]}) echo "Restoring file: ${node_backup_arr[1]}" ; BACKUP_FILE="${node_backup_arr[1]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[2]}) echo "Restoring file: ${node_backup_arr[2]}" ; BACKUP_FILE="${node_backup_arr[2]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[3]}) echo "Restoring file: ${node_backup_arr[3]}" ; BACKUP_FILE="${node_backup_arr[3]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[4]}) echo "Restoring file: ${node_backup_arr[4]}" ; BACKUP_FILE="${node_backup_arr[4]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[5]}) echo "Restoring file: ${node_backup_arr[5]}" ; BACKUP_FILE="${node_backup_arr[5]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[6]}) echo "Restoring file: ${node_backup_arr[6]}" ; BACKUP_FILE="${node_backup_arr[6]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[7]}) echo "Restoring file: ${node_backup_arr[7]}" ; BACKUP_FILE="${node_backup_arr[7]}"; FUNC_RESTORE_DECRYPT; break ;;
        ${node_backup_arr[8]}) echo "exiting now..." ; break ;;
        *) echo invalid option;;
    esac
done


