# Performing Backup & Restore operations on your Plugin $PLI node

This document aims to provide guidance on the usage of the scripts associated with performing manual backup & restore operations.

_NOTE: There is no **TL:DR** section on this topic given the significance of operations being performed so please take the time to read the documentation_

This particular document assumes that you already have a local clone of the repo on your node.

## Performing a BACKUP

**IMPORTANT ::** _Backups are stored locally on your VPS host. It is YOUR responsibility to ensure these files are copied to another location off the local node so that you can recover the node in the event of disk corruption / failure._

### Usage syntax

A brief explanation of the function syntax 

        Usage: ./_plinode_backup.sh {function}

        where {function} is one of the following;

              -full      ==  performs a local backup of both config & DB files only
              -conf      ==  performs a local backup of config files only
              -db        ==  performs a local backup of DB files only


The following commands will perform a **FULL** backup

    cd ~/pli_node_conf && ./_plinode_backup.sh -full


The following commands will perform a **CONFIG files** only backup

    cd ~/pli_node_conf && ./_plinode_backup.sh -conf


The following commands will perform a **DATABASE** only backup 

    cd ~/pli_node_conf && ./_plinode_backup.sh -db

---

### What files are backed up?

 - Conf files;
    All files in you $HOME folder with the _'plinode'_ prefix are selected for backup. This covers the following as an example;
    - node & backup vars files
    - exported node recovery keys json files
    
---

## Performing a RESTORE

There are two approaches to the restore operation as set out below.

### In-Place RESTORE

An 'in-place' restore is where you need to revert the node to a previous state, this could be either just the conf files or the database files or indeed both.  

This is not a very involved operation with minimal steps as follows;

  - run the restore script as follows;
    
        ./_plinode_restore.sh

    you will then be presented with the scenario check message where you confirm which approach you wish to execute;

        #########################################################################
        #########################################################################
        ##
        ##      RESTORE SCENARIO CONFIRMATION...
        ##
        ##
        ##  A Full Restore is ONLY where you have moved backup files to a FRESH / NEW VPS host
        ##  this includes where you have reset your previous VPS installation to start again..
        ##

        Are you performing a Full Restore to BLANK / NEW VPS ? (Y/n)

  - As this is an 'in-place' restore, we simply respond no
    There is also a timer set on this input which defaults to no and presents the following message; before continuing to list the available files for restore.

        ....timed out waiting for user response - proceeding as standard in-place restore to existing system...

  - Now to selecting the type & date-time stamp backup file to restore. You should be presented with a list of files similar to the following;
    
    **NOTE ::**_The list of files that you see will be dependent on how many backups you have performed._

>                      Showing last 8 backup files.
>                      Select the number for the file you wish to restore
>
>            1) /plinode_backups/plitest_conf_vars_2022_04_12_22_43.tar.gz.gpg	       6) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_25.sql.gz.gpg
>            2) /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg	       7) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_29.sql.gz.gpg
>            3) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_43.sql.gz.gpg  8) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql.gz.gpg
>            4) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_54.sql.gz.gpg  9) QUIT
>            5) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_21.sql.gz.gpg
>            #?



### Full RESTORE 

The full restore approach targets the following scenarios;

  -  where a full rebuilt of your VPS host is necess