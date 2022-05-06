# Move modular script to manual script deployment for upgrade/migration testing 

'''
pm2 stop all ; pm2 delete all ; pm2 save

cd ~/plugin-deployment

mv external-Initiator/ ../

cp .env.apicred apicredentials.txt
cp .env.password password.txt
rm .env.apicred && rm .env.password


rm *plinode*
rm sample*
rm *.bak
rm -R test/ && rm -R _archive/ && rm -r oneClickDeploy/ && rm -R docs/
rm time.txt
rm DISCLAIMER.md
rm README*
rm job_alarmclock_test.sh && rm gen_passwd.sh && rm base_sys_setup.sh && rm reset_pli.sh && rm pli_node_scripts.sh
rm go1.17.3.linux-amd64.tar.gz


sed -i "s/.env.password/password.txt/g" 2_nodeStartPM2.sh
sed -i "s/.env.apicred/apicredentials.txt/g" 2_nodeStartPM2.sh

pm2 start 2_nodeStartPM2.sh
pm2 start 3_initiatorStartPM2.sh

pm2 save
pm2 startup systemd
'''
---
**Reboot the host to ensure the processes startup automatically**
---