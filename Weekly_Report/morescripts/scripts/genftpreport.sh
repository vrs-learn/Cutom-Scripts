#!/bin/sh
##############################################################################
# Author : Vaibhav Raj Saxena
# Description : Generate and FTP the file to frrmdef-ap70
#
#
##############################################################################

#Send files to FTP dir

SCRIPTS_DIR="$HOME"/scripts/morescripts/scripts
DATA_DIR="$HOME"/scripts/morescripts/data

#Run the Job Extract Script
"$SCRIPTS_DIR"/jobs_extract_bynodes_appl.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Job Extract Report has failed. Please check"
  exit 2;
fi


ftpfile=all_dc_week8p.csv

#Sending the file to FTP Dir
sftp ftp_user@10.126.48.237 <<EOF
ascii
lcd $DATA_DIR
cd usage_reporting
put $ftpfile
bye
EOF
