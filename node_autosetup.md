# Setting up a Plugin $PLI node - Automated Script Method;

1. Logon as root to your new VPS
   
   i. Due to the various experiences across different VPS hosting platforms, lets update the system & add in base packages before proceeding;

         sudo apt update -y && sudo apt upgrade -y && sudo apt install -y git nano curl && sudo apt autoremove -y


2. Create a new admin user account
-- Copy the below text into a local text editor on your pc/laptop e.g. notepad
-- Change '**my_new_user**' & '**my_new_password**' for your values and paste the code to the terminal
        
        sudo groupadd my_new_user
        sudo useradd -p $(openssl passwd -6 my_new_password) my_new_user -m -s /bin/bash -g my_new_user -G sudo

3. Now open a new terminal session to your VPS and logon with your new admin user account and complete the rest of the steps.


4. Once logged on as your new admin user - run the following commands;

   i.  Now we clone down the install scripts repository

        cd $HOME
        git clone https://github.com/inv4fee2020/pli_node_conf.git
        cd pli_node_conf
        chmod +x *.sh
  

5. At this point we are ready to go ahead and deploy the Plugin node - run the following commands;

        ./pli_node_scripts.sh fullnode


6. In about 12-15mins you should have a node running and ready to progress with the Remix steps.

7. **IMPORTANT** Be sure to record the auto created credentials that are output to the screen.  These are also writted to the node vars file in the $HOME folder

|<img src="https://github.com/inv4fee2020/docs_pli/blob/main/images/plinode_autosetup_creds_2022-03-29.png" width=70% height=70%>|
|---|  


***
***


> When connecting to your nodes plugin GUI as outlined in ['fund your node'](https://docs.goplugin.co/plugin-installations/fund-your-node), you must use *_'https://your_node_ip:6689'_* instead due to the configuration applied by the [main script](https://github.com/inv4fee2020/pli_node_conf#main-script-actions)

***

8. When you get to the [Job Setup](https://docs.goplugin.co/oracle/job-setup) section on the main docs & have successfully created your Oracle contract address. You can then run the following script to generate the necessary json blob required to create the test job on your local node;

        ./gen_node_testjob.sh


|<img src="https://github.com/inv4fee2020/docs_pli/blob/main/images/pli_node_testjob_jsonblob%202022-01-27%20at%2010.05.42.png" width=70% height=70%>|
|---|    
    
The script will prompt you to input your Oracle contract address (in any format) e.g with a prefix of 'xdc' or '0x' and convert it as necessary to the correct format. It will then output the necessary json blob to the terminal screen for you to copy and paste to the jobs section of your node. 

This ensures that all the values from the node deployment are consistent throughout the process and reduces the likelihood of errors.

|<img src="https://github.com/inv4fee2020/docs_pli/blob/main/images/pli_node_ui_new_job%202022-01-27%20at%2009.47.41.png" width=70% height=70%>|
|---|