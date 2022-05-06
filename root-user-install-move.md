#  root user install move

### Accompanying video for visual aid.

[Youtube Playlist : Plugin ($PLI )Node - Root user move & legacy script migration](https://www.youtube.com/watch?v=jq9mDfvptGw&list=PL2_76-uvpc8zOFfuAIVaEI2YJr0JGlXPo)


## Install mkpasswd to generate the password hash

    apt install -y mkpasswd

> You may need to install using the 'whois' package depending on your VPS provider; If you get issues with the above, try the following;

    apt install -y whois


## Create a hash of your chosen password 'letmein123' is a test password - please ensure you update to be stronger and more random etc.

    mkpasswd -m sha256crypt letmein123

**With the password hashed - you can safely re-use this for copy & pasting to your other nodes**


## replace 'bhcadmin' with your user account that you wish to use & update the password hash with the output of your password hash !!  

**Replace _\_ADD\_YOUR\_PERSONAL\_PASSWORD\_HERE\__ with your password hash produced above..**

**NOTE: you must maintain the single quotes encasing the hash**


    export usergrp=bhcadmin
    sudo groupadd $usergrp
    sudo useradd -p '_ADD_YOUR_PERSONAL_PASSWORD_HERE_' $usergrp -m -s /bin/bash -g $usergrp -G sudo



## stop & delete all the PM2 processes

    pm2 stop all ; pm2 delete all; pm2 save 



## Copy over the necessary folders & reset permissions

**these can take a few mins!!**


    sudo cp -pR ~/plugin-deployment /home/$usergrp
    sudo chown $usergrp:$usergrp  -R  /home/$usergrp/plugin-deployment


    sudo cp -pR /root/work /home/$usergrp/
    sudo chown -R $usergrp:$usergrp /home/$usergrp/work


    sudo cp -pR ~/external-Initiator /home/$usergrp/plugin-deployment
    sudo chown $usergrp:$usergrp  -R  /home/$usergrp/plugin-deployment/external-Initiator


    sudo cp -pR ~/.tmp_profile /home/$usergrp/
    sudo chown $usergrp:$usergrp  /home/$usergrp/.tmp_profile



You may get an error here - ignore it!  We are guessing that the 'external-initiator' folder will be in one of the two locations, so we will try both. One will fail and throw an error but the other should succeed.

    sudo cp /root/work/bin/external-initiator /home/$usergrp/work/bin
    sudo cp /root/go/bin/external-initiator /home/$usergrp/work/bin
    sudo chown $usergrp:$usergrp  -R /home/$usergrp/work/bin



## copy export lines to /home/$usergrp/.profile

You can examine the contents of the file and where any lines are missing when compared to the below example, simply manually add them using the editor of your choice eg. `nano`

Example;

    export GOROOT=/usr/local/go
    export GOPATH=$HOME/work
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    export FEATURE_EXTERNAL_INITIATORS=true


Command to run;

    cat ~/.profile | grep export >> /home/$usergrp/.profile



## impersonate the new user account created above (same as logging into a new terminal session)

    sudo -i -u $usergrp
    cd ~/
    pwd

---

    cd ~/plugin-deployment
    source ~/.profile

---

    pm2 start 2_nodeStartPM2.sh
    sleep 3s
    pm2 status
    pm2 startup systemd

## after entering the systemd command you will see similiar output to the following

```
bhcadmin@plitest1:~/plugin-deployment$ pm2 startup systemd
[PM2] Init System found: systemd
[PM2] To setup the Startup Script, copy/paste the following command:
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u bhcadmin --hp /home/bhcadmin
bhcadmin@plitest1:~/plugin-deployment$
```


## Copy the list that starts with 'sudo env' and paste in onto the terminal

```
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u bhcadmin --hp /home/bhcadmin
```

## you should be prompted for the password of your user account and will then see similar output as follows;

```
bhcadmin@plitest1:~/plugin-deployment$ sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u bhcadmin --hp /home/bhcadmin
[sudo] password for bhcadmin:
[PM2] Init System found: systemd
Platform systemd
Template
[Unit]
Description=PM2 process manager
Documentation=https://pm2.keymetrics.io/
After=network.target

[Service]
Type=forking
User=bhcadmin
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/go/bin:/home/bhcadmin/work/bin:/usr/local/go/bin:/home/bhcadmin/work/bin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
Environment=PM2_HOME=/home/bhcadmin/.pm2
PIDFile=/home/bhcadmin/.pm2/pm2.pid
Restart=on-failure

ExecStart=/usr/lib/node_modules/pm2/bin/pm2 resurrect
ExecReload=/usr/lib/node_modules/pm2/bin/pm2 reload all
ExecStop=/usr/lib/node_modules/pm2/bin/pm2 kill

[Install]
WantedBy=multi-user.target

Target path
/etc/systemd/system/pm2-bhcadmin.service
Command list
[ 'systemctl enable pm2-bhcadmin' ]
[PM2] Writing init configuration in /etc/systemd/system/pm2-bhcadmin.service
[PM2] Making script booting at startup...
[PM2] [-] Executing: systemctl enable pm2-bhcadmin...
Created symlink /etc/systemd/system/multi-user.target.wants/pm2-bhcadmin.service → /etc/systemd/system/pm2-bhcadmin.service.
[PM2] [v] Command successfully executed.
+---------------------------------------+
[PM2] Freeze a process list on reboot via:
$ pm2 save

[PM2] Remove init script via:
$ pm2 unstartup systemd
bhcadmin@plitest1:~/plugin-deployment$
```


## Now we continue to start the external-initiator

```
pm2 start 3_initiatorStartPM2.sh
pm2 save
sleep 3s
pm2 status
```


## all the processes should be running as follows;

```
bhcadmin@plitest1:~/plugin-deployment$ pm2 list
┌─────┬────────────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id  │ name                   │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├─────┼────────────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0   │ 2_nodeStartPM2         │ default     │ N/A     │ fork    │ 27625    │ 4m     │ 2    │ online    │ 0%       │ 3.2mb    │ bhcadmin │ disabled │
│ 1   │ 3_initiatorStartPM2    │ default     │ N/A     │ fork    │ 27788    │ 23s    │ 0    │ online    │ 0%       │ 3.2mb    │ bhcadmin │ disabled │
└─────┴────────────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘

```

**pay special attention to the restarts column indicated by '↺' - if this value is increasing constantly then you have an issue that should be resolved before proceeding**


# repeat the following command to watch for changes in the restart column;
```
pm2 list
```


**lets try a reboot to make sure that the services restart automatically !!**

## You have completed the move from root user install to a new admin user based install
## next step is the modular script integration!


**We will come back to cleaning up the installation folders under the 'root' user later - once we have a backup**