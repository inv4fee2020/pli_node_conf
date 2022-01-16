# pli_node_conf
Misc. scripts for GoPlugin $PLI node setup using the SCRIPT METHOD.

> **NOTE: All values used in this code are for test purposes only & deployed to a test environment that is regularly deleted.**

>> **NOTE: Please ensure that you clone/fork and update with your own values as necessary.**

---

# TL:DR

clone the repo to your local '$HOME' folder **Preferably as a normal user & _not as root_**

        cd $HOME
        git clone https://github.com/inv4fee2020/pli_node_conf.git
        cd pli_node_conf
        chmod +x {base_sys_setup.sh,pli_node_scripts.sh,reset_pli.sh}
        cp sample.vars ~/plinode_$(hostname -f).vars && chmod 600 ~/plinode_$(hostname -f).vars
        nano ~/plinode_$(hostname -f).vars

Update the the minimum variables (as per VARIABLES section below) 

Run the main script to do a full node deployment

        ./pli_node_scripts.sh fullnode

& have a working node in approx 15mins ready for you to perform your REMIX contract & jobs config steps.



---
## VARIABLES file

A sample vars file is included 'sample.vars'.

This should be copied to your user $HOME folder using the following command;

>>>     cp sample.vars ~/"plinode_$(hostname -f).vars"

The scripts check that the local node variables file exists. If not then the code prompts the user and exists.
By using a dedicated variables file, any updates to the main script should not involve any changes to the node specific settings.

---

The following VARIABLES should be updated at a minimum for your individual implementation;

| VARIABLE |  NOTE |
|----------|-------|
|API_EMAIL="user123@gmail.com"||
|API_PASS="passW0rd123"|Must be 8 - 50 characters & NO special characters. (error creating api initializer)|
|PASS_KEYSTORE="Som3$tr*nGp4$$w0Rd"| Min. 12 characters, 3 lower, 3 upper, 3 numbers, 3 symbols & no more than 3 identical consecutive characters|
|DB_PWD_NEW="testdbpwd1234"|This is your new secure Postgres DB password & NO special characters|
|PLI_SSH_NEW_PORT="6222"| Change to suit your preference - should be a single value in the high range above 1025 & below 65535 e.g. 34022|

You can reveiw the 'sample.vars' file for the full list of VARIABLES.




---
---
## pli_node_scripts.sh

This script performs file manipulations & executes the various plugin bash scripts in order 
to successfully deploy the node. 

The scripts has 2 main functions, one of which must be passed to run the scripts

>>>     fullnode
>>>     initiators

### Function: fullnode

As the name suggest, this executes all code to provision a full working node ready for the contract & jobs creation on remix.
This function calls the 'initiator' function as part of executing all code.


### Function: initiator
This function performs just the external initiator section and skips the main node deployment. 
The key aspect to this function is the file manipulation to extract the access secrets/tokens and complete the registration process vastly reducing the chances of any errors.



**_NOTE: The script uses a base install folder is your linux users $HOME folder - which is now set as a VARIABLE._**

The script performs the following actions;

- Updates Postgres DB password 'sed' find/replace on BASH_FILE1
- Removes existing Golang install as part of pre-requisite for BASH_FILE1
- Updates BASH_FILE2 to use new '.env' files & Postgres password
- Updates BASH_FILE2 with TLS certificate files & TLS Port
- Creates local certificate authority & TLS certificate for use with local job server
- Updates BASH_FILE2 with EXTERNAL_INITIATORS parameter
- Checks for the Golang path & updates bash profile as necessary
- Initialises the BASH_FILE2 PM2 service & sets PM2 to auto start on boot
- External Initiators install & setup
- Performs authentication the plugin module & generates the initiator keys & output to file
- Manipulates the stored keys file & transfers to VARIABLES
- Auto generates the BASH_FILE3 file required to run the Initiator process
- Initialises the BASH_FILE3 PM2 service & updates PM2 to auto start on boot

---
---


## reset_pli.sh

As the name suggests this script does a full reset of you local Plugin installation.

User account deletion: The script does _NOT_ delete any other user or system accounts beyond that of _'postgres'_.

Basic function is to;

- stop & delete all PM2 processes
- stop all postgress services
- uninstall all postgres related components
- delete all postgres related system folders
- remove the postgres user & group
- delete all plugin installaton folders under the users $HOME folder


---
---


## base_sys_setup.sh (__Optional__)

You can reveiw the 'sample.vars' file for the full list of VARIABLES.

This script performs os level commands as follows;

- Apply ubuntu updates
- Install misc. services & apps e.g. UFW, Curl, Git, locate 
- New Local Admin user & group (Choice of interactive user input OR hardcode in VARS definition)
- SSH keys for the above 
- Applies UFW firewall minimum configuration & starts/enables service
- Modifies UFW firewall logging to use only the ufw.log file
- Modify SSH service to use alternate service port, update UFW & restart SSH


---
---


## Testing

The scripts have been developed on ubuntu 20.x linux distros deployed within both a vmware esxi environment & racknerd VPS.

Full deployment of the base node & external initiators was recorded at 15mins on racknerd with no user interaction. 