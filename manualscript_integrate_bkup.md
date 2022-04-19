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
   2. Create the new vars file for your node
   3. Setup the backup folder & permissions
   4. Perform a Full Backup of your node
   5. Validate your backup with a restore to a temporary test / sandbox VPS