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

The following details clarify what we are backing up, but as part of the process all files are compressed using gunzip and then gpg encrypted
#### Conf files;
All files in you $HOME folder with the _'plinode'_ prefix are selected for backup. This covers the following as an example;
    - node & backup vars files
    - exported node recovery keys json files

#### Database files;
Using the inbuild postgres database utility, we take a full backup of the plugin node database *_"plugin_mainnet_db"_*


#### File Encryption
As touched on above, all compressed backup files are gpg encrypted.  The process follows the same approach as the actual node installation whereby the _KEYSTORE PASSWORD_ is used to secure the backup files.  As this password is already securely stored in your password manager / key safe, it was the logical method to employ rather than creating another strong password to have to store & document.
    
---


## Performing a RESTORE

There are two approaches to the restore operation as set out below.

---
---
### In-Place RESTORE

An 'in-place' restore is where you need to revert the node to a previous state, this could be either just the conf files or the database files or indeed both.  

This is not a very involved operation with minimal steps as follows;

  1. run the restore script as follows;
    
            ./_plinode_restore.sh

  2. Now to selecting the type & date-time stamp backup file to restore. You should be presented with a list of files similar to the following;
    
    **NOTE ::** _The list of files that you see will be dependent on how many backups you have performed._
    


                      Showing last 8 backup files.
                      Select the number for the file you wish to restore

            1) /plinode_backups/plitest_conf_vars_2022_04_12_22_43.tar.gz.gpg	       6) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_25.sql.gz.gpg
            2) /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg	       7) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_29.sql.gz.gpg
            3) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_43.sql.gz.gpg  8) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql.gz.gpg
            4) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_54.sql.gz.gpg  9) QUIT
            5) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_21.sql.gz.gpg
            #?

    
   3. The code detects the file selection and calls the appropriate function to handle the file. 
   
      i.  If you choose a "conf" file then the script proceeds to restore the contents to the original location: $HOME
   
      ii. If you chose a "db" file you will then be presented with the scenario check message as follows; where you confirm which approach you wish to execute;

            ######################################################################################
            ######################################################################################
            ##
            ##      RESTORE SCENARIO CONFIRMATION...
            ##
            ##
            ##  A Full Restore is ONLY where you have moved backup files to a FRESH / NEW VPS host
            ##  this includes where you have reset your previous VPS installation to start again..
            ##

            Are you performing a Full Restore to BLANK / NEW VPS? - Please answer (Y)es or (N)o 

  4. As this is an 'in-place' restore, we simply respond no
     
     **NOTE ::** There is also a timer set on this input which presents the following message; before repeating to list the available files for restore.

            ....timed out waiting for user response - please select a file to restore...

  - At this point you either select the file to restore 


---
---
### Full RESTORE 

The full restore approach targets the following scenarios;

  1.  where a full rebuild of your current VPS host - using the "reset_pli.sh" script 
  2.  where a full rebuild of your current VPS host - using the control panel reset option of your VPS hosting portal
  3.  migration of your node to another VPS hosting platform

With scenario 1. the assumption is that there is no movement of any backup files are they have remained intact in their default location of "/plinode_backups".

With scenarios 2. & 3. the assumption is that you have copied the relevant backup files to the original path "/plinode_backups" on your now reset / new VPS host.

#### How to perform a full restore

  1. With the necessary files copied to the fresh VPS under folder "/plinode_backups", we need to set the necessary file permissions so that the main scripts can execute. Lets get into the correct folder to run the scripts;

            cd ~/pli_node_conf

  2. Lets now run the setup script;

            ./_plinode_setup_bkup.sh

  3. This will produce output to the terminal as it executes, the following is an example of what you can expect;

            nmadmin@plitest:~/pli_node_conf$ ./_plinode_setup_bkup.sh
            [sudo] password for nmadmin:
            pre-check vars - checking if gdrive user exits
            pre-check vars - setting group members for backups - without gdrive
            pre-check vars - assiging user-group permissions..
            checking vars - updating file plinode_plitest_bkup.vars variable 'DB_BACKUP_DIR' to: plinode_backups
            checking vars - assigning permissions for directory: /plinode_backups
            checking vars - assigning 'DB_BACKUP_PATH' variable: /plinode_backups
            nmadmin@plitest:~/pli_node_conf$

  4. Lets check the permissions on the "/plinode_backups" folder

            ll / | grep plinode

  5. We should see the folder permissions set like the following example;

            drwxrwxr-x   2 nmadmin nodebackup       4096 Apr 13 10:09 plinode_backups

  6. Now we progress to restore the "conf" files so that we have all our credentials and variables necessary for the re-install of the node software.
     During this step you will be prompted for your origianl _KEYSTORE PASSWORD_ so best to have it to hand ready for pasting into the terminal.

  7. Lets kick off the "conf" files restore by running the main restore script;
    
        ./_plinode_restore.sh

  8. You will then be presented with the scenario check message where you confirm which approach you wish to execute;

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

    
  9. As we are indeed performing a Full Restore, we proceed to confirm by inputting Y and press enter
     
     NOTE:: By confirming this input we are telling the script to run some extra code that will also  
