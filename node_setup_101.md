# 101 on setting up a Plugin $PLI node;

1. Logon as root to your new VPS


2. Create a new admin user account
-- Copy the below text into a local text editor e.g. notepad
-- Change 'my_new_user' & 'my_new_password' for your values and paste the code to the terminal
        
        sudo groupadd my_new_user
        sudo useradd -p $(openssl passwd -6 my_new_password) my_new_user -m -s /bin/bash -g my_new_user -G sudo

3. Now open a new terminal session to your VPS and logon with your new admin user account and complete the rest of the steps


4. Once logged on as your new admin user - run the following commands;

        sudo -l > /dev/null 2>&1
        sudo apt install -y git nano        
        cd $HOME
        git clone https://github.com/inv4fee2020/pli_node_conf.git
        cd pli_node_conf
        chmod +x *.sh
        cp -n sample.vars ~/plinode_$(hostname -f).vars && chmod 600 ~/plinode_$(hostname -f).vars
        nano ~/plinode_$(hostname -f).vars


5. Update the VARs file as necessary... Pay special attention to the notes on the password structure;
        https://github.com/inv4fee2020/pli_node_conf#variables-file


6. When you have updated all the variables, exit from nano and save your changes using

        ctrl+x
        y


7. Lets update the OS and install necessary packages & update the UFW firewall - run the following commands;

        ./base_sys_setup.sh -D


8. During the UFW portion of the above script, you will be prompted to to confirm (y/n) to proceed. Select 'Y' to continue. This will not disrupt your existing ssh session


9. At this point we are ready to go ahead and deploy the Plugin node - run the following commands;

        ./pli_node_scripts.sh fullnode


10. in about 12-15mins you should have a node running and ready to progress with the Remix steps

    > When connecting to your nodes plugin GUI as outlined in ['fund your node'](https://docs.goplugin.co/plugin-installations/fund-your-node), you must use *_'https://your_node_ip:6689'_* instead due to the configuration applied by the [main script](https://github.com/inv4fee2020/pli_node_conf#main-script-actions)


11. When you get to the [Job Setup](https://docs.goplugin.co/oracle/job-setup) on the main docs & have created your Oracle contract address. You can then run the following script to generate the necessary json blob to create the job on your local node;

        ./gen_node_testjob.sh

The script will input your Oracle contract address in any format e.g with a prefix of 'xdc' or '0x' and convert it as necessary to the correct format. It will then output the necessary json blob to the terminal for you to copy and paste. 

This ensures that all the values from the node deplpoyment are consistent throughout the process and reduces the likelihood of errors.