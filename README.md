# pli_node_conf
Misc. scripts for GoPlugin $PLI node setup


## base_sys_setup.sh

This script performs os level commands as follows;
1. Apply ubuntu updates
2. Install misc. services & apps e.g. UFW, Curl, Git, locate 
3. New Local Admin user & group
4. SSH keys for the above 
5. Applies UFW firewall minimum configuration & starts/enables service
6. Modifies UFW firewall logging to use only the ufw.log file
7. Modify SSH service to use alternate service port, update UFW & restart SSH


## pli_node_scripts.sh

This scripts performs file manipulations & executes the various plugin bash scripts in order 
to successfully deploy the node. 

The script uses a base install folder '/pli_node' which is hard coded throughout but easily changed 
with find/replace if necessary.

The following VARIABLES should be updated for your individual implementation;


| VARIABLE |  NOTE |
|----------|-------|
|FILE_API=".env.apicred"||
|FILE_KEYSTORE=".env.password"||
|API_EMAIL="user123@gmail.com"||
|API_PASS="passW0rd123"|              #NOTE: Must be 8 - 50 characters. (error creating api initializer)|
|PASS_KEYSTORE="Som3$tr*nGp4$$w0Rd"||
|DB_PWD_FIND="'postgres'"|            #NOTE: Maintain the single quotes inorder to pass the VAR correctly as the system expects it..|
|DB_PWD_REPLACE="testdbpwd1234"||
|BASH_FILE1="1_prerequisite.bash"||
|BASH_FILE2="2_nodeStartPM2.sh"||
|BASH_FILE3="3_InitiatorStartPM2.sh"||
