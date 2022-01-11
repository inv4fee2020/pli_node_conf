# pli_node_conf
Misc. scripts for GoPlugin $PLI node setup using the SCRIPT METHOD.

> **NOTE: All values used in this code are for test purposes only & deployed to a test environment that is regularly deleted.**

>> **NOTE: Please ensure that you fork and update with your own values as necessary.**



## base_sys_setup.sh

This script performs os level commands as follows;
1. Apply ubuntu updates
2. Install misc. services & apps e.g. UFW, Curl, Git, locate 
3. New Local Admin user & group
4. SSH keys for the above 
5. Applies UFW firewall minimum configuration & starts/enables service
6. Modifies UFW firewall logging to use only the ufw.log file
7. Modify SSH service to use alternate service port, update UFW & restart SSH

---
---
## pli_node_scripts.sh

This scripts performs file manipulations & executes the various plugin bash scripts in order 
to successfully deploy the node. 

The script uses a base install folder '/pli_node' which is hard coded throughout but easily changed 
with find/replace if necessary.

---
The following VARIABLES should be updated for your individual implementation;


| VARIABLE |  NOTE |
|----------|-------|
|PLI_BASE_DIR="pli_node"| base folder which holds all installs|
|PLI_DEPLOY_DIR="plugin-deployment"|created by the initial git clone|
|TLS_CERT_PATH="/$PLI_BASE_DIR/$PLI_DEPLOY_DIR/Plugin/tls"|full path for TLS cert generation|
|TLS_SVC_PORT="6689"|TLS/SSL port for node server|
|FILE_API=".env.apicred"||
|FILE_KEYSTORE=".env.password"||
|API_EMAIL="user123@gmail.com"||
|API_PASS="passW0rd123"|              #NOTE: Must be 8 - 50 characters. (error creating api initializer)|
|PASS_KEYSTORE="Som3$tr*nGp4$$w0Rd"| Min. 12 characters, 3 lower, 3 upper, 3 numbers, 3 symbols & no more than 3 identical consecutive characters|
|DB_PWD_FIND="'postgres'"|            #NOTE: Maintain the single quotes inorder to pass the VAR correctly as the system expects it..|
|DB_PWD_REPLACE="testdbpwd1234"||
|BASH_FILE1="1_prerequisite.bash"||
|BASH_FILE2="2_nodeStartPM2.sh"||
|BASH_FILE3="3_InitiatorStartPM2.sh"||


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