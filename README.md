# pli_node_conf
Misc. scripts for GoPlugin $PLI node setup using the SCRIPT METHOD.

> **NOTE: All values used in this code are for test purposes only & deployed to a test environment that is regularly deleted.**

>> **NOTE: Please ensure that you clone/fork and update with your own values as necessary.**

---

---
## base_sys_setup.sh


The following VARIABLES should be updated at a minimum for your individual implementation;


| VARIABLE |  NOTE |
|----------|-------|
|PLI_SSH_NEW_PORT="6222"| Change to suit your preference - should be a single value in the high range above 1025 & below 65535 e.g. 34022|

You can reveiw the 'base_sys_setup' file for the full list of VARIABLES.

---

This script performs os level commands as follows;
1. Apply ubuntu updates
2. Install misc. services & apps e.g. UFW, Curl, Git, locate 
3. New Local Admin user & group (Choice of interactive user input OR hardcode in VARS definition)
4. SSH keys for the above 
5. Applies UFW firewall minimum configuration & starts/enables service
6. Modifies UFW firewall logging to use only the ufw.log file
7. Modify SSH service to use alternate service port, update UFW & restart SSH

---
---
## pli_node_scripts.sh

This scripts performs file manipulations & executes the various plugin bash scripts in order 
to successfully deploy the node. 

The script uses a base install folder '/pli_node' which is set as a VARIABLE.

---
The following VARIABLES should be updated at a minimum for your individual implementation;


| VARIABLE |  NOTE |
|----------|-------|
|FILE_KEYSTORE=".env.password"||
|API_EMAIL="user123@gmail.com"||
|API_PASS="passW0rd123"|Must be 8 - 50 characters. (error creating api initializer)|
|PASS_KEYSTORE="Som3$tr*nGp4$$w0Rd"| Min. 12 characters, 3 lower, 3 upper, 3 numbers, 3 symbols & no more than 3 identical consecutive characters|
|DB_PWD_REPLACE="testdbpwd1234"|This is your new secure Postgres DB password|

You can reveiw the 'pli_node_scripts' file for the full list of VARIABLES.

---

The script performs the following actions;
1. Updates Postgres DB password 'sed' find/replace on BASH_FILE1
2. Removes existing Golang install as part of pre-requisite for BASH_FILE1
3. Updates BASH_FILE2 to use new '.env' files & Postgres password
4. Updates BASH_FILE2 with TLS certificate files & TLS Port
5. Creates local certificate authority & TLS certificate for use with local job server
6. Updates BASH_FILE2 with EXTERNAL_INITIATORS parameter
7. Checks for the Golang path & updates bash profile as necessary
8. Initialises the BASH_FILE2 PM2 service & sets PM2 to auto start on boot

9. External Initiators install & setup
10. Performs authentication the plugin module & generates the initiator keys & output to file
11. Manipulates the stored keys file & transfers to VARIABLES
12. Auto generates the BASH_FILE3 file required to run the Initiator process
13. Initialises the BASH_FILE3 PM2 service & updates PM2 to auto start on boot

---
---


## reset_pli.sh

As the name suggests this script does a full reset of you local Plugin installation.

There are no variables passed to this script.

Basic function is to;
- stop & delete all PM2 processes
- stop all postgress services
- uninstall all postgres related components
- delete all postgres related system folders
- remove the postgres user & group
- delete all plugin installaton folders under the users $HOME folder