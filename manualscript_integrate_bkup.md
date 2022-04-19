alpha stage development

# Enabling backup script for legacy manual deployment

This document and the steps therein are aimed at operators that have deployed their nodes using the legacy manual script deployment method. 

The legacy manual script deployment method is defined as having created & edited the following files; as part of the medium articles & subsequent community member tutorials that referenced these same articles.

   - apicredentials.txt
   - password.txt

#### Legacy medium articles

   - https://medium.com/@GoPlugin/setup-a-plugin-node-automated-way-using-shell-script-fbdec48a0dea

---

## How to integrate the automated scripts

In order to utilise the backup script so that you can quickly recover your node to either the same VPS or an entirely different VPS with another provider, you need to perform a number of steps which are set out below.

### Integration steps

   1. Clone down the scripts repositoty from github

            cd $HOME
            git clone https://github.com/inv4fee2020/pli_node_conf.git
            cd pli_node_conf
            chmod +x *.sh


   2. Create the new vars file for your node
   
            cd ~/pli_node_conf && cp sample.vars ~/"plinode_$(hostname -f)".vars
            chmod 600 ~/"plinode_$(hostname -f)".vars


   3. Update the new vars file with your nodes credentials

      This is the important piece. When updating the vars file, it is critically important that you maintain the accuracy of credentials otherwise when you come to restore the node, you may discover issues related to incorrect credentials

      The following credentials must be updated into the new vars file;

      - KeyStore Password _(sourced from the password.txt file)_
      - Postgres Password _(sourced from the_ _2\_nodeStartPM2.sh file)_


   4. Setup the backup folder & permissions
   
            cd ~/pli_node_conf &&  ./_plinode_setup_bkup.sh


   5. Perform a Full Backup of your node
   6. Validate your backup with a restore to a temporary test / sandbox VPS