#101 on setting up a Plugin $PLI node;

1. Logon as root to your new VPS


2. Create a new admin user account
> -- Change 'my_new_user' & 'my_new_password' for your values and paste the code to the terminal
        sudo groupadd my_new_user
        sudo useradd -p $(openssl passwd -6 my_new_password) my_new_user -m -s /bin/bash -g my_new_user -G sudo

3. Now open a new terminal session to your VPS and logon with your new admin user account and complete the rest of the steps


4. Once logged on as your new admin user - run the following commands;

        cd $HOME
        git clone https://github.com/inv4fee2020/pli_node_conf.git
        cd pli_node_conf
        chmod +x {base_sys_setup.sh,pli_node_scripts.sh,reset_pli.sh,gen_node_testjob.sh}
        cp -n sample.vars ~/plinode_$(hostname -f).vars && chmod 600 ~/plinode_$(hostname -f).vars
        nano ~/plinode_$(hostname -f).vars
        ./base_sys_setup.sh --user


5. Update the VARs file as necessary... Pay special attention to the notes on the password structure;
        https://github.com/inv4fee2020/pli_node_conf#variables-file


6. When you have updated all the variables, exit from nano and save your changes using

        ctrl+x
        y


7. Lets update the OS and install necessary packages - run the following commands;

        ./base_sys_setup.sh -D


8. At this point we are ready to go ahead and deploy the Plugin node - run the following commands;

        ./pli_node_scripts.sh fullnode


9. in about 12-15mins you should have a node running and ready to progress with the Remix steps