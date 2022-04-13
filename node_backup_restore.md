# Performing Backup & Restore operations on your Plugin $PLI node

This document aims to provide guidance on the usage of the scripts associated with performing manual backup & restore operations.

_NOTE: There is no **TL:DR** section on this topic given the significance of operations being performed so please take the time to read the documentention_

This particular document assumes that you already have a local clone of the repo on your node.

## Performing a BACKUP

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
    - exported keys json files
    
---

## Performing a RESTORE


### In-Place RESTORE


### Full RESTORE 
