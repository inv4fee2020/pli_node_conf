#!/bin/bash
source ~/.venv/aws-backups/bin/activate

set -eu
set -o pipefail

#export PATH=/bin:/usr/bin:/usr/local/bin
DATE_WITH_TIME=`date "+%d%b%Y-%H%M"`



################################################################
################## Update below values  ########################


DB_BACKUP_PATH='/backups/DB'
DB_HOST='localhost'
DB_PORT='5432'


DB_USER='USER'
DB_PASSWORD='PASSWORD'
DB_NAME='USER'
DB_BACKUP_FNAME="${DB_NAME}_DB_${DATE_WITH_TIME}"
DB_TYPE=PostgreSQL

BACKUP_RETAIN_DAYS=31  ## Number of days to keep local backup copy

S3_BACKUP_GPG_SECRET=/usr/local/etc/datafile_gpg_secret
S3_BUCKET_NAME='bucket-name'
S3_FOLDER=
S3_STORAGE_RETENTION=STANDARD_IA

# Valid choices are:    STANDARD | REDUCED_REDUNDANCY | STANDARD_IA |
#                       ONEZONE_IA | INTELLIGENT_TIERING | GLACIER |
#                       DEEP_ARCHIVE. Defaults to 'STANDARD'
#
#    https://aws.amazon.com/s3/storage-classes/?nc=sn&loc=3



#################################################################


echo "SCR-DB-BKUP: Scheduled script [ ${0##*/} ] : STARTED" | logger

if [ -n ${DB_BACKUP_PATH} ]; then
        echo "SCR-POSTGRES-BKUP: backup folder [${DB_BACKUP_PATH}] not found - CREATING..." | logger
        mkdir -p ${DB_BACKUP_PATH}/
fi


echo "SCR-DB-BKUP: ${DB_TYPE} Database backup started for DB [${DB_NAME}]"

#PGPASSWORD="${DB_PASSWORD}" pg_dump -Fc -h "localhost" -U "${DB_USER}" "${DATABASE_NAME}" -f ${DB_BACKUP_PATH}/${DATABASE_NAME}_DB"-"${DATE_WITH_TIME}.sql.gz
PGPASSWORD="${DB_PASSWORD}" pg_dump -Fc -h "localhost" -U "${DB_USER}" "${DB_NAME}" -f ${DB_BACKUP_PATH}/${DB_BACKUP_FNAME}.sql.gz

if [ $? -eq 0 ]; then
  echo "SCR-DB-BKUP: ${DB_TYPE} Database backup - SUCCESS - Code $?" | logger
  echo "SCR-DB-BKUP: ${DB_TYPE} Database file ${DB_BACKUP_FNAME} created" | logger
else
  echo "SCR-DB-BKUP: ${DB_TYPE} Database backup - FAILURE - Code $?" | logger
fi

## MAINTAIN FILE PERMISSIONS FOR NEW BACKUP FILES ##

chmod -R o-rx ${DB_BACKUP_PATH}


##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####

CFILES=$(find ${DB_BACKUP_PATH}/*.gz -type f -mtime +${BACKUP_RETAIN_DAYS} -print | wc -l)

if [ -n ${DB_BACKUP_PATH} ] && [ ${CFILES} != 0 ]; then
        find ${DB_BACKUP_PATH}/*.gz -type f -mtime +${BACKUP_RETAIN_DAYS} -print0 | while read -d $'\0' DFILE
        do
          echo "SCR-DB-BKUP: Remove files older than ${BACKUP_RETAIN_DAYS} - Deleting file : $DFILE" | logger
          rm -f $DFILE
        done
    else
        echo "SCR-DB-BKUP: backup folder [${DB_BACKUP_PATH}] contains [${CFILES}] files older than [${BACKUP_RETAIN_DAYS}] days - NOTHING TO DELETE" | logger
fi
echo "SCR-DB-BKUP: Scheduled script [ ${0##*/} ] : FINISHED" | logger

#### End of backup to LOCAL DISK processs ####


##### ENCRYPT DB backup file #####

ENC_FNAME=${DB_BACKUP_FNAME}.gpg
gpg --yes --batch --passphrase=${S3_BACKUP_GPG_SECRET} -o /tmp/${ENC_FNAME} -c /${DB_BACKUP_PATH}/${DB_BACKUP_FNAME}.sql.gz


##### UPLOAD DB backup file #####

if [ -z ${S3_FOLDER} ]; then
  aws s3 cp /tmp/${ENC_FNAME} s3://${S3_BUCKET_NAME}/ --storage-class ${S3_STORAGE_RETENTION}
else
  aws s3 cp /tmp/${ENC_FNAME} s3://${S3_BUCKET_NAME}/${S3_FOLDER}/ --storage-class ${S3_STORAGE_RETENTION}
fi

if [ $? -eq 0 ]; then
  echo "SCR-S3-BKUP: Encrypted Database file upload - SUCCESS - Code $?" | logger
  echo "SCR-S3-BKUP: Encrypted ${ENC_FNAME} uploaded to S3 bucket ${S3_BUCKET_NAME}" | logger
else
  echo "SCR-S3-BKUP: Encrypted Database file upload - FAILURE - Code $?" | logger
fi


##### Update the AWS TAG for the uploaded file #####

aws s3api put-object-tagging  \
--bucket bucket-name \
--key ${ENC_FNAME} \
--tagging 'TagSet=[{Key=Owner,Value=owner_value},{Key=Dataset,Value=data_value},{Key=Env,Value=env_value},{Key=Team,Value=team_value}]'


##### DELETE tmp file #####
rm /tmp/${ENC_FNAME}

# END OF SCRIPT
